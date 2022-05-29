import SwiftSugar
import TabularData
import VisionSugar
import CoreText
import Foundation

struct Observation {
//    var attributeWithId: AttributeWithId
    var identifiableAttribute: IdentifiableAttribute
    var identifiableValue1: IdentifiableValue?
    var identifiableValue2: IdentifiableValue?
//    var valueWithId1: ValueWithId?
//    var valueWithId2: ValueWithId?
}

struct ProcessArtefactsResult {
    var rows: [Observation]
    var rowBeingExtracted: Observation?
}
//public typealias ValueWithId = (value: Value, observationId: UUID)

//public typealias AttributeWithId = (attribute: Attribute, observationId: UUID)
//public typealias Observation = (attributeWithId: AttributeWithId, valueWithId1: ValueWithId?, valueWithId2: ValueWithId?)

//typealias ProcessArtefactsResult = (rows: [Observation], rowBeingExtracted: Observation?)

extension NutritionLabelClassifier {

//    static func extractAttribute(_ attribute: Attribute, from recognizedTexts: [RecognizedText]) -> Row {
//        return (attribute, nil, nil)
//    }

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
    
    static func processArtefacts(of recognizedText: RecognizedText, from recognizedTexts: [RecognizedText], ignoring discarded: [RecognizedText]) -> ProcessArtefactsResult {
        
        let artefacts = recognizedText.artefacts
        let id = recognizedText.id

        var rows: [Observation] = []
        var identifiableAttributeBeingExtracted: IdentifiableAttribute? = nil
//        var attributeBeingExtractedWithId: AttributeWithId? = nil
        var value1BeingExtracted: Value? = nil
        
        var ignoreNextValueDueToPerPreposition = false
        
        for i in artefacts.indices {
            let artefact = artefacts[i]
            if let extractedAttribute = artefact.attribute {
                /// if we're in the process of extracting a value, save it as a row
                if let attributeBeingExtracted = identifiableAttributeBeingExtracted, let valueBeingExtracted = value1BeingExtracted {
                    rows.append(Observation(identifiableAttribute: attributeBeingExtracted,
                                            identifiableValue1: IdentifiableValue(value: valueBeingExtracted, id: id),
                                            identifiableValue2: nil))
//                    rows.append((attributeBeingExtracted, (valueBeingExtracted, id), nil))
                    value1BeingExtracted = nil
                }
                identifiableAttributeBeingExtracted = IdentifiableAttribute(attribute: extractedAttribute, id: recognizedText.id)
//                attributeBeingExtractedWithId = (extractedAttribute, recognizedText.id)
                
            } else if let value = artefact.value, let attributeWithId = identifiableAttributeBeingExtracted {
                
                var unit = value.unit
                var value = value
                
                /// **Heuristic** If the value is missing its unit, *and* we don't have two values available inline, *and* it doesn't allow unit-less values—assign the attribute's default unit to it
                if unit == nil,
                   !attributeWithId.attribute.supportsUnitLessValues,
                   !haveTwoInlineValues(for: recognizedText,
                                        in: recognizedTexts,
                                        forAttribute: attributeWithId.attribute,
                                        ignoring: discarded)
                {
                    guard let defaultUnit = attributeWithId.attribute.defaultUnit else {
                        continue
                    }
                    value = Value(amount: value.amount, unit: defaultUnit)
                    unit = defaultUnit
                }
                
                if !attributeWithId.attribute.supportsUnitLessValues {
                    guard let _ = unit else { continue }
                }
                
                guard !ignoreNextValueDueToPerPreposition else {
                    ignoreNextValueDueToPerPreposition = false
                    continue
                }
                
                if let value1 = value1BeingExtracted, let unit1 = value1.unit {
                    if attributeWithId.attribute.isNutrient {
                        /// If the unit doesn't match the first one we got, ignore this
                        guard unit == unit1 else {
                            continue
                        }
                    }
                    rows.append(Observation(identifiableAttribute: attributeWithId,
                                            identifiableValue1: IdentifiableValue(value: value1, id: id),
                                            identifiableValue2: IdentifiableValue(value: value, id: id)))
//                    rows.append((attributeWithId, (value1, id), (value, id)))
                    identifiableAttributeBeingExtracted = nil
                    value1BeingExtracted = nil
                } else {
                    /// Before setting this as the first value, check that the attribute supports the unit, and that we don't have the RI (required intake) preposition immediately following it
                    var nextArtefactInvalidatesValue = false
                    if i < artefacts.count - 1,
                       let nextArtefactAsPreposition = artefacts[i+1].preposition,
                       nextArtefactAsPreposition.invalidatesPreviousValueArtefact
                    {
                        nextArtefactInvalidatesValue = true
                    }
                    
                    guard !nextArtefactInvalidatesValue else {
                        continue
                    }
                    if let unit = unit {
                        guard attributeWithId.attribute.supportsUnit(unit) else {
                            continue
                        }
                    }
                    
//                    guard attributeWithId.attribute.supportsUnit(unit), !nextArtefactInvalidatesValue else {
//                        continue
//                    }
                    value1BeingExtracted = value
                    
                    /// If the attribute doesn't support multiple units (such as `servingsPerContainerAmount`), add the row and clear the variables now
                    if !attributeWithId.attribute.supportsMultipleColumns {
                        rows.append(Observation(identifiableAttribute: attributeWithId,
                                                identifiableValue1: IdentifiableValue(value: value, id: id),
                                                identifiableValue2: nil))
//                        rows.append((attributeWithId, (value, id), nil))
                        value1BeingExtracted = nil
                        identifiableAttributeBeingExtracted = nil
                    }
                }
            } else if let preposition = artefact.preposition {
                if preposition.containsPer {
                    ignoreNextValueDueToPerPreposition = true
                }
            }
        }
        
        if let attributeBeingExtracted = identifiableAttributeBeingExtracted {
            if let value1BeingExtracted = value1BeingExtracted {
                return ProcessArtefactsResult(
                    rows: rows,
                    rowBeingExtracted: Observation(identifiableAttribute: attributeBeingExtracted,
                                                   identifiableValue1: IdentifiableValue(value: value1BeingExtracted, id: id),
                                                   identifiableValue2: nil)
                )
//                return (rows, Observation(identifiableAttribute: attributeBeingExtracted,
//                                          identifiableValue1: IdentifiableValue(value: value1BeingExtracted, id: id),
//                                          identifiableValue2: nil))
//                return (rows, (attributeBeingExtracted, (value1BeingExtracted, id), nil))
            } else {
                if attributeBeingExtracted.attribute.supportsPrecedingValue,
                   let value = artefacts.valuePreceding(attributeBeingExtracted.attribute) {
                    return ProcessArtefactsResult(
                        rows: rows,
                        rowBeingExtracted: Observation(identifiableAttribute: attributeBeingExtracted,
                                                       identifiableValue1: IdentifiableValue(value: value, id: id),
                                                       identifiableValue2: nil)
                    )
//                    return (rows, Observation(identifiableAttribute: attributeBeingExtracted,
//                                              identifiableValue1: IdentifiableValue(value: value, id: id),
//                                              identifiableValue2: nil))
//                    return (rows, (attributeBeingExtracted, (value, id), nil))
                } else {
                    return ProcessArtefactsResult(
                        rows: rows,
                        rowBeingExtracted: Observation(identifiableAttribute: attributeBeingExtracted,
                                                       identifiableValue1: nil,
                                                       identifiableValue2: nil)
                    )
//                    return (rows, Observation(identifiableAttribute: attributeBeingExtracted,
//                                              identifiableValue1: nil,
//                                              identifiableValue2: nil))
//                    return (rows, (attributeBeingExtracted, nil, nil))
                }
            }
        } else {
            return ProcessArtefactsResult(
                rows: rows,
                rowBeingExtracted: nil
            )
//            return (rows, nil)
        }
        /// Get the artefacts
        /// For each artefact
        ///     If it is an `Attribute`
        ///         save it as the `attributeBeingExtracted`
        ///     If it is a `Value`,
        ///         If we have a `attributeBeingExtracted`
        ///             If we don't have `value1` and its a supported unit
        ///                 Save it as `value1`
        ///             Else (we have `value1)`
        ///                 If its the same unit as `value1`
        ///                     Set the row with (`attributeBeingExtracted, value1, value2)`
        ///                     Reset `attributeBeingExtracted` and `value1`
        /// If we have `attributeBeingExtracted`, call the extraction function with it
    }
    
//    static func processArtefacts(of recognizedText: RecognizedText) -> ProcessArtefactsResult {
//        processArtefacts(recognizedText.artefacts, forObservationWithId: recognizedText.id)
//    }

