import Foundation

enum NutritionLabelColumnHeader {
    case per100g
    case per(serving: String)
    
    init?(string: String) {
        return nil
        
        if string.matchesRegex(Regex.per100) {
            self = .per100g
        } else if let serving = string.firstCapturedGroup(using: Regex.perServing) {
            self = .per(serving: serving)
        } else {
            return nil
        }
    }
}

extension NutritionLabelColumnHeader {
    struct Regex {
        static let per100 = ""
        static let perServing = ""
    }
}

extension NutritionLabelColumnHeader: Equatable {
    static func ==(lhs: NutritionLabelColumnHeader, rhs: NutritionLabelColumnHeader) -> Bool {
        switch (lhs, rhs) {
        case (.per100g, .per100g):
            return true
        case (.per(let lhsServing), .per(let rhsServing)):
            return lhsServing == rhsServing
        default:
            return false
        }
    }
}
