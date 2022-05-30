import VisionSugar

class ServingClassifier {
    
    let recognizedTexts: [RecognizedText]
    var observations: [Observation]

    var discarded: [RecognizedText] = []

    init(recognizedTexts: [RecognizedText], observations: [Observation]) {
        self.recognizedTexts = recognizedTexts
        self.observations = observations
    }
    
    static func classify(_ recognizedTexts: [RecognizedText], into observations: [Observation]) -> [Observation] {
        ServingClassifier(recognizedTexts: recognizedTexts, observations: observations).getObservations()
    }

    //MARK: - Helpers
    func getObservations() -> [Observation] {
        for recognizedText in recognizedTexts {
            guard recognizedText.string.containsServingAttribute else {
                continue
            }
            print("🥄 Processing: \(recognizedText)")
        }
        return observations
    }
}