    static func extract(_ row: inout Observation, from recognizedText: RecognizedText, extractedRows: [Observation]) -> (didExtract: Bool, shouldContinue: Bool) {
        
        var didExtract = false
        for artefact in recognizedText.getArtefacts(for: row.identifiableAttribute.attribute, rowBeingExtracted: row, extractedRows: extractedRows) {
            if let value = artefact.value {
                
                /// **Heuristic** If the value is missing its unit and the attribute has a default unit, assign it to it
                var unit = value.unit
                var value = value
                if unit == nil {
                    guard let defaultUnit = row.identifiableAttribute.attribute.defaultUnit else {
                        continue
                    }
                    value = Value(amount: value.amount, unit: defaultUnit)
                    unit = defaultUnit
                }
                guard let unit = unit else { continue }
                
                if let value1 = row.identifiableValue1 {
                    guard let unit1 = value1.value.unit, unit == unit1 else {
                        continue
                    }
                    row.identifiableValue2 = IdentifiableValue(value: value, id: recognizedText.id)
//                    row.value2 = value
                    didExtract = true
                    /// Send `false` for algorithm to stop searching inline texts once we have completed the row
                    return (didExtract: didExtract, shouldContinue: false)
                } else if row.identifiableAttribute.attribute.supportsUnit(unit) {
                    row.identifiableValue1 = IdentifiableValue(value: value, id: recognizedText.id)
//                    row.value1 = value
                    didExtract = true
                }
            } else if let _ = artefact.attribute {
                /// Send `false` for algorithm to stop searching inline texts once we hit another `Attribute`
                return (didExtract: didExtract, shouldContinue: false)
            }
        }
        /// Send `true` for algorithm to keep searching inline texts if we haven't hit another `Attribute` or completed the `Row`
        return (didExtract: didExtract, shouldContinue: true)
        
        ///         For each of its artefacts
        ///             If it is a `Value`
        ///                 If we don't have `value1` and its a supported unit
        ///                     Save it as `value1`
        ///                 Else (we have `value1)`
        ///                     If its the same unit as `value1`
        ///                         Set the row with (`attributeBeingExtracted, value1, value2)`
        ///                         Reset `attributeBeingExtracted` and `value1`
        ///             Else if it is (another) `Attribute`
        ///                 return false
    }

