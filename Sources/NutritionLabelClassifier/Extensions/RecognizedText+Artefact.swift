import Foundation
import VisionSugar

extension RecognizedText {
    var artefacts: [Artefact] {
        var arrays: [[Artefact]] = []
        for candidate in candidates {
            arrays.append(artefacts(for: candidate))
        }
        
        //MARK: - Heuristics for picking other candidates
        
        /// If the first array is a single value, and has no unit, but one of the next candidates has another single value *with a unit*—pick the first one we encounter
//        if let first = arrays.first, first.count == 1, first.
        
        return arrays.first ?? []
    }
    
    func artefacts(for string: String) -> [Artefact] {
        var array: [Artefact] = []
        var string = string
        while string.count > 0 {
            /// First check if we have a value at the start of the string
            if let valueSubstring = string.valueSubstringAtStart,
               /// If we do, extract it from the string and add its corresponding `Value` to the array
                let value = Value(fromString: valueSubstring) {
                string = string.replacingFirstOccurrence(of: valueSubstring, with: "").trimmingWhitespaces
                
                let artefact = Artefact(value: value, observationId: id)
                array.append(artefact)

            /// Otherwise, get the string component up to and including the next numeral
            } else if let substring = string.substringUpToFirstNumeral {
                /// Check if it matches any prepositions or attributes (currently picks prepositions over attributes for the entire substring)
                if let preposition = Preposition(fromString: substring) {
                    let artefact = Artefact(preposition: preposition, observationId: id)
                    array.append(artefact)
                } else if let attribute = Attribute(fromString: substring) {
                    let artefact = Artefact(attribute: attribute, observationId: id)
                    array.append(artefact)
                }
                string = string.replacingFirstOccurrence(of: substring, with: "").trimmingWhitespaces
            } else {
                break
            }
        }
        return array
    }
}
