import Foundation
import VisionSugar

extension Array where Element == Observation {
    var containsSeparateValue2Observations: Bool {
        !filterContainingSeparateValue2.isEmpty
    }
    
    /// Filters out observations that contains separate `recognizedText`s for value 1 and 2 (if present)
    var filterContainingSeparateValues: [Observation] {
        filter { $0.valueText1?.textId != $0.valueText2?.textId }
    }
    /// Filters out observations that contains a separate value 1 observation (that is not the same as value 2)
    var filterContainingSeparateValue1: [Observation] {
        filterContainingSeparateValues.filter { $0.valueText1 != nil }
    }
    var filterContainingSeparateValue2: [Observation] {
        filterContainingSeparateValues.filter { $0.valueText2 != nil }
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
        let result = extractHeaders(inSameColumnAs: topMostValue1RecognizedText)
        guard result.extractedHeader1 else {
            //TODO: Try other methods for header 1
            return observations
        }
        
        /// Make sure we haven't extracted header 2 yet before attempting to do it
        guard !result.extractedHeader2 else {
            return observations
        }
        
        /// If we haven't extracted header 2 yet, and are expecting it (by checking if we have any value 2's)
        guard observations.containsSeparateValue2Observations else {
            return observations
        }
        
        guard let topMostValue2RecognizedText = topMostValue2RecognizedText else {
            //TODO: Try first inline text to header1 that's also in the same column as value 2's
            return observations
        }
        
        let _ = extractHeaders(inSameColumnAs: topMostValue2RecognizedText, forHeaderNumber: 2)

        return observations
    }
    
    func extractHeaders(inSameColumnAs topRecognizedText: RecognizedText, forHeaderNumber headerNumber: Int = 1) -> (extractedHeader1: Bool, extractedHeader2: Bool)
    {
        let inlineTextRows = recognizedTexts.inlineTextRows(as: topRecognizedText, preceding: true, ignoring: discarded)
        var extractedHeader1: Bool = false
        var extractedHeader2: Bool = false
        let headerAttribute: Attribute = headerNumber == 1 ? .headerType1 : .headerType2
        
        func extractedFirstHeader() {
            if headerNumber == 1 {
                extractedHeader1 = true
            } else {
                extractedHeader2 = true
            }
        }
        
        for row in inlineTextRows {
            for recognizedText in row {
                guard let columnHeaderText = ColumnHeaderText(string: recognizedText.string) else {
                    continue
                }
                switch columnHeaderText {
                case .per100g:
                    guard let observation = Observation(headerType: .per100g,for: headerAttribute, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(observation)
                    extractedFirstHeader()
                case .perServing:
                    guard let observation = Observation(headerType: .perServing,for: headerAttribute, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(observation)
                    extractedFirstHeader()
                case .per100gAndPerServing:
                    guard let firstObservation = Observation(headerType: .per100g,for: headerAttribute, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(firstObservation)
                    extractedFirstHeader()
                    
                    guard headerNumber == 1, let secondObservation = Observation(headerType: .perServing, for: .headerType2, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(secondObservation)
                    extractedHeader2 = true
                case .perServingAnd100g:
                    guard let firstObservation = Observation(headerType: .per100g,for: headerAttribute, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(firstObservation)
                    extractedFirstHeader()

                    guard headerNumber == 1, let secondObservation = Observation(headerType: .perServing, for: .headerType2, recognizedText: recognizedText) else {
                        continue
                    }
                    observations.appendIfValid(secondObservation)
                    extractedHeader2 = true
                }
                
                switch columnHeaderText {
                case .perServing(let string), .per100gAndPerServing(let string), .perServingAnd100g(let string):
                    guard let string = string, let serving = HeaderText.Serving(string: string) else {
                        break
                    }
                    if let amount = serving.amount, let observation = Observation(double: amount, attribute: .headerServingAmount, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
                    }
                    if let unit = serving.unit, let observation = Observation(unit: unit, attribute: .headerServingUnit, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
                    }
                    if let string = serving.unitName, let observation = Observation(string: string, attribute: .headerServingUnitSize, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
                    }
                    guard let equivalentSize = serving.equivalentSize else {
                        break
                    }
                    if let observation = Observation(double: equivalentSize.amount, attribute: .headerServingEquivalentAmount, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
                    }
                    if let unit = equivalentSize.unit, let observation = Observation(unit: unit, attribute: .headerServingEquivalentUnit, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
                    }
                    if let string = equivalentSize.unitName, let observation = Observation(string: string, attribute: .headerServingEquivalentUnitSize, recognizedText: recognizedText) {
                        observations.appendIfValid(observation)
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
        observations.filterContainingSeparateValue1.compactMap { $0.valueText1?.textId }
    }
    
    var topMostValue2RecognizedText: RecognizedText? {
        value2RecognizedTexts.sorted { $0.rect.minY < $1.rect.minY }.first
    }
    
    var value2RecognizedTexts: [RecognizedText] {
        value2RecognizedTextIds.compactMap { id in
            recognizedTexts.first { $0.id == id }
        }
    }
    
    var value2RecognizedTextIds: [UUID] {
        observations.filterContainingSeparateValue2.compactMap { $0.valueText2?.textId }
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
