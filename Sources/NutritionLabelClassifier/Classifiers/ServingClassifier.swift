import VisionSugar

class ServingClassifier: Classifier {
    
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
        ServingClassifier(recognizedTexts: recognizedTexts, observations: observations).getObservations()
    }

    //MARK: - Helpers
    func getObservations() -> [Observation] {
        for recognizedText in recognizedTexts {
            guard recognizedText.string.containsServingAttribute else {
                continue
            }
            
            extractObservations(of: recognizedText)
            
            /// Process any attributes that were extracted
            for observation in pendingObservations {
                /// Only add attributes that haven't already been added
                observations.appendIfValid(observation)
//                if !observations.contains(where: { $0.attributeText.attribute == observation.attributeText.attribute }) {
//                    observations.append(observation)
//                }
            }

            /// Now do an inline search for any attribute that is still being extracted
            if let observation = observationBeingExtracted {
                
                /// Skip attributes that have already been added
                guard !observations.contains(where: { $0.attributeText.attribute == observation.attributeText.attribute }) else {
                    continue
                }

                var observationBeingExtracted = observation
                let inlineTextColumns = recognizedTexts.inlineTextColumns(as: recognizedText, ignoring: discarded)
                for column in inlineTextColumns {
                    
                    guard let inlineText = pickInlineText(fromColumn: column, for: observation.attributeText.attribute) else { continue }
                    
                    let result = extractServingObservation(
                        for: observationBeingExtracted.attribute,
                        from: inlineText)
//                    /// If we did extract a value, and the `recognizedText` had a single `Value` artefact—add it to the discarded pile so it doesn't get selected as= an inline text again
//                    if result.didExtract,
//                       inlineText.nutrientArtefacts.count >= 1,
//                       let _ = inlineText.nutrientArtefacts.first?.value
//                    {
//                        discarded.append(inlineText)
//                    }
                    if !result.shouldContinue {
                        break
                    }
                }
                
                /// If we've still not found any resulting attributes, look in the next text directly below it
                guard let nextLineText = recognizedTexts.filterSameColumn(as: recognizedText, removingOverlappingTexts: false).first else {
                    continue
                }
//                let _ = extractServingObservation(&observationBeingExtracted, from: nextLineText)
            }
        }
        return observations
    }
    
    private func pickInlineText(fromColumn column: [RecognizedText], for attribute: Attribute) -> RecognizedText? {
        
        /// **Heuristic** Remove any texts that contain no artefacts before returning the closest one, if we have more than 1 in a column (see Test Case 22 for how `Alimentaires` and `1.5 g` fall in the same column, with the former overlapping with `Protein` more, and thus `1.5 g` getting ignored
        let column = column.filter {
            $0.servingArtefacts.count > 0
        }
        
        /// As the defaul fall-back, return the first text (ie. the one closest to the observation we're extracted)
        return column.first
    }

    
    func extractObservations(of recognizedText: RecognizedText) {
        
        let textId = recognizedText.id
        
        let artefacts = recognizedText.servingArtefacts

        var observations: [Observation] = []
        
        var extractingAttributes: [AttributeText] = []

        for i in artefacts.indices {
            let artefact = artefacts[i]
            if let extractedAttribute = artefact.attribute {
                extractingAttributes = [AttributeText(attribute: extractedAttribute, textId: textId)]
            }
            else if !extractingAttributes.isEmpty {
                for extractingAttribute in extractingAttributes {
                    /// If this attribute supports the serving artefact, add it as an observation
                    if let observation = Observation(attributeText: extractingAttribute, servingArtefact: artefact) {
                        observations.append(observation)
                        
                        /// If we expect attributes following this (for example, `.servingUnit` or `.servingUnitSize` following a `.servingAmount`), assign those as the attributes we're now extracting
                        if let nextAttributes = extractingAttribute.attribute.nextAttributes {
                            extractingAttributes = nextAttributes.map { AttributeText(attribute: $0, textId: textId) }
                        } else {
                            extractingAttributes = []
                        }
                    }
                }
            }
        }
        
        //TODO: Handle multiple attributes here
        if let extractingAttribute = extractingAttributes.first {
            pendingObservations = observations
            observationBeingExtracted = Observation(
                attributeText: extractingAttribute,
                valueText1: nil,
                valueText2: nil)
        } else {
            pendingObservations = observations
            observationBeingExtracted = nil
        }
    }
    
    func extractServingObservation(for attribute: Attribute, from recognizedText: RecognizedText) -> (didExtract: Bool, shouldContinue: Bool) {
        
        let didExtract = false
//        var didExtract = false
        for artefact in recognizedText.getServingArtefacts()
        {
//            if let observation = Observation(attributeText: extractingAttribute, servingArtefact: artefact) {
//                observations.append(observation)
//
//                /// If we expect attributes following this (for example, `.servingUnit` or `.servingUnitSize` following a `.servingAmount`), assign those as the attributes we're now extracting
//                if let nextAttributes = extractingAttribute.attribute.nextAttributes {
//                    extractingAttributes = nextAttributes.map { AttributeText(attribute: $0, textId: textId) }
//                } else {
//                    extractingAttributes = []
//                }
//            }

            
            if let _ = artefact.attribute {
                /// Send `false` for algorithm to stop searching inline texts once we hit another `Attribute`
                return (didExtract: didExtract, shouldContinue: false)
            }
        }
        /// Send `true` for algorithm to keep searching inline texts if we haven't hit another `Attribute` or completed the `Observation`
        return (didExtract: didExtract, shouldContinue: true)
    }
}
