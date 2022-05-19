import Foundation

struct NutritionLabelValue {
    let amount: Double
    let unit: NutritionLabelUnit?
    
    init?(string: String) {
        let groups = string.capturedGroups(using: Regex.standardPattern, allowCapturingEntireString: true)
        guard groups.count > 1,
              let amount = Double(groups[1].replacingOccurrences(of: ":", with: "."))
        else {
            return nil
        }
        self.amount = amount
        if groups.count == 3 {
            guard let unit = NutritionLabelUnit(rawValue: groups[2].lowercased()) else {
                return nil
            }
            self.unit = unit
        } else {
            self.unit = nil
        }
    }
    
    init(amount: Double, unit: NutritionLabelUnit? = nil) {
        self.amount = amount
        self.unit = unit
    }
    
    struct Regex {
        static let units = NutritionLabelUnit.allCases.map { $0.rawValue }.joined(separator: "|")
//        static let standardPattern = #"^(?:[^0-9.:]* |\(|^)([0-9.:]+)[ ]*(\#(units))*$"#
        static let standardPattern = #"^(?:[^0-9.:]*(?: |\()|^)([0-9.:]+)[ ]*(\#(units))+(?: .*|\)?$)$"#
    }
}

extension NutritionLabelValue: Equatable {
    static func ==(lhs: NutritionLabelValue, rhs: NutritionLabelValue) -> Bool {
        lhs.amount == rhs.amount &&
        lhs.unit == rhs.unit
    }
}

enum NutritionLabelUnit: String, CaseIterable {
    case g
    case ug /// alternative symbol for mcg
    case mg
    case kj
    case mcg
    case kcal
}
