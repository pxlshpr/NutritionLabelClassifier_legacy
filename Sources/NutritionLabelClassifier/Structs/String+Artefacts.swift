import Foundation
import VisionSugar

extension RecognizedText {
    var artefacts: [AnyHashable] {
        string.artefacts
    }
}
extension String {

    var artefacts: [AnyHashable] {

        var array: [AnyHashable] = []
        var string = self

        while string.count > 0 {
            /// First check if we have a value at the start of the string
            if let valueSubstring = string.valueSubstringAtStart,
               /// If we do, extract it from the string and add its corresponding `Value` to the array
                let value = Value(fromString: valueSubstring) {
                string = string.replacingFirstOccurrence(of: valueSubstring, with: "").trimmingWhitespaces
                array.append(value)

            /// Otherwise, get the string component up to and including the next numeral
            } else if let substring = string.substringUpToFirstNumeral {
                /// Check if it matches any prepositions or attributes (currently picks prepositions over attributes for the entire substring)
                if let preposition = Preposition(fromString: substring) {
                    array.append(preposition)
                } else if let attribute = Attribute(fromString: substring) {
                    array.append(attribute)
                }
                string = string.replacingFirstOccurrence(of: substring, with: "").trimmingWhitespaces
            } else {
                break
            }
        }
        return array
    }
    
    //MARK: - Helpers
    var valueSubstringAtStart: String? {
        //TODO: Modularize this and substringUpToFirstNumeral handling not capturing the entire strings with a workaround
        let regex = Value.Regex.atStartOfString
        let groups = trimmingWhitespaces.capturedGroups(using: regex, allowCapturingEntireString: true)
        let substring: String?
        if groups.count > 1 {
            substring = groups[1]
        } else if groups.count == 1 {
            substring = groups[0]
        } else {
            substring = nil
        }
        return substring?.trimmingWhitespaces
    }
    
    var substringUpToFirstNumeral: String? {
        let regex = #"^([0-9]*[^0-9\n]+)[0-9]?.*$"#
        let groups = trimmingWhitespaces.capturedGroups(using: regex, allowCapturingEntireString: true)
        let substring: String?
        if groups.count > 1 {
            substring = groups[1]
        } else if groups.count == 1 {
            substring = groups[0]
        } else {
            substring = nil
        }
        return substring?.trimmingWhitespaces
    }
    
    var trimmingWhitespaces: String {
        trimmingCharacters(in: .whitespaces)
    }
}
