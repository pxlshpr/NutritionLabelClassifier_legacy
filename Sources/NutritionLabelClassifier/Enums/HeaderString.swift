import Foundation

//TODO: Rename this, particularly to remove the `Text` suffix
public enum HeaderString {
    case per100
    case perServing(serving: String?)
    case per100AndPerServing(serving: String?)
    case perServingAnd100(serving: String?)

    init?(string: String) {
        if string.matchesRegex(Regex.per100) {
            self = .per100
        }
        else if let size = string.firstCapturedGroup(using: Regex.perServingWithSize) {
            self = .perServing(serving: size)
        }
//        else if let size = string.firstCapturedGroup(using: Regex.perServingWithSize2) {
//            self = .perServing(serving: size)
//        }
        else if let size = string.firstCapturedGroup(using: Regex.perServingAndPer100g) {
            self = .perServingAnd100(serving: size)
        }
        else if let size = string.firstCapturedGroup(using: Regex.per100gAndPerServing) {
            self = .per100AndPerServing(serving: size)
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
        static let per100 = #"^((serve |)per |)100[ ]*(?:g|ml)$"#
        static let perServing = #"^(?=^.*(amount|)[ ]*(per |\/)serv(ing|e).*$)(?!^.*100[ ]*(?:g|ml).*$).*$"#
        
        static let perServingWithSize = #"^(?=^.*(?:per )([\#(Rx.numbers)]+.*)$)(?!^.*100[ ]*(?:g|ml).*$).*$"#
        /// Alternative for cases like `⅕ of a pot (100g)`
        static let perServingWithSize2 = #"(^[0-9⅕]+(?: of a|)[ ]*[^0-9⅕]+[0-9⅕]+[ ]?[^0-9⅕ \)]+)"#
        
        static let per100gAndPerServing = #"(?:.*per 100[ ]*(?:g|ml)[ ])(?:per[ ])?(.*)"#
        static let perServingAndPer100g = #"^.*(?:(?:per|)[ ]+([\#(Rx.numbers)]+(?:g|ml)).*per 100[ ]*(?:g|ml)).*$"#
        
        /// Deprecated patterns
//        static let per100 = #"^(per |)100[ ]*g$"#
//        static let perServingWithSize = #"^(?=^.*(?:per |serving size[:]* )([0-9]+.*)$)(?!^.*100[ ]*g.*$).*$"#
        //        static let perServingWithSize2 = #"^([\#(Rx.numbers)]+)(?: of a|)[ ]*([^\#(Rx.numbers)]+)([\#(Rx.numbers)]+)[ ]?([^\#(Rx.numbers) \)]+)"#

   }
}

extension HeaderString: Equatable {
    public static func ==(lhs: HeaderString, rhs: HeaderString) -> Bool {
        switch (lhs, rhs) {
        case (.per100, .per100):
            return true
        case (.perServing(let lhsServing), .perServing(let rhsServing)):
            return lhsServing == rhsServing
        case (.per100AndPerServing(let lhsServing), .per100AndPerServing(let rhsServing)):
            return lhsServing == rhsServing
        case (.perServingAnd100(let lhsServing), .perServingAnd100(let rhsServing)):
            return lhsServing == rhsServing
        default:
            return false
        }
    }
}
