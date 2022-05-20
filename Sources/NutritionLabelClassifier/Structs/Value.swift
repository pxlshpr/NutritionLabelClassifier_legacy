import Foundation

struct Value {
    let amount: Double
    let unit: NutritionUnit?
    
    init?(fromString string: String) {
        let groups = string.capturedGroups(using: Regex.fromString, allowCapturingEntireString: true)
        guard groups.count > 1,
              let amount = Double(
                groups[1]
                    .replacingOccurrences(of: ":", with: ".") /// Fix Vision errors of misreading decimal places as ":"
                    .replacingOccurrences(of: ",", with: "") /// Remove comma separators
              )
        else {
            return nil
        }
        self.amount = amount
        if groups.count == 3 {
            guard let unit = NutritionUnit(string: groups[2].lowercased().trimmingWhitespaces) else {
                return nil
            }
            self.unit = unit
        } else {
            self.unit = nil
        }
    }
    
    init(amount: Double, unit: NutritionUnit? = nil) {
        self.amount = amount
        self.unit = unit
    }
    
    struct Regex {
        static let units = NutritionUnit.allUnits.map { "[ ]*\($0)" }.joined(separator: "|")
        static let number = #"[0-9]+[0-9.:,]*"#
        static let atStartOfString = #"^(\#(number)(?:(?:\#(units))|[ ]|$))"#
//        static let atStartOfString = #"^(\#(number)[ ]*(\#(units))?)"#
        static let fromString = #"^(\#(number))(?:(\#(units))|[ ]|$)"#
        
        //TODO: Remove this
        static let standardPattern =
        #"^(?:[^0-9.:]*(?: |\()|^\/?)([0-9.:]+)[ ]*(\#(units))+(?: .*|\).*$|\/?$)$"#
    }
}

extension Value: Equatable {
    static func ==(lhs: Value, rhs: Value) -> Bool {
        lhs.amount == rhs.amount &&
        lhs.unit == rhs.unit
    }
}

extension Value: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(amount)
        hasher.combine(unit)
    }
}

extension Value: CustomStringConvertible {
    var description: String {
        if let unit = unit {
            return "\(amount) \(unit.rawValue)"
        } else {
            return "\(amount)"
        }
    }
}
