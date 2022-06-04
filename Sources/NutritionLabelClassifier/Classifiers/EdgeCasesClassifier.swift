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
        findMissingHeaderType1()
        return observations
    }
    
    /// If we have only one column of values, and haven’t already assigned `.headerType1`, look for the text `Amount Per Serving` and then manually set `.headerType1` as `.perServing` if found.
    func findMissingHeaderType1() {
        guard !observations.hasTwoColumnsOfValues, !observations.contains(attribute: .headerType1) else {
            return
        }
        for recognizedText in recognizedTexts {
            if let headerType = HeaderType(string: recognizedText.string),
               let observation = Observation(headerType: headerType,
                                             for: .headerType1,
                                             recognizedText: recognizedText)
            {
                observations.append(observation)
            }
        }
    }
    
    func findMissedServingAmount() {
        /// If we haven't got a serving amount yet
        guard !observations.contains(attribute: .servingAmount),
              !observations.contains(attribute: .servingUnit),
              !observations.contains(attribute: .headerServingAmount),
              !observations.contains(attribute: .headerServingUnit)
        else {
            return
        }
        
        /// Look for a `Value` within brackets such as `(170g)` (that hasn't been used already) and assign that.
        for recognizedText in recognizedTexts {
            let regex = #"\(([0-9]*)[ ]*g\)"#
//            let regex = #"([0-9]*)[ ]*g"#
            let groups = recognizedText.string.capturedGroups(using: regex)
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
