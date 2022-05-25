import VisionSugar
import TabularData

extension NutritionLabelClassifier {
    public static func classify(_ arrayOfRecognizedTexts: [[RecognizedText]]) -> Output {
        let dataFrame = dataFrameOfNutrients(from: arrayOfRecognizedTexts)
        return dataFrame.classifierOutput
    }
}

extension DataFrame {
    
    var classifierOutput: Output {
        
        let rows: [Output.NutrientRow] = rows.compactMap { row in
            guard let attributeWithIdRow = row["attribute"] as? AttributeWithId,
                  let valueWithId1Row = row["value1"] as? ValueWithId?,
                  let valueWithId2Row = row["value2"] as? ValueWithId? else {
                return nil
            }
            
            guard attributeWithIdRow.attribute.isNutrient else {
                return nil
            }
            
            let attributeWithId = Output.NutrientRow.AttributeWithId(
                attribute: attributeWithIdRow.attribute,
                id: attributeWithIdRow.observationId
            )
            let value1WithId: Output.NutrientRow.ValueWithId?
            if let valueWithId = valueWithId1Row {
                value1WithId = Output.NutrientRow.ValueWithId(
                    value: valueWithId.value,
                    id: valueWithId.observationId
                )
            } else {
                value1WithId = nil
            }

            let value2WithId: Output.NutrientRow.ValueWithId?
            if let valueWithId = valueWithId2Row {
                value2WithId = Output.NutrientRow.ValueWithId(
                    value: valueWithId.value,
                    id: valueWithId.observationId
                )
            } else {
                value2WithId = nil
            }

            return Output.NutrientRow(
                attributeWithId: attributeWithId, value1WithId: value1WithId, value2WithId: value2WithId
            )
        }
        
        
        var perContainer: Output.Serving.PerContainer? = nil
        if let row = rows.first(where: { $0.attributeWithId.attribute == .servingsPerContainer}), let valueWithId = row.value1WithId {
            perContainer = Output.Serving.PerContainer(
                valueWithId: Output.DoubleWithId(
                    double: valueWithId.value.amount,
                    id: valueWithId.id),
                nameWithId: nil)
        }
        let serving = Output.Serving(amount: nil, perContainer: perContainer)        
        let nutrients = Output.Nutrients(columnHeader1: nil, columnHeader2: nil, rows: rows)
        
        return Output(serving: serving, nutrients: nutrients, primaryColumnIndex: 0)
    }
}
