import Foundation

extension String {
    var trimmingPercentageValues: String {
        let regex = #"([0-9]*[ ]*%)"#
        
        var trimmedString = self
        while true {
            let groups = trimmedString.capturedGroups(using: regex)
            guard let percentageSubstring = groups.first else {
                break
            }
            
            trimmedString = trimmedString.replacingOccurrences(of: percentageSubstring, with: "")
        }
        return trimmedString
    }
    
    var hasBothKjAndKcal: Bool {
        let regex = #"^.*[0-9]+[ ]*kj.*[0-9]+[ ]*kcal.*$|^.*[0-9]+[ ]*kcal.*[0-9]+[ ]*kj.*$"#
        return self.matchesRegex(regex)
    }
}

struct NutritionLabelValue {
    let amount: Double
    let unit: NutritionLabelUnit?
    
    init?(string: String) {
        
        /// First trim out any percentage-signed valued
        var string = string.trimmingPercentageValues
        
        /// Next, invalidate anything that has "per 100g" in it
        if string.matchesRegex(#"per 100[ ]*g"#) {
            return nil
        }
        
        /// If the string contains both 'kj' and 'kcal', extract and remove the kcal-based value (since its smaller)
        if string.hasBothKjAndKcal {
            let kcalSubstringRegex = #"([0-9]+[ ]*kcal)"#
            let groups = string.capturedGroups(using: kcalSubstringRegex)
            if let kcalSubstring = groups.first {
                string = string.replacingOccurrences(of: kcalSubstring, with: "")
            }
        }
        
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
            
            /// invalidate extra large 'g' values to account for serving size being misread into value lines sometimes
            if unit == .g, amount > 100 {
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
        static let standardPattern =
        #"^(?:[^0-9.:]*(?: |\()|^\/?)([0-9.:]+)[ ]*(\#(units))+(?: .*|\).*$|\/?$)$"#
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
