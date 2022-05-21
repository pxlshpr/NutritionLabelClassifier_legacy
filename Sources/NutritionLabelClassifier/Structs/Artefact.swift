import Foundation

public struct Artefact {
    let observationId: UUID
    let attribute: Attribute?
    let value: Value?
    
    init(attribute: Attribute, observationId: UUID) {
        self.observationId = observationId
        self.attribute = attribute
        self.value = nil
    }
    
    init(value: Value, observationId: UUID) {
        self.observationId = observationId
        self.value = value
        self.attribute = nil
    }
}
