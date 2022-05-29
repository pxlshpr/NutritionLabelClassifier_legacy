import Foundation
import VisionSugar
import TabularData

extension DataFrame {
    func rowForObservedAttribute(_ attribute: Attribute) -> DataFrame.Rows.Element? {
        rows.first(where: {
            guard let attributeWithId = $0["attribute"] as? AttributeText else {
                return false
            }
            return attributeWithId.attribute == attribute
        })
    }

    func identifiableValue1ForAttribute(_ attribute: Attribute) -> ValueText? {
        guard let row = rowForObservedAttribute(attribute) else {
            return nil
        }
        return row["value1"] as? ValueText
    }
    
    func identifiableValue2ForAttribute(_ attribute: Attribute) -> ValueText? {
        guard let row = rowForObservedAttribute(attribute) else {
            return nil
        }
        return row["value2"] as? ValueText
    }
}

extension DataFrame {
    
    var classifierOutput: Output {
        
        let rows: [Output.Nutrients.Row] = rows.compactMap { row in
            guard let attributeWithIdRow = row["attribute"] as? AttributeText,
                  let valueWithId1Row = row["value1"] as? ValueText?,
                  let valueWithId2Row = row["value2"] as? ValueText? else {
                return nil
            }
            
            guard valueWithId1Row != nil || valueWithId2Row != nil else {
                return nil
            }
            
            let attributeWithId = AttributeText(
                attribute: attributeWithIdRow.attribute,
                textId: attributeWithIdRow.textId
            )
            let value1WithId: ValueText?
            if let valueWithId = valueWithId1Row {
                value1WithId = ValueText(
                    value: valueWithId.value,
                    textId: valueWithId.textId
                )
            } else {
                value1WithId = nil
            }

            let value2WithId: ValueText?
            if let valueWithId = valueWithId2Row {
                value2WithId = ValueText(
                    value: valueWithId.value,
                    textId: valueWithId.textId
                )
            } else {
                value2WithId = nil
            }

            return Output.Nutrients.Row(
                attributeText: attributeWithId,
                valueText1: value1WithId,
                valueText2: value2WithId
            )
        }

        let nutrients = Output.Nutrients(
            headerText1: nil,
            headerText2: nil,
            rows: rows.filter { $0.attributeText.attribute.isNutrient })

        let perContainer: Output.Serving.PerContainer?
        if let valueWithId = identifiableValue1ForAttribute(.servingsPerContainerAmount) {
            perContainer = Output.Serving.PerContainer(
                amountText: DoubleText(valueWithId),
                nameText: nil)
        } else {
            perContainer = nil
        }
        
        let serving: Output.Serving?
        if let value1WithId = identifiableValue1ForAttribute(.servingAmount) {
            
            let equivalentSize: Output.Serving.EquivalentSize?
            if let value2WithId = identifiableValue2ForAttribute(.servingAmount) {
                equivalentSize = Output.Serving.EquivalentSize(
                    amountText: DoubleText(value2WithId),
                    unitText: UnitText(value2WithId),
                    unitNameText: nil
                )
            } else {
                equivalentSize = nil
            }
            
            serving = Output.Serving(
                amountText: DoubleText(value1WithId),
                unitText: UnitText(value1WithId),
                unitNameText: nil,
                equivalentSize: equivalentSize,
                perContainer: perContainer
            )
        } else {
            serving = nil
        }
           
        
        return Output(serving: serving, nutrients: nutrients, primaryColumnIndex: 0)
    }
}
