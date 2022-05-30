import Foundation
import VisionSugar
import TabularData

extension DataFrame {
    func rowForObservedAttribute(_ attribute: Attribute) -> DataFrame.Rows.Element? {
        rows.first(where: {
            guard let attributeWithId = $0[.attribute] as? AttributeText else { return false }
            return attributeWithId.attribute == attribute
        })
    }
    
    func valueText1ForAttribute(_ attribute: Attribute) -> ValueText? {
        guard let row = rowForObservedAttribute(attribute) else { return nil }
        return row[.value1] as? ValueText
    }
    
    func valueText2ForAttribute(_ attribute: Attribute) -> ValueText? {
        guard let row = rowForObservedAttribute(attribute) else { return nil }
        return row[.value2] as? ValueText
    }
    
    func doubleTextForAttribute(_ attribute: Attribute) -> DoubleText? {
        guard let row = rowForObservedAttribute(attribute) else { return nil }
        return row[.double] as? DoubleText
    }

    func stringTextForAttribute(_ attribute: Attribute) -> StringText? {
        guard let row = rowForObservedAttribute(attribute) else { return nil }
        return row[.string] as? StringText
    }

    func unitTextForAttribute(_ attribute: Attribute) -> UnitText? {
        guard let stringText = stringTextForAttribute(attribute),
              let unit = NutritionUnit(string: stringText.string) else {
            return nil
        }
        return UnitText(unit: unit, textId: stringText.textId)
    }
}

extension String {
    static let attribute = "attribute"
    static let value1 = "value1"
    static let value2 = "value2"
    static let double = "double"
    static let string = "string"
    
    static let attributeString = "attributeString"
    static let value1String = "value1String"
    static let value2String = "value2String"
    static let doubleString = "doubleString"
}
extension DataFrame {
    
    var nutrients: Output.Nutrients {
        /// Get all the `Output.Nutrient.Row`s
        let rows: [Output.Nutrients.Row] = rows.compactMap { row in
            guard let attributeText = row[.attribute] as? AttributeText,
                  let value1Text = row[.value1] as? ValueText?,
                  let value2Text = row[.value2] as? ValueText?
            else {
                return nil
            }
            
            guard value1Text != nil || value2Text != nil else {
                return nil
            }
            
            return Output.Nutrients.Row(
                attributeText: attributeText,
                valueText1: value1Text,
                valueText2: value2Text
            )
        }
        
        //TODO: Get the Header rows if available
        
        return Output.Nutrients(
            headerText1: nil,
            headerText2: nil,
            rows: rows.filter { $0.attributeText.attribute.isNutrient }
        )
    }
    
    var perContainer: Output.Serving.PerContainer? {
        guard let valueText = valueText1ForAttribute(.servingsPerContainerAmount) else {
            return nil
        }
        return Output.Serving.PerContainer(
            amountText: DoubleText(valueText),
            nameText: nil
        )
    }
    
    var equivalentSize: Output.Serving.EquivalentSize? {
        guard let doubleText = doubleTextForAttribute(.servingEquivalentAmount) else {
            return nil
        }
        return Output.Serving.EquivalentSize(
            amountText: DoubleText(doubleText),
            unitText: unitTextForAttribute(.servingEquivalentUnit),
            unitNameText: stringTextForAttribute(.servingEquivalentUnitSize)
        )
    }
    
    var serving: Output.Serving? {
        guard let doubleText = doubleTextForAttribute(.servingAmount) else {
            return nil
        }
        return Output.Serving(
            amountText: DoubleText(doubleText),
            unitText: unitTextForAttribute(.servingUnit),
            unitNameText: stringTextForAttribute(.servingUnitSize),
            equivalentSize: equivalentSize,
            perContainer: perContainer
        )
    }
    
    var classifierOutput: Output {
        Output(
            serving: serving,
            nutrients: nutrients
        )
    }
}
