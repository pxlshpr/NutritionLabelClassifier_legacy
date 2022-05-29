import Foundation
import VisionSugar
import TabularData

extension NutritionLabelClassifier {
    public static func classify(_ arrayOfRecognizedTexts: [[RecognizedText]]) -> Output {
        let dataFrame = dataFrameOfNutrients(from: arrayOfRecognizedTexts)
        return dataFrame.classifierOutput
    }
    
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
                if observation.valueText2 == nil, let value1 = observation.valueText1, value1.value.amount == 0 {
                    observations[index].valueText2 = value1
                }
            }
        }
        
        /// TODO: **Heursitic** Fill in the other missing values by simply using the ratio of values for what we had extracted successfully
        
        return dataFrameOfNutrients(from: observations)
    }
    
    private static func dataFrameOfNutrients(from observations: [Observation]) -> DataFrame {
        var dataFrame = DataFrame()
        let labelColumn = Column(name: "attribute", contents: observations.map { $0.attributeText })
        let value1Column = Column(name: "value1", contents: observations.map { $0.valueText1 })
        let value2Column = Column(name: "value2", contents: observations.map { $0.valueText2 })
//        let column1Id = ColumnID("values1", Value?.self)
//        let column2Id = ColumnID("values2", Value?.self)
//
        dataFrame.append(column: labelColumn)
        dataFrame.append(column: value1Column)
        dataFrame.append(column: value2Column)
        return dataFrame
    }
}
