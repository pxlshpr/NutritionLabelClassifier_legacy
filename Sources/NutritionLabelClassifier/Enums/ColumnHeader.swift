import Foundation

public enum ColumnHeaderType: Int, CaseIterable {
    case per100g = 1
    case perCustomSize = 1000
}

extension ColumnHeaderType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .per100g:
            return "Per 100g"
        case .perCustomSize:
            return "Per Custom Size"
        }
    }
}
