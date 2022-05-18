import Foundation

enum NLClassifierClass: CaseIterable {
    case servingSizeVolume
    case servingSizeWeight
    case servingSizeDescriptive
    case servingsPerContainer
    case energy
    case macroProtein
    case macroCarbs
    case macroFat
    case microCholesterol
    case microSaturatedFat
    case microTransFat
    case microDietaryFibre
    case microSodium
    case microCalcium
    case microSugar
    
    var regex: String? {
        switch self {
        case .energy:
            return #"energy"#
        case .macroProtein:
            return #"protein"#
        case .macroCarbs:
            return #"carb.*"#
        case .macroFat:
            return #"fat"#
        case .microCholesterol:
            return #"cholesterol"#
        case .microSaturatedFat:
            return #"saturated"#
        case .microTransFat:
            return #"trans"#
        case .microDietaryFibre:
            return #"dietary fibre"#
        case .microSodium:
            return #"(sodium|salt)"#
        case .microSugar:
            return #"sugar"#
        case .microCalcium:
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
