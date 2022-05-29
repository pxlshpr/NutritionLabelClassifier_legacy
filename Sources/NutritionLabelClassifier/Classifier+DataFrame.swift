import SwiftSugar
import TabularData
import VisionSugar
import CoreText
import Foundation

struct Observation {
    var identifiableAttribute: IdentifiableAttribute
    var identifiableValue1: IdentifiableValue?
    var identifiableValue2: IdentifiableValue?
}

struct ProcessArtefactsResult {
    var observations: [Observation]
    var observationBeingExtracted: Observation?
}

extension NutritionLabelClassifier {

    static func haveTwoInlineValues(for recognizedText: RecognizedText, in recognizedTexts: [RecognizedText], forAttribute attribute: Attribute, ignoring discarded: [RecognizedText]) -> Bool {
        let inlineTextColumns = recognizedTexts.inlineTextColumns(as: recognizedText, ignoring: discarded)
        var inlineValueCount = 0
        for column in inlineTextColumns {
            guard let inlineText = pickInlineText(fromColumn: column, for: attribute) else { continue }
            if inlineText.artefacts.contains(where: { $0.value != nil }) {
                inlineValueCount += 1
            }
        }
        return inlineValueCount > 1
    }
    
//    static func processArtefacts(of recognizedText: RecognizedText) -> ProcessArtefactsResult {
//        processArtefacts(recognizedText.artefacts, forObservationWithId: recognizedText.id)
//    }

    public static func classify(_ recognizedTexts: [RecognizedText]) -> Output {
        classify([recognizedTexts])
    }

    public static func dataFrameOfNutrients(from recognizedTexts: [RecognizedText]) -> DataFrame {
        dataFrameOfNutrients(from: [recognizedTexts])
    }

    public static func dataFrameOfNutrients(from arrayOfRecognizedTexts: [[RecognizedText]]) -> DataFrame {
        var observations: [Observation] = []
        for recognizedTexts in arrayOfRecognizedTexts {
            extractNutrientObservations(from: recognizedTexts, into: &observations)
        }

        /// **Heuristic** If more than half of value2 is empty, clear it all, assuming we have erraneous reads
        if observations.percentageOfNilValue2 > 0.5 {
            observations = observations.clearingValue2
        }

        /// **Heuristic** If we have two values worth of data and any of the cells are missing where one value is 0, simply copy that across
        if observations.hasTwoColumnsOfValues {
            for index in observations.indices {
                let observation = observations[index]
                if observation.identifiableValue2 == nil, let value1 = observation.identifiableValue1, value1.value.amount == 0 {
                    observations[index].identifiableValue2 = value1
                }
            }
        }
        
        /// TODO: **Heursitic** Fill in the other missing values by simply using the ratio of values for what we had extracted successfully
        
        return dataFrameOfNutrients(from: observations)
    }
    
    private static func dataFrameOfNutrients(from observations: [Observation]) -> DataFrame {
        var dataFrame = DataFrame()
        let labelColumn = Column(name: "attribute", contents: observations.map { $0.identifiableAttribute })
        let value1Column = Column(name: "value1", contents: observations.map { $0.identifiableValue1 })
        let value2Column = Column(name: "value2", contents: observations.map { $0.identifiableValue2 })
//        let column1Id = ColumnID("values1", Value?.self)
//        let column2Id = ColumnID("values2", Value?.self)
//
        dataFrame.append(column: labelColumn)
        dataFrame.append(column: value1Column)
        dataFrame.append(column: value2Column)
        return dataFrame
    }
    
    static func pickInlineText(fromColumn column: [RecognizedText], for attribute: Attribute) -> RecognizedText? {
        
        /// **Heuristic** In order to account for slightly curved labels that may pick up both a `kJ` and `kcal` `Value` when looking for energy—always pick the `kJ` one (as its larger in value) regardless of how far away it is from the observation (as the curvature can sometimes skew this)
        if column.contains(where: { Value(fromString: $0.string)?.unit == .kcal }),
           column.contains(where: { Value(fromString: $0.string)?.unit == .kj }) {
            return column.first(where: { Value(fromString: $0.string)?.unit == .kj })
        }
        
        /// **Heuristic** Remove any texts that contain no artefacts before returning the closest one, if we have more than 1 in a column (see Test Case 22 for how `Alimentaires` and `1.5 g` fall in the same column, with the former overlapping with `Protein` more, and thus `1.5 g` getting ignored
        var column = column.filter {
            $0.artefacts.count > 0
//            Value(fromString: $0.string) != nil
        }
        
        /// **Heuristic** Remove any values that aren't supported by the attribute we're extracting
        column = column.filter {
            if let unit = Value(fromString: $0.string)?.unit {
                return attribute.supportsUnit(unit)
            }
            return true
        }
        
        /// As the defaul fall-back, return the first text (ie. the one closest to the observation we're extracted)
        return column.first
    }
}

extension Array where Element == Observation {
    var hasTwoColumnsOfValues: Bool {
        for observation in self {
            if observation.identifiableValue2 != nil {
                return true
            }
        }
        return false
    }
    
    var percentageOfNilValue2: Double {
        var numberOfNilValue2s = 0.0
        for observation in self {
            if observation.identifiableValue2 == nil {
                numberOfNilValue2s += 1
            }
        }
        return numberOfNilValue2s / Double(count)
    }
    
    var clearingValue2: [Observation] {
        var observations = self
        for index in observations.indices {
            observations[index].identifiableValue2 = nil
        }
        return observations
    }
}

extension Array where Element == Artefact {
    func valuePreceding(_ attribute: Attribute) -> Value? {
        guard let attributeIndex = firstIndex(where: { $0.attribute == attribute }),
              attributeIndex > 0,
              let value = self[attributeIndex-1].value
        else {
            return nil
        }
        
        /// If the value has a unit, make sure that the attribute supports it
        if let unit = value.unit {
            guard attribute.supportsUnit(unit) else {
                return nil
            }
        } else {
            /// Otherwise, if the value has no unit, make sure that the attribute supports unit-less values
            guard attribute.supportsUnitLessValues else {
                return nil
            }
        }
        
        return value
    }
}
