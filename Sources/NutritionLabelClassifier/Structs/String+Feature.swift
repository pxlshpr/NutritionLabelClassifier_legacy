import Foundation

extension String {

    var features: [Feature] {
        var features: [Feature] = []
        
        let array = artefacts
        
        // Set the currentAttribute we're grabbing as nil
        var currentAttribute: Attribute? = nil
        
        // For each e
        for e in array {
            if let attribute = e as? Attribute {
                currentAttribute = attribute
            } else if let value = e as? Value {
                guard let attribute = currentAttribute else {
                    continue
                }
                if let unit = value.unit {
                    guard attribute.supportsUnit(unit) else {
                        continue
                    }
                }
                features.append(Feature(attribute: attribute, value: value))
            }
        }
        // If e is a value
            // If we have an attribute we're grabbing
                // Create a feature with the currentAttribute and value
                // Add it to the array
            // Else
                // Discard this value by continuing
        // Else if e is an attribute
            // Set the currentAttribute to it
        
        return features
    }
}

