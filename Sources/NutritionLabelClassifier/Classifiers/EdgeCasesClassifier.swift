import Foundation
import VisionSugar

class EdgeCasesClassifier: Classifier {
    let recognizedTexts: [RecognizedText]
    var observations: [Observation]

    var pendingObservations: [Observation] = []
    var observationBeingExtracted: Observation? = nil
    var discarded: [RecognizedText] = []

    init(recognizedTexts: [RecognizedText], observations: [Observation]) {
        self.recognizedTexts = recognizedTexts
        self.observations = observations
    }
    
    static func observations(from recognizedTexts: [RecognizedText], priorObservations observations: [Observation]) -> [Observation] {
        EdgeCasesClassifier(recognizedTexts: recognizedTexts, observations: observations)
            .getObservations()
    }
    
    func getObservations() -> [Observation] {
        findMissedServingAmount()
        return observations
    }
    
    func findMissedServingAmount() {
        /// If we haven't got a serving amount yet
        guard !observations.contains(attribute: .servingAmount),
              !observations.contains(attribute: .servingUnit) else {
            return
        }
        
        /// Look for a `Value` within brackets such as `(170g)` (that hasn't been used already) and assign that.
        for recognizedText in recognizedTexts {
            let groups = recognizedText.string.capturedGroups(using: #"\(([0-9]*)[ ]*g\)"#)
            if groups.count == 2,
               let amount = Double(groups[1]),
               let amountObservation = Observation(
                    double: amount,
                    attribute: .servingAmount,
                    recognizedText: recognizedText
               ),
               let unitObservation = Observation(
                    unit: .g,
                    attribute: .servingUnit,
                    recognizedText: recognizedText
               )
            {
                observations.append(amountObservation)
                observations.append(unitObservation)
            }
        }
    }
}
