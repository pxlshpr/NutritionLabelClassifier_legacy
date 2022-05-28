import Foundation

public enum ColumnHeaderType: Int, CaseIterable {
    case per100g = 1
    case perServing = 1000
}

extension ColumnHeaderType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .per100g:
            return "Per 100g"
        case .perServing:
            return "Per Serving"
        }
    }
}
