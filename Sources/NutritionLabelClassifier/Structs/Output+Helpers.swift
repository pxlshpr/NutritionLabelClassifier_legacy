import Foundation

public extension Output {
    var containsServingAttributes: Bool {
        guard let serving = serving else { return false }
        return serving.amount != nil
        || serving.unit != nil
        || serving.unitSizeName != nil
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
            return serving?.unitSizeName != nil
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
        case .columnHeader1Type:
            return nutrients.headerText1 != nil
        case .columnHeader2Type:
            return nutrients.headerText2 != nil
        default:
            return nutrients.rows.contains(where: { $0.attribute == attribute })
        }
    }
}
