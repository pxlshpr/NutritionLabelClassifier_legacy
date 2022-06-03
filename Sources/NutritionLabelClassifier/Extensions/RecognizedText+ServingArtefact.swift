import VisionSugar
import Foundation

extension Double {
    init?(fromString string: String) {

        var string = string
            .replacingOccurrences(of: ":", with: ".") /// Fix Vision errors of misreading decimal places as `:`
        
        if string.matchesRegex(NumberRegex.usingCommaAsDecimalPlace) {
            string = string.replacingOccurrences(of: ",", with: ".")
        } else {
            /// It's been used as a thousand separator in that case
            string = string.replacingOccurrences(of: ",", with: "")
        }
        
        let groups = string.capturedGroups(using: NumberRegex.isFraction)
        if groups.count == 2,
            let numerator = Double(groups[0]),
            let denominator = Double(groups[1]),
            denominator != 0
        {
            self = numerator/denominator
            return
        }
        
        guard let amount = Double(string) else {
            return nil
        }
        self = amount
    }
}
extension RecognizedText {
    var servingArtefacts: [ServingArtefact] {
        getServingArtefacts()
    }
    
    func getServingArtefacts(for attribute: Attribute? = nil, observationBeingExtracted: Observation? = nil, extractedObservations: [Observation] = []) -> [ServingArtefact] {
        var arrays: [[ServingArtefact]] = []
        for candidate in candidates {
            arrays.append(servingArtefacts(for: candidate))
        }
        
        /// Run heuristics if needed to select a candidate when we have multiple candidates of the recognized text
        
        /// Default is to always return the first array if none of the heuristics picked another candidate
        return arrays.first(where: { $0.count > 0 }) ?? []
    }
    
    func servingArtefacts(for string: String) -> [ServingArtefact] {
//        let originalString = string.cleanedAttributeString
        var array: [ServingArtefact] = []
        var string = string.cleanedAttributeString
        while string.count > 0 {
            /// First check if we have a number at the start of the string
            if let numberSubstring = string.numberSubstringAtStart,
               let double = Double(fromString: numberSubstring)
            {
                string = string.replacingFirstOccurrence(of: numberSubstring, with: "").trimmingWhitespaces

                let artefact = ServingArtefact(double: double, textId: id)
                array.append(artefact)
            }
            /// Otherwise if we have a unit at the start of the string
            else if let unitSubstring = string.unitSubstringAtStart,
                    let unit = NutritionUnit(string: unitSubstring)
            {
                string = string.replacingFirstOccurrence(of: unitSubstring, with: "").trimmingWhitespaces
                
                let artefact = ServingArtefact(unit: unit, textId: id)
                array.append(artefact)
            }
            /// Finally get the next substring up to the first numeral
            else if let substring = string.substringUpToFirstNumeral
            {
                /// If it matches an attribute, create an artefact from it
//                if let attributeSubstring = string.servingAttributeSubstringAtStart,
//                   let attribute = Attribute(fromString: attributeSubstring)
                if let attribute = Attribute(fromString: substring)
                {
                    /// **Heuristic** If this is the `.servingsPerContainerAmount`, also try and grab the `.servingsPerContainerName` from the substring, and add that as an artefact before proceeding
                    if attribute == .servingsPerContainerAmount,
                       let containerName = string.servingsPerContainerName
                    {
                        array.append(ServingArtefact(attribute: .servingsPerContainerName, textId: id))
                        array.append(ServingArtefact(string: containerName, textId: id))
                    }

                    let artefact = ServingArtefact(attribute: attribute, textId: id)
                    array.append(artefact)
                    
//                    string = string.replacingFirstOccurrence(of: attributeSubstring, with: "").trimmingWhitespaces
                    string = string.replacingFirstOccurrence(of: substring, with: "").trimmingWhitespaces
                }
                /// Otherwise, if the substring contains letters, add it as a string attribute
                else if substring.containsWords
                {
                    let artefact = ServingArtefact(string: substring, textId: id)
                    array.append(artefact)
                    string = string.replacingFirstOccurrence(of: substring, with: "").trimmingWhitespaces
                }
                /// Finally, we'll be ignoring any joining symbols
                else {
                    string = string.replacingFirstOccurrence(of: substring, with: "").trimmingWhitespaces
                }
            } else {
                break
            }
        }
        return array
    }
}
