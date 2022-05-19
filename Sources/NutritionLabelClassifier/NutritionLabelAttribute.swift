import Foundation

enum NutritionLabelAttribute: CaseIterable {
    case servingSizeVolume
    case servingSizeWeight
    case servingSizeDescriptive
    case servingsPerContainer
    
    case energy
    
    case protein
    
    case carbohydrate
    case dietaryFibre

    case fat
    case saturatedFat
    case transFat
    case cholesterol
    
    case sodium
    case calcium
    case sugar
    
    var regex: String? {
        switch self {
        case .energy:
            return #"energy"#
            
        case .protein:
            return #"protein"#
            
        case .carbohydrate:
            return #"carb.*"#
        case .dietaryFibre:
            return #"dietary fibre"#

        case .fat:
            return #"fat"#
        case .saturatedFat:
            return #"saturated"#
        case .transFat:
            return #"trans"#
        case .cholesterol:
            return #"cholesterol"#
            
        case .sodium:
            return #"(sodium|salt)"#
        case .sugar:
            return #"sugar"#
        case .calcium:
            return #"calcium"#
            
        default:
            return nil
        }
    }
    
    var isValueBased: Bool {
        switch self {
        case .servingSizeVolume, .servingSizeWeight, .servingSizeDescriptive, .servingsPerContainer:
            return false
        default:
            return true
        }
    }
}
