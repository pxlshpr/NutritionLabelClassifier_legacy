import Foundation

enum NutritionUnit: String, CaseIterable {
    case g
    case mg //TODO: Recognize `mq` as a typo
    case kj
    case mcg //TODO: Recognize `ug` as an alternative and remove it
    case kcal
    case p = "%" /// percent
    
    init?(string: String) {
        for unit in Self.allCases {
            if unit.possibleUnits.contains(string) {
                self = unit
                return
            }
        }
        return nil
    }
    
    var regex: String? {
        switch self {
        case .g:
            return "^g$"
        case .mg:
            return "^(mg|mq)$"
        case .kj:
            return "^kj$"
        case .mcg:
            return "^(ug|mcg)$"
        case .kcal:
            return "^(k|)cal$"
        case .p:
            return "^%$"
        }
    }
    
    var possibleUnits: [String] {
        switch self {
        case .g:
            return ["g"]
        case .mg:
            return ["mg", "mq"]
        case .kj:
            return ["kj", "kilojules"]
        case .mcg:
            return ["mcg", "ug"]
        case .kcal:
            return ["kcal", "cal"]
        case .p:
            return ["%"]
        }
    }
    
    static var allUnits: [String] {
        var allUnits: [String] = []
        for unit in allCases {
            allUnits.append(contentsOf: unit.possibleUnits)
        }
        return allUnits
    }
    
    static var allUnitsRegexOptions = allUnits.joined(separator: "|")
}
