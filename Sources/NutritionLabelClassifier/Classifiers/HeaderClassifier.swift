import Foundation
import VisionSugar

extension Observation {
    init?(headerType: HeaderType, for attribute: Attribute, recognizedText: RecognizedText) {
        guard attribute == .headerType1 || attribute == .headerType2 else {
            return nil
        }
        self.init(
            attributeText: AttributeText(attribute: attribute,
                                         textId: recognizedText.id),
            stringText: StringText(string: headerType.rawValue,
                                   textId: recognizedText.id,
                                   attributeTextId: recognizedText.id)
        )
    }
    
    init?(double: Double, attribute: Attribute, recognizedText: RecognizedText) {
        guard attribute.expectsDouble else { return nil }
        self.init(
            attributeText: AttributeText(attribute: attribute, textId: recognizedText.id),
            doubleText: DoubleText(double: double, textId: recognizedText.id, attributeTextId: recognizedText.id))
    }
    
    init?(unit: NutritionUnit, attribute: Attribute, recognizedText: RecognizedText) {
        guard attribute.expectsNutritionUnit else { return nil }
        self.init(
            attributeText: AttributeText(attribute: attribute, textId: recognizedText.id),
            stringText: StringText(string: unit.description, textId: recognizedText.id, attributeTextId: recognizedText.id))
    }