    public static func classify(_ recognizedTexts: [RecognizedText]) -> Output {
        classify([recognizedTexts])
    }

    public static func dataFrameOfNutrients(from recognizedTexts: [RecognizedText]) -> DataFrame {
        dataFrameOfNutrients(from: [recognizedTexts])
    }

    public static func dataFrameOfNutrients(from arrayOfRecognizedTexts: [[RecognizedText]]) -> DataFrame {
        var rows: [Observation] = []
        for recognizedTexts in arrayOfRecognizedTexts {
            extractRowsOfNutrients(from: recognizedTexts, into: &rows)
        }

        /// **Heuristic** If more than half of value2 is empty, clear it all, assuming we have erraneous reads
        if rows.percentageOfNilValue2 > 0.5 {
            rows = rows.clearingValue2
        }

        /// **Heuristic** If we have two values worth of data and any of the cells are missing where one value is 0, simply copy that across
        if rows.hasTwoColumnsOfValues {
            for index in rows.indices {
                let row = rows[index]
                if row.identifiableValue2 == nil, let value1 = row.identifiableValue1, value1.value.amount == 0 {
                    rows[index].identifiableValue2 = value1
                }
            }
        }
        
        /// TODO: **Heursitic** Fill in the other missing values by simply using the ratio of values for what we had extracted successfully
        
        return dataFrameOfNutrients(from: rows)
    }
    
    private static func dataFrameOfNutrients(from rows: [Observation]) -> DataFrame {
        var dataFrame = DataFrame()
        let labelColumn = Column(name: "attribute", contents: rows.map { $0.identifiableAttribute })
        let value1Column = Column(name: "value1", contents: rows.map { $0.identifiableValue1 })
        let value2Column = Column(name: "value2", contents: rows.map { $0.identifiableValue2 })
//        let column1Id = ColumnID("values1", Value?.self)
//        let column2Id = ColumnID("values2", Value?.self)
//
        dataFrame.append(column: labelColumn)
        dataFrame.append(column: value1Column)
        dataFrame.append(column: value2Column)
        return dataFrame
    }
    
    private static func heuristicRecognizedTextIsPartOfAttribute(_ recognizedText: RecognizedText, from recognizedTexts: [RecognizedText]) -> Bool {
        recognizedText.string.lowercased() == "vitamin"
    }
    
