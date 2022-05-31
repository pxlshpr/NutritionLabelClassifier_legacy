import Foundation

public enum HeaderType: String, CaseIterable {
    case per100g
    case perServing
}

extension HeaderType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .per100g:
            return "Per 100g"
        case .perServing:
            return "Per Serving"
        }
    }
    
    public var stringFieldName: String {
        switch self {
        case .perServing:
            return "Serving"
        default:
            return ""
        }
    }
}
