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
                observations.appendIfValid(observation)
            }

            /// Now do an inline search for any attribute that is still being extracted
            if let observation = observationBeingExtracted {
                
                /// Skip attributes that have already been added
                guard !observations.contains(where: { $0.attributeText.attribute == observation.attributeText.attribute }) else {
                    continue
                }

                /// **NOTE:** We're currently not looking for inline texts, as its not needed so far, and uncommenting the following block results in failed tests which we need to look into first
//                let inlineTextColumns = recognizedTexts.inlineTextColumns(as: recognizedText, ignoring: discarded)
//                for column in inlineTextColumns {
//                    
//                    guard let inlineText = pickInlineText(fromColumn: column, for: observation.attributeText.attribute) else { continue }
//                    
//                    extractObservations(
//                        of: inlineText,
//                        startingWithAttributeText: observation.attributeText
//                    )
//                    for observation in pendingObservations {
//                        observations.appendIfValid(observation)
//                    }
//                }
                
                /// If we've still not found any resulting attributes, look in the next text directly below it
                guard let nextLineText = recognizedTexts.filterSameColumn(as: recognizedText, removingOverlappingTexts: false).first,
                    nextLineText.string != "Per 100g"
                else {
                    continue
                }
                extractObservations(
                    of: nextLineText,
                    startingWithAttributeText: observation.attributeText)
                for observation in pendingObservations {
                    observations.appendIfValid(observation)
                }
            }
        }
        return observations
    }
    
    func extractObservations(of recognizedText: RecognizedText, startingWithAttributeText startingAttributeText: AttributeText? = nil) {
        
        let textId = recognizedText.id
        let artefacts = recognizedText.servingArtefacts
        var observations: [Observation] = []
        var extractingAttributes: [AttributeText] = [startingAttributeText].compactMap { $0 }

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
        
        pendingObservations = observations
        if startingAttributeText == nil, let extractingAttribute = extractingAttributes.first {
            observationBeingExtracted = Observation(
                attributeText: extractingAttribute,
                valueText1: nil,
                valueText2: nil)
        }
    }
    
    //MARK: - Helpers
    private func pickInlineText(fromColumn column: [RecognizedText], for attribute: Attribute) -> RecognizedText? {
        
        /// **Heuristic** Remove any texts that contain no artefacts before returning the closest one, if we have more than 1 in a column (see Test Case 22 for how `Alimentaires` and `1.5 g` fall in the same column, with the former overlapping with `Protein` more, and thus `1.5 g` getting ignored
        let column = column.filter {
            $0.servingArtefacts.count > 0
        }
        
        /// As the defaul fall-back, return the first text (ie. the one closest to the observation we're extracted)
        return column.first
    }
}
