import Foundation

public enum HeaderType: Int, CaseIterable {
    case per100g = 1
    case perServing = 1000
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
