import Foundation

extension DoubleText {
    init(_ valueText: ValueText) {
        self.double = valueText.value.amount
        self.textId = valueText.textId
        self.attributeTextId = valueText.textId
    }
    init(_ doubleText: DoubleText) {
        self.double = doubleText.double
        self.textId = doubleText.textId
        self.attributeTextId = doubleText.textId
    }
}

extension UnitText {
    init?(_ valueText: ValueText) {
        guard let unit = valueText.value.unit else {
            return nil
        }
        self.unit = unit
        self.textId = valueText.textId
        self.attributeTextId = valueText.textId
    }
    init?(_ stringText: StringText) {
        guard let unit = NutritionUnit(string: stringText.string) else {
            return nil
        }
        self.unit = unit
        self.textId = stringText.textId
        self.attributeTextId = stringText.textId
    }
}

public extension Output {
    var containsServingAttributes: Bool {
        guard let serving = serving else { return false }
        return serving.amount != nil
        || serving.unit != nil
        || serving.unitName != nil
        || serving.equivalentSize != nil
        || serving.perContainer != nil
    }
    
    func containsAttribute(_ attribute: Attribute) -> Bool {
        switch attribute {
        case .nutritionFacts:
            return false
        case .servingAmount:
            return serving?.amount != nil
        case .servingUnit:
            return serving?.unit != nil
        case .servingUnitSize:
            return serving?.unitName != nil
        case .servingEquivalentAmount:
            return serving?.equivalentSize != nil
        case .servingEquivalentUnit:
            return serving?.equivalentSize?.unit != nil
        case .servingEquivalentUnitSize:
            return serving?.equivalentSize?.sizeName != nil
        case .servingsPerContainerAmount:
            return serving?.perContainer != nil
        case .servingsPerContainerName:
            return serving?.perContainer?.name != nil
        case .headerType1:
            return nutrients.headerText1 != nil
        case .headerType2:
            return nutrients.headerText2 != nil
        default:
            return nutrients.rows.contains(where: { $0.attribute == attribute })
        }
    }
}
