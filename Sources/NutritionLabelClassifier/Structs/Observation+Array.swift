import Foundation

extension Array where Element == Observation {
    func printDescription() {
        for i in indices {
            print("[\(i)] → \(self[i].description)")
        }
    }
}

extension Array where Element == Observation {
    var hasTwoColumnsOfValues: Bool {
        for observation in self {
            if observation.valueText2 != nil {
                return true
            }
        }
        return false
    }
    
    var percentageOfNilValue2: Double {
        var numberOfNilValue2s = 0.0
        for observation in self {
            if observation.valueText2 == nil {
                numberOfNilValue2s += 1
            }
        }
        return numberOfNilValue2s / Double(count)
    }
    
    var clearingValue2: [Observation] {
        var observations = self
        for index in observations.indices {
            observations[index].valueText2 = nil
        }
        return observations
    }
}

extension Array where Element == Observation {
    
    func contains(attribute: Attribute) -> Bool {
        contains(where: { $0.attributeText.attribute == attribute })
    }

    func containsConflictingAttribute(to attribute: Attribute) -> Bool {
        for conflictingAttribute in attribute.conflictingAttributes {
            if contains(attribute: conflictingAttribute) {
                return true
            }
        }
        return false
    }

    mutating func appendIfValid(_ observation: Observation) {
        let attribute = observation.attributeText.attribute
        let containsAttribute = contains(attribute: attribute)
        let containsConflictingAttribute = containsConflictingAttribute(to: attribute)
        if !containsAttribute && !containsConflictingAttribute {
            append(observation)
        }
    }
}

extension Array where Element == Observation {
    var containsSeparateValue2Observations: Bool {
        !filterContainingSeparateValue2.isEmpty
    }
    
    /// Filters out observations that contains separate `recognizedText`s for value 1 and 2 (if present)
    var filterContainingSeparateValues: [Observation] {
        filter { $0.valueText1?.textId != $0.valueText2?.textId }
    }
    /// Filters out observations that contains a separate value 1 observation (that is not the same as value 2)
    var filterContainingSeparateValue1: [Observation] {
        filterContainingSeparateValues.filter { $0.valueText1 != nil }
    }
    var filterContainingSeparateValue2: [Observation] {
        filterContainingSeparateValues.filter { $0.valueText2 != nil }
    }
}
