import Foundation

enum Attribute: String, CaseIterable {
    case servingSizeVolume
    case servingSizeWeight
    case servingSizeDescriptive
    case servingsPerContainer
    
    case energy
    
    case protein
    
    case carbohydrate
    case dietaryFibre
    case gluten
    case sugar
    case starch
    
    case fat
    case saturatedFat
    case polyunsaturatedFat
    case monounsaturatedFat
    case transFat
    case cholesterol
    
    case salt
    case sodium
    case calcium
    case iron
    case potassium
    
    case vitaminA
    case vitaminC
    case vitaminD
    
    var parentAttribute: Attribute? {
        switch self {
        case .saturatedFat, .polyunsaturatedFat, .monounsaturatedFat, .transFat, .cholesterol:
            return .fat
        case .dietaryFibre, .gluten, .sugar, .starch:
            return .carbohydrate
        case .sodium:
            return .salt
        default:
            return nil
        }
    }
    func supportsUnit(_ unit: NutritionUnit) -> Bool {
        supportedUnits.contains(unit)
    }
    
    var supportsMultipleColumns: Bool {
        switch self {
        case .energy:
            return true
        default:
            return false
        }
    }
    
    var supportedUnits: [NutritionUnit] {
        switch self {
        case .energy:
            return [.kcal, .kj]
        case .protein, .carbohydrate, .fat:
            return [.g]
        case .dietaryFibre, .saturatedFat, .polyunsaturatedFat, .monounsaturatedFat, .transFat, .cholesterol, .sugar, .gluten, .starch:
            return [.g, .mg, .mcg]
        case .salt, .sodium, .calcium, .iron, .potassium, .vitaminA, .vitaminC, .vitaminD:
            return [.g, .mg, .mcg, .p]
//        case .servingSizeVolume:
//        case .servingSizeWeight:
//        case .servingSizeDescriptive:
//        case .servingsPerContainer:
        default:
            return []
        }
    }
    
    var regex: String? {
        switch self {
        case .energy:
            return #"^.*(energy|calories).*$"#
            
        case .protein:
            return #"protein"#
            
        case .carbohydrate:
            return #"carb.*"#
        case .dietaryFibre:
            return #"(dietary |)fib(re|er)"#
        case .gluten:
            return #"gluten"#
        case .starch:
            return #"starch"#

        case .fat:
            return Regex.fat
        case .saturatedFat:
            return Regex.saturatedFat
        case .monounsaturatedFat:
            return Regex.monounsaturatedFat
        case .polyunsaturatedFat:
            return Regex.polyunsaturatedFat
        case .transFat:
            return Regex.transFat
        case .cholesterol:
            return Regex.cholesterol
            
        case .salt:
            return #"salt"#
        case .sodium:
            return #"sodium"#
        case .sugar:
            return #"sugar"#
        case .calcium:
            return #"calcium"#
        case .iron:
            return #"iron"#
        case .potassium:
            return #"potas"#
            
        case .vitaminA:
            return Regex.vitamin("a")
        case .vitaminC:
            return Regex.vitamin("c")
        case .vitaminD:
            return Regex.vitamin("d")

        default:
            return nil
        }
    }
    
    init?(fromString string: String) {
        var pickedAttribute: Attribute? = nil
        for attribute in Self.allCases {
            guard let regex = attribute.regex else { continue }
            if string.trimmingWhitespaces.matchesRegex(regex) {
                guard pickedAttribute == nil else {
                    /// Fail strings that contain more than one match (since the order shouldn't dictate what we choose)
                    return nil
                }
                pickedAttribute = attribute
            }
        }
        if let pickedAttribute = pickedAttribute {
            self = pickedAttribute
        } else {
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
    
    struct Regex {
        static let fat = #"^(?=^.*fa(t|i).*$)(?!\#(saturatedFat))(?!\#(transFat))(?!\#(polyunsaturatedFat))(?!\#(monounsaturatedFat)).*$"#
        static let saturatedFat = #"^.*(saturated|of which saturates).*$"#
        static let transFat = #"^.*trans.*$"#
        static let monounsaturatedFat = #"^.*mono(-|)unsaturat.*$"#
        static let polyunsaturatedFat = #"^.*poly(-|)unsaturat.*$"#
        static let cholesterol = #"cholesterol"#
        static func vitamin(_ letter: String) -> String {
            #"vit(amin[ ]+|\.[ ]*|[ ]+)\#(letter)"#
        }
    }
}

extension Attribute: Identifiable {
    var id: RawValue { rawValue }
}

extension Attribute {
    static func attributes(in string: String) -> [Attribute] {
        for attribute in Attribute.allCases {
            guard let regex = attribute.regex else { continue }
            if string.matchesRegex(regex) {
                return [attribute]
            }
        }
        return []
    }
}
