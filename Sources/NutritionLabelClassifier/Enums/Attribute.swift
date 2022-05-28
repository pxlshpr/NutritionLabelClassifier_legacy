import Foundation

public enum Attribute: String, CaseIterable {
    
    case nutritionFacts
    
    case servingAmount                 /// Double
    case servingUnit                  /// NutritionUnit
    case servingUnitSize              /// String
    case servingEquivalentAmount       /// Double
    case servingEquivalentUnit        /// NutritionUnit
    case servingEquivalentUnitSize    /// String
    
    public var isColumnAttribute: Bool {
        switch self {
        case .nutrientsColumnHeader1, .nutrientsColumnHeader2:
            return true
        default:
            return false
        }
    }
    public var isServingAttribute: Bool {
        switch self {
        case .servingAmount, .servingUnit, .servingUnitSize, .servingEquivalentAmount, .servingEquivalentUnit, .servingEquivalentUnitSize, .servingsPerContainerName, .servingsPerContainerAmount:
            return true
        default:
            return false
        }
    }
    
    public var expectsDouble: Bool {
        switch self {
        case .servingAmount, .servingEquivalentAmount, .servingsPerContainerAmount:
            return true
        default:
            return false
        }
    }
    
    public var expectsNutritionUnit: Bool {
        switch self {
        case .servingUnit, .servingEquivalentUnit:
            return true
        default:
            return false
        }
    }
    
    public var expectsString: Bool {
        switch self {
        case .servingUnitSize, .servingEquivalentUnitSize, .servingsPerContainerName:
            return true
        default:
            return false
        }
    }
    
    public var isIrrelevant: Bool {
        switch self {
        case .nutritionFacts:
            return true
        default:
            return false
        }
    }
    
    public var isNutrientAttribute: Bool {
        !isColumnAttribute && !isServingAttribute && !isIrrelevant
    }

//    case servingSizeVolume
//    case servingSizeWeight
//    case servingSizeDescriptive
    
    case servingsPerContainerAmount
    case servingsPerContainerName

    /// String where `100g` indicates Per 100 g, Otherwise
    case nutrientsColumnHeader1
    case nutrientsColumnHeader2

    //MARK: Nutrients
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
    
    var defaultUnit: NutritionUnit? {
        supportedUnits.first
    }
    
    var supportsMultipleColumns: Bool {
        switch self {
        case .servingsPerContainerAmount, .servingsPerContainerName:
            return false
        default:
            return true
        }
    }
    
    /// For values like `servingsPerContainerAmount` and `addedSugar` which allows extracting preceding values like the following:
    /// `40 Servings Per Container`
    /// `Includes 4g Added Sugar`
    var supportsPrecedingValue: Bool {
        switch self {
        case .servingsPerContainerAmount, .servingsPerContainerName:
            return true
        default:
            return false
        }
    }
    
    var isNutrient: Bool {
        switch self {
        case .servingsPerContainerAmount, .servingsPerContainerName:
            return false
        default:
            return true
        }
    }
    
    var supportedUnits: [NutritionUnit] {
        switch self {
        case .energy:
            return [ .kj, .kcal]
        case .protein, .carbohydrate, .fat, .salt:
            return [.g]
        case .dietaryFibre, .saturatedFat, .polyunsaturatedFat, .monounsaturatedFat, .transFat, .cholesterol, .sugar, .gluten, .starch:
            return [.g, .mg, .mcg]
        case .sodium, .calcium, .iron, .potassium, .vitaminA, .vitaminC, .vitaminD:
            return [.mg, .mcg, .p, .g]
//        case .servingSizeVolume:
//        case .servingSizeWeight:
//        case .servingSizeDescriptive:
//        case .servingsPerContainerAmount:
        default:
            return []
        }
    }
    
    var regex: String? {
        switch self {
        case .servingsPerContainerAmount, .servingsPerContainerName:
            return #"(servings |)per (container|package|tub|pot)"#
        case .nutritionFacts:
            return #"Nutrition Facts"#
        case .energy:
            return #"^.*(energy|calories|energie).*$"#
            
        case .protein:
            return #"(protein|proteine)"#
            
        case .carbohydrate:
            return #"(carb|glucides).*"#
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
            return #"(salt|salz|sel)"#
        case .sodium:
            return #"sodium"#
        case .sugar:
            return #"(sugar|sucres|zucker|zuccheri)"#
        case .calcium:
            return #"calcium"#
        case .iron:
            return #"(^| )iron"#
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
    
    var supportsUnitLessValues: Bool {
        switch self {
        case .servingsPerContainerAmount, .servingsPerContainerName:
            return true
        default:
            return false
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
        case .servingAmount, .servingUnit, .servingUnitSize, .servingEquivalentAmount, .servingEquivalentUnit, .servingEquivalentUnitSize, .servingsPerContainerAmount, .servingsPerContainerName:
            return false
        default:
            return true
        }
    }
    
    struct Regex {
        static let fat = #"^(?=^.*(fa(t|i)|fett|grassi).*$)(?!\#(saturatedFat))(?!\#(transFat))(?!\#(polyunsaturatedFat))(?!\#(monounsaturatedFat)).*$"#
        static let saturatedFat = #"^.*(saturated|of which saturates|saturi).*$"#
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
    public var id: RawValue { rawValue }
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


extension Attribute: CustomStringConvertible {
    public var description: String {
        switch self {
        case .nutritionFacts:
            return "Nutrition Facts"
        case .servingAmount:
            return "Serving Amount"
        case .servingUnit:
            return "Serving Unit"
        case .servingUnitSize:
            return "Serving Unit Size"
        case .servingEquivalentAmount:
            return "Serving Equivalent Amount"
        case .servingEquivalentUnit:
            return "Serving Equivalent Unit"
        case .servingEquivalentUnitSize:
            return "Serving Equivalent Unit Size"
        case .servingsPerContainerAmount:
            return "Servings Per Container Amount"
        case .servingsPerContainerName:
            return "Servings Per Container Name"
        case .nutrientsColumnHeader1:
            return "Column Header 1"
        case .nutrientsColumnHeader2:
            return "Column Header 2"
        case .energy:
            return "Energy"
        case .protein:
            return "Protein"
        case .carbohydrate:
            return "Carbohydrate"
        case .dietaryFibre:
            return "Dietary Fibre"
        case .gluten:
            return "Gluten"
        case .sugar:
            return "Sugar"
        case .starch:
            return "Starch"
        case .fat:
            return "Fat"
        case .saturatedFat:
            return "Saturated Fat"
        case .polyunsaturatedFat:
            return "Polyunsaturated Fat"
        case .monounsaturatedFat:
            return "Monounsaturated Fat"
        case .transFat:
            return "Trans Fat"
        case .cholesterol:
            return "Cholesterol"
        case .salt:
            return "Salt"
        case .sodium:
            return "Sodium"
        case .calcium:
            return "Calcium"
        case .iron:
            return "Iron"
        case .potassium:
            return "Potassium"
        case .vitaminA:
            return "Vitamin A"
        case .vitaminC:
            return "Vitamin C"
        case .vitaminD:
            return "Vitamin D"
        }
    }
}
