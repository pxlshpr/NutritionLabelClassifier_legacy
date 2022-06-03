import Foundation

//TODO: Rename this, particularly to remove the `Text` suffix
public enum HeaderString {
    case per100g
    case perServing(serving: String?)
    case per100gAndPerServing(serving: String?)
    case perServingAnd100g(serving: String?)

    init?(string: String) {
        if string.matchesRegex(Regex.per100) {
            self = .per100g
        }
        else if let size = string.firstCapturedGroup(using: Regex.perServingWithSize) {
            self = .perServing(serving: size)
        }
//        else if let size = string.firstCapturedGroup(using: Regex.perServingWithSize2) {
//            self = .perServing(serving: size)
//        }
        else if let size = string.firstCapturedGroup(using: Regex.perServingAndPer100g) {
            self = .perServingAnd100g(serving: size)
        }
        else if let size = string.firstCapturedGroup(using: Regex.per100gAndPerServing) {
            self = .per100gAndPerServing(serving: size)
        }
        else if string.matchesRegex(Regex.perServing) {
            self = .perServing(serving: nil)
        }
        else {
            return nil
        }
    }
}

struct Rx {
    static let fractions = "½⅓¼⅕⅙⅐⅛⅑⅒⅔⅖¾⅗⅜⅘⅚⅞"
    static let numerals = "0-9"
    static let numbers = "\(numerals)\(fractions)"
}
extension HeaderString {
    struct Regex {
        static let per100 = #"^((serve |)per |)100[ ]*g$"#
        static let perServing = #"^(?=^.*(amount|)[ ]*(per |\/)serv(ing|e).*$)(?!^.*100[ ]*g.*$).*$"#
        
        static let perServingWithSize = #"^(?=^.*(?:per )([\#(Rx.numbers)]+.*)$)(?!^.*100[ ]*g.*$).*$"#
        /// Alternative for cases like `⅕ of a pot (100g)`
//        static let perServingWithSize2 = #"^([\#(Rx.numbers)]+)(?: of a|)[ ]*([^\#(Rx.numbers)]+)([\#(Rx.numbers)]+)[ ]?([^\#(Rx.numbers) \)]+)"#
        static let perServingWithSize2 = #"(^[0-9⅕]+(?: of a|)[ ]*[^0-9⅕]+[0-9⅕]+[ ]?[^0-9⅕ \)]+)"#
        
        static let per100gAndPerServing = #"(?:.*per 100[ ]*g[ ])(?:per[ ])?(.*)"#
        static let perServingAndPer100g = #"^.*(?:(?:per|)[ ]+([\#(Rx.numbers)]+g).*per 100[ ]*g).*$"#
        
        /// Deprecated patterns
//        static let per100 = #"^(per |)100[ ]*g$"#
//        static let perServingWithSize = #"^(?=^.*(?:per |serving size[:]* )([0-9]+.*)$)(?!^.*100[ ]*g.*$).*$"#
   }
}

extension HeaderString: Equatable {
    public static func ==(lhs: HeaderString, rhs: HeaderString) -> Bool {
        switch (lhs, rhs) {
        case (.per100g, .per100g):
            return true
        case (.perServing(let lhsServing), .perServing(let rhsServing)):
            return lhsServing == rhsServing
        case (.per100gAndPerServing(let lhsServing), .per100gAndPerServing(let rhsServing)):
            return lhsServing == rhsServing
        case (.perServingAnd100g(let lhsServing), .perServingAnd100g(let rhsServing)):
            return lhsServing == rhsServing
        default:
            return false
        }
    }
}
