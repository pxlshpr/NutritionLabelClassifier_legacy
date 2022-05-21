import Foundation

public struct Artefact {
    let observationId: UUID
    let attribute: Attribute?
    let value: Value?
    let preposition: Preposition?
    
    init(attribute: Attribute, observationId: UUID) {
        self.observationId = observationId
        self.attribute = attribute
        self.value = nil
        self.preposition = nil
    }
    
    init(value: Value, observationId: UUID) {
        self.observationId = observationId
        self.value = value
        self.attribute = nil
        self.preposition = nil
    }
    
    init(preposition: Preposition, observationId: UUID) {
        self.observationId = observationId
        self.preposition = preposition
        self.value = nil
        self.attribute = nil
    }
}

extension Artefact: Equatable {
    public static func ==(lhs: Artefact, rhs: Artefact) -> Bool {
        lhs.observationId == rhs.observationId
        && lhs.attribute == rhs.attribute
        && lhs.value == rhs.value
        && lhs.preposition == rhs.preposition
    }
}
