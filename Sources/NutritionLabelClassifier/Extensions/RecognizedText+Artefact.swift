import Foundation
import VisionSugar

extension RecognizedText {
    var artefacts: [Artefact] {
        getArtefacts()
    }
    
    func getArtefacts(for attribute: Attribute? = nil, rowBeingExtracted: Row? = nil, extractedRows: [Row] = []) -> [Artefact] {
        var arrays: [[Artefact]] = []
        for candidate in candidates {
            arrays.append(artefacts(for: candidate))
        }
        
        if let selection = heuristicSelectionOfValueWithUnit(from: arrays) {
            return selection
        }
        
        if let selection = heuristicSelectionOfValidValueForChildAttribute(from: arrays, for: attribute, rowBeingExtracted: rowBeingExtracted, extractedRows: extractedRows) {
            return selection
        }
        
        /// Default is to always return the first array if none of the heuristics picked another candidate
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

//MARK: - Heuristic Selections
extension RecognizedText {
    
    /** If the first array is a single value, and has no unit, but one of the next candidates has another single value *with a unit*—pick the first one we encounter
     */
    func heuristicSelectionOfValueWithUnit(from arrays: [[Artefact]]) -> [Artefact]? {
        guard arrays.count > 1 else { return nil }
        guard arrays.first?.count == 1, let value = arrays.first?.first?.value, value.unit == nil else {
            return nil
        }
        for array in arrays.dropFirst() {
            if array.count == 1, let value = array.first?.value, value.unit != nil {
                return array
            }
        }
        return nil
    }
    
    /** Filters out the `Value`s containing `Unit`s, and if we have multiple of them *and* the attribute we're getting (if provided) is a child element of another attribute (ie. its value should be less than its), *and* we also have extracted the parent attribute earlier—we will choose the first value that is less than or equal to the parents value.
     
        For example: if VisionKit misreads `1.4g` as `11.4g` for `.saturatedFat`, and submits both strings as candidates, and we happen to have `.fat` set as `2.2g`—we would choose `1.4g` over `11.4g`
     */
    func heuristicSelectionOfValidValueForChildAttribute(from arrays: [[Artefact]], for attribute: Attribute? = nil, rowBeingExtracted: Row? = nil, extractedRows: [Row] = []) -> [Artefact]?
    {
        guard arrays.count > 1 else { return nil }
        
        /// Make sure we have an attribute provided, and that it does have a parent attribute for which we have already extracted a row first.
        guard let attribute = attribute,
              let parentAttribute = attribute.parentAttribute,
              let parentRow = extractedRows.first(where: { $0.attribute == parentAttribute })
        else {
            return nil
        }
        
        /// Grab the respective `Value` of the parent `Row` based on what we're currently grabbing (as comparisons across rows make no sense).
        let parentValue: Value?
        if rowBeingExtracted?.value1 != nil {
            parentValue = parentRow.value2
        } else {
            parentValue = parentRow.value1
        }
        guard let parentValue = parentValue else { return nil }

        /// Now filter out all the single unit-based value artefact arrays
        let artefactsOfSingleValuesWithUnits = arrays.filter {
            $0.count == 1
//            && $0.first?.value?.unit != nil
            && $0.first?.value?.unit == parentValue.unit
        }
        
        /// Make sure we have at least 2 to pick from before proceeding
        guard artefactsOfSingleValuesWithUnits.count > 1 else { return nil }
        
        /// Now go through each in order, and pick the first that is less than or equal to its parents amount
        /// **This should filter out any erraneously recognized values that are greater than the parent's**
        for array in artefactsOfSingleValuesWithUnits {
            if let amount = array.first?.value?.amount,
               amount <= parentValue.amount {
                return array
            }
        }
        
        return nil
    }
}
