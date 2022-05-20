import Foundation

enum Preposition: String, CaseIterable {
    case per
    case includes
    
    var regex: String {
        switch self {
        case .per:
            return #"(^| )per( |$)"#
        case .includes:
            return #"(^| )include(s|)( |$)"#
        }
    }
    
    init?(fromString string: String) {
        for preposition in Self.allCases {
            if string.trimmingWhitespaces.matchesRegex(preposition.regex) {
                self = preposition
                return
            }
        }
        return nil
    }
}

extension Preposition: Identifiable {
    var id: RawValue { rawValue }
}
