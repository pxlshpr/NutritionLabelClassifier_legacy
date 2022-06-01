import Foundation
import VisionSugar

class HeaderClassifier {
    
    let recognizedTexts: [RecognizedText]
    var observations: [Observation]

    var pendingObservations: [Observation] = []
    var observationBeingExtracted: Observation? = nil
    var discarded: [RecognizedText] = []

    init(recognizedTexts: [RecognizedText], observations: [Observation]) {
        self.recognizedTexts = recognizedTexts
        self.observations = observations
    }
    
    static func classify(_ recognizedTexts: [RecognizedText], into observations: [Observation]) -> [Observation] {
        ServingClassifier(recognizedTexts: recognizedTexts, observations: observations).getObservations()
    }

    func getObservations() -> [Observation] {
        for recognizedText in recognizedTexts {
        }
        return observations
    }
}

protocol Classifier

