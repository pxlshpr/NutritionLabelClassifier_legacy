import Foundation

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
