import Foundation
import VisionSugar

class HeaderClassifier: Classifier {
    
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
        HeaderClassifier(recognizedTexts: recognizedTexts, observations: observations).getObservations()
    }

    func getObservations() -> [Observation] {
        /// Get top-most value1 recognized text
        guard let topMostValue1RecognizedText = topMostValue1RecognizedText else {
            print("⭐️ Couldn't get topMostValue1RecognizedText")
            //TODO: Try other methods here
            return observations
        }
        print("⭐️ Top-most value1 is: \(topMostValue1RecognizedText.string)")

        /// Get preceding recognized texts in that column
        let inlineTextRows = recognizedTexts.inlineTextRows(as: topMostValue1RecognizedText, preceding: true, ignoring: discarded)
        for row in inlineTextRows {
            print(row.map { $0.string })
            for recognizedText in row {
                guard let columnHeaderText = ColumnHeaderText(string: recognizedText.string) else {
                    continue
                }
                switch columnHeaderText {
                case .per100g:
                    fatalError("TODO per100g")
                case .perServing(let serving):
                    fatalError("TODO perServing: \(serving ?? "")")
                case .per100gAndPerServing(let serving):
                    let header1Type = Observation(
                        attributeText: AttributeText(attribute: .headerType1,
                                                     textId: recognizedText.id),
                        stringText: StringText(string: HeaderType.per100g.rawValue,
                                               textId: recognizedText.id,
                                               attributeTextId: recognizedText.id)
                    )
                    observations.append(header1Type)
                    
                    let header2Type = Observation(
                        attributeText: AttributeText(attribute: .headerType2,
                                                     textId: recognizedText.id),
                        stringText: StringText(string: HeaderType.perServing.rawValue,
                                               textId: recognizedText.id,
                                               attributeTextId: recognizedText.id)
                    )
                    observations.append(header2Type)
                case .perServingAnd100g(let serving):
                    fatalError("TODO perServingAnd100g: \(serving ?? "")")
                }
            }
        }
        
        /// If we haven't extracted header 2 yet, and are expecting it (by checking if we have any value 2's)
            /// Now look into the first inline text we have that's also in the same column as value 2's

        return observations
    }
    
    var topMostValue1RecognizedText: RecognizedText? {
        value1RecognizedTexts.sorted { $0.rect.minY < $1.rect.minY }.first
    }
    
    var value1RecognizedTexts: [RecognizedText] {
        value1RecognizedTextIds.compactMap { id in
            recognizedTexts.first { $0.id == id }
        }
    }
    
    var value1RecognizedTextIds: [UUID] {
        observations.compactMap { $0.valueText1?.textId }
    }
}
