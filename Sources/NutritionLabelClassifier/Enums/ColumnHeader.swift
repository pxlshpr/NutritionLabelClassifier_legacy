import Foundation

public enum HeaderType: Int, CaseIterable {
    case per100g = 1
    case perServing = 1000
    case perCustomSize = 2000
}

extension HeaderType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .per100g:
            return "Per 100g"
        case .perServing:
            return "Per Serving"
        case .perCustomSize:
            return "Per Custom Size"
        }
    }
    
    public var stringFieldName: String {
        switch self {
        case .perServing:
            return "Serving"
        case .perCustomSize:
            return "Custom Size"
        default:
            return ""
        }
    }
}