    private static func processArtefactsOf(_ recognizedText: RecognizedText, byJoiningWithNextInlineRecognizedTextIn recognizedTexts: [RecognizedText], rows: [Observation], ignoring discarded: [RecognizedText]) ->  ProcessArtefactsResult
    {
        guard let nextRecognizedText = recognizedTexts.inlineTextColumns(as: recognizedText).first?.first else {
            return ProcessArtefactsResult(
                rows: rows,
                rowBeingExtracted: nil
            )
//            return (rows: rows, rowBeingExtracted: nil)
        }
        let combinedRecognizedText = RecognizedText(
            id: nextRecognizedText.id,
            rectString: NSCoder.string(for: nextRecognizedText.rect),
            boundingBoxString: NSCoder.string(for: nextRecognizedText.boundingBox),
            candidates: ["\(recognizedText.string) \(nextRecognizedText.string)"])
        return processArtefacts(of: combinedRecognizedText, from: recognizedTexts, ignoring: discarded)
    }
    
    private static func extractRowsOfNutrients(from recognizedTexts: [RecognizedText], into rows: inout [Observation]) {
        
//        var rows: [Row] = []
        
        /// Holds onto those that are single `Value`s that have already been used
        var discarded: [RecognizedText] = []

        for recognizedText in recognizedTexts {
            
            let result: ProcessArtefactsResult
            if heuristicRecognizedTextIsPartOfAttribute(recognizedText, from: recognizedTexts) {
                result = processArtefactsOf(recognizedText, byJoiningWithNextInlineRecognizedTextIn: recognizedTexts, rows: rows, ignoring: discarded)
            } else {
                result = processArtefacts(of: recognizedText, from: recognizedTexts, ignoring: discarded)
            }
            
            /// Process any attributes that were extracted
            for row in result.rows {
                /// Only add attributes that haven't already been added
                if !rows.contains(where: { $0.identifiableAttribute.attribute == row.identifiableAttribute.attribute }) {
                    rows.append(row)
                }
            }
            
            /// Now do an inline search for any attribute that is still being extracted
            if let row = result.rowBeingExtracted {
                
                /// If we have a value1 for this row, make sure we add the recognized text it was added from to the discarded list before checking the inline ones
                if let value1Id = row.identifiableValue1?.id,
                    let recognizedTextForValue1 = recognizedTexts.first(where: { $0.id == value1Id })
                {
                    discarded.append(recognizedTextForValue1)
                }
                
                /// Skip attributes that have already been added
                guard !rows.contains(where: { $0.identifiableAttribute.attribute == row.identifiableAttribute.attribute }) else {
                    continue
                }

                var rowBeingExtracted = row
                let inlineTextColumns = recognizedTexts.inlineTextColumns(as: recognizedText, ignoring: discarded)
                for column in inlineTextColumns {
                    
                    guard let inlineText = pickInlineText(fromColumn: column, for: row.identifiableAttribute.attribute) else { continue }
                    
                    let result = extract(&rowBeingExtracted, from: inlineText, extractedRows: rows)
                    /// If we did extract a value, and the `recognizedText` had a single `Value` artefact—add it to the discarded pile so it doesn't get selected as= an inline text again
                    if result.didExtract,
                       inlineText.artefacts.count >= 1,
                       let _ = inlineText.artefacts.first?.value
                    {
                        discarded.append(inlineText)
                    }
                    if !result.shouldContinue {
                        break
                    }
                }
                
                /// After going through all inline texts and not completing the row, add this (possibly incomplete one)
                guard rowBeingExtracted.identifiableValue1 != nil || rowBeingExtracted.identifiableValue2 != nil else {
                    continue
                }
                rows.append(rowBeingExtracted)
            }
        }
//        return rows
    }
    
    static func pickInlineText(fromColumn column: [RecognizedText], for attribute: Attribute) -> RecognizedText? {
        
        /// **Heuristic** In order to account for slightly curved labels that may pick up both a `kJ` and `kcal` `Value` when looking for energy—always pick the `kJ` one (as its larger in value) regardless of how far away it is from the row (as the curvature can sometimes skew this)
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
        
        /// As the defaul fall-back, return the first text (ie. the one closest to the row we're extracted)
        return column.first
    }
}

extension Array where Element == Observation {
    var hasTwoColumnsOfValues: Bool {
        for row in self {
            if row.identifiableValue2 != nil {
                return true
            }
        }
        return false
    }
    
    var percentageOfNilValue2: Double {
        var numberOfNilValue2s = 0.0
        for row in self {
            if row.identifiableValue2 == nil {
                numberOfNilValue2s += 1
            }
        }
        return numberOfNilValue2s / Double(count)
    }
    
    var clearingValue2: [Observation] {
        var rows = self
        for index in rows.indices {
            rows[index].identifiableValue2 = nil
        }
        return rows
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