    init?(string: String, attribute: Attribute, recognizedText: RecognizedText) {
        guard attribute.expectsString else { return nil }
        self.init(
            attributeText: AttributeText(attribute: attribute, textId: recognizedText.id),
            stringText: StringText(string: string, textId: recognizedText.id, attributeTextId: recognizedText.id))
    }
}

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
            //TODO: Try other methods here
            return observations
        }

        /// Get preceding recognized texts in that column
        let _ = extractHeaders(inSameColumnAs: topMostValue1RecognizedText)
        
        /// If we haven't extracted header 2 yet, and are expecting it (by checking if we have any value 2's)
            /// Now look into the first inline text we have that's also in the same column as value 2's

        return observations
    }
    
    func extractHeaders(inSameColumnAs topRecognizedText: RecognizedText) -> (extractedHeader1: Bool, extractedHeader2: Bool) {
        let inlineTextRows = recognizedTexts.inlineTextRows(as: topRecognizedText, preceding: true, ignoring: discarded)
        var extractedHeader1: Bool = false
        var extractedHeader2: Bool = false
        for row in inlineTextRows {
            for recognizedText in row {
                guard let columnHeaderText = ColumnHeaderText(string: recognizedText.string) else {
                    continue
                }
                switch columnHeaderText {
                case .per100g:
                    guard let header1Type = Observation(headerType: .per100g,for: .headerType1, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(header1Type)
//                    observations.append(header1Type)
                    extractedHeader1 = true
                case .perServing:
                    guard let header1Type = Observation(headerType: .perServing,for: .headerType1, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(header1Type)
//                    observations.append(header1Type)
                    extractedHeader1 = true
                case .per100gAndPerServing:
                    guard let header1Type = Observation(headerType: .per100g,for: .headerType1, recognizedText: recognizedText),
                          let header2Type = Observation(headerType: .perServing, for: .headerType2, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(header1Type)
                    observations.appendIfValid(header2Type)
//                    observations.append(header1Type)
//                    observations.append(header2Type)
                    extractedHeader1 = true
                    extractedHeader2 = true
                case .perServingAnd100g:
                    guard let header1Type = Observation(headerType: .per100g,for: .headerType1, recognizedText: recognizedText),
                          let header2Type = Observation(headerType: .perServing, for: .headerType2, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(header1Type)
                    observations.appendIfValid(header2Type)
//                    observations.append(header1Type)
//                    observations.append(header2Type)
                    extractedHeader1 = true
                    extractedHeader2 = true
                }
                
                switch columnHeaderText {
                case .perServing(let string), .per100gAndPerServing(let string), .perServingAnd100g(let string):
                    guard let string = string, let serving = HeaderText.Serving(string: string) else {
                        break
                    }
                    if let amount = serving.amount, let observation = Observation(double: amount, attribute: .headerServingAmount, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
//                        observations.append(observation)
                    }
                    if let unit = serving.unit, let observation = Observation(unit: unit, attribute: .headerServingUnit, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
//                        observations.append(observation)
                    }
                    if let string = serving.unitName, let observation = Observation(string: string, attribute: .headerServingUnitSize, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
//                        observations.append(observation)
                    }
                    guard let equivalentSize = serving.equivalentSize else {
                        break
                    }
                    if let observation = Observation(double: equivalentSize.amount, attribute: .headerServingEquivalentAmount, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
//                        observations.append(observation)
                    }
                    if let unit = equivalentSize.unit, let observation = Observation(unit: unit, attribute: .headerServingEquivalentUnit, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
//                      observations.append(observation)
                    }
                    if let string = equivalentSize.unitName, let observation = Observation(string: string, attribute: .headerServingEquivalentUnitSize, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
//                      observations.append(observation)
                    }
                default:
                    break
                }
                if extractedHeader1 || extractedHeader2 { break }
            }
            if extractedHeader1 || extractedHeader2 { break }
        }
        return (extractedHeader1, extractedHeader2)
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

extension HeaderText.Serving {
    
    init?(string: String) {
        let regex = #"^([^0-9]*)([0-9]+[0-9\/]*)[ ]*([A-z]+)(?:[^0-9]*([0-9]+)[ ]*([A-z]+)|).*$"#
        let groups = string.capturedGroups(using: regex)
        
        if groups.count == 3 {
            /// if we have the first group, this indicates that we got the serving unit without an amount, so assume it to be a `1`
            /// e.g. **serving (125 g)**
            if !groups[0].isEmpty {
                self.init(amount: 1,
                          unitString: groups[0],
                          equivalentSize: EquivalentSize(
                            amountString: groups[1],
                            unitString: groups[2]
                          )
                )
            } else {
                /// 120g
                /// 100ml
                /// 15 ml
                /// 100 ml
                self.init(amountString: groups[1], unitString: groups[2], equivalentSize: nil)
            }
        }
        else if groups.count == 5 {
            /// 74g (2 tubes)
            /// 130g (1 cup)
            /// 125g (1 cup)
            /// 3 balls (36g)
            /// 1/4 cup (30 g)
            self.init(amountString: groups[1],
                      unitString: groups[2],
                      equivalentSize: EquivalentSize(
                        amountString: groups[3],
                        unitString: groups[4]
                      )
            )
        } else {
            return nil
        }
    }
    
    init?(amountString: String, unitString: String, equivalentSize: EquivalentSize?) {
        self.init(amount: Double(fromString: amountString), unitString: unitString, equivalentSize: equivalentSize)
    }
    
    init?(amount: Double?, unitString: String, equivalentSize: EquivalentSize?) {
        self.amount = amount
        let cleaned = unitString.cleanedUnitString
        if let unit = NutritionUnit(string: cleaned) {
            self.unit = unit
            unitName = nil
        } else {
            unit = nil
            unitName = cleaned
        }
        self.equivalentSize = equivalentSize
    }

}

extension String {
    var cleanedUnitString: String {
        let str = hasSuffix(" (") ? replacingOccurrences(of: " (", with: "") : self
        return str.trimmingWhitespaces
    }
}

extension HeaderText.Serving.EquivalentSize {
    
    init?(amountString: String, unitString: String) {
        guard let amount = Double(fromString: amountString) else {
            return nil
        }
        let cleaned = unitString.cleanedUnitString
        self.amount = amount
        if let unit = NutritionUnit(string: cleaned) {
            self.unit = unit
            unitName = nil
        } else {
            unit = nil
            unitName = cleaned
        }
    }
}
