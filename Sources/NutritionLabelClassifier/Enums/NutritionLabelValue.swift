import Foundation

struct NutritionLabelValue {
    let amount: Double
    let unit: NutritionLabelUnit?
    
    init?(string: String) {
        let groups = string.capturedGroups(using: Regex.pattern, allowCapturingEntireString: true)
        guard groups.count > 1, let amount = Double(groups[1]) else {
            return nil
        }
        self.amount = amount
        if groups.count == 3 {
            guard let unit = NutritionLabelUnit(rawValue: groups[2]) else {
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
        static let pattern = #"^([0-9.]+)[ ]*(g|mg|mcg)*$"#
    }
}

extension NutritionLabelValue: Equatable {
    static func ==(lhs: NutritionLabelValue, rhs: NutritionLabelValue) -> Bool {
        lhs.amount == rhs.amount &&
        lhs.unit == rhs.unit
    }
}

enum NutritionLabelUnit: String {
    case g
    case mg
    case mcg
}
