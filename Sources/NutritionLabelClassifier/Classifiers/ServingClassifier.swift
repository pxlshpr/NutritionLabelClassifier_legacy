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
                    
                    let result = extractServingObservation(&observationBeingExtracted, from: inlineText)
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
                
                /// After going through all inline texts and not completing the observation, add this (possibly incomplete one)
                guard observationBeingExtracted.valueText1 != nil || observationBeingExtracted.valueText2 != nil else {
                    continue
                }
//                observations.append(observationBeingExtracted)
                observations.appendIfValid(observationBeingExtracted)
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
//        var doubleTextBeingExtracted: DoubleText? = nil
//        var stringTextBeingExtracted: StringText? = nil
//        var unitTextBeingExtracted: UnitText? = nil

        for i in artefacts.indices {
            let artefact = artefacts[i]
            if let extractedAttribute = artefact.attribute {
                
                /// if we're in the process of extracting an observation and we have enough data for it, save it
//                if let attributeTextBeingExtracted = attributeTextBeingExtracted {
//                    fatalError("Encountered \(extractedAttribute) before completing \(attributeTextBeingExtracted.attribute)")
//                }
                
                extractingAttributes = [AttributeText(attribute: extractedAttribute, textId: textId)]
//                if let attributeBeingExtracted = attributeTextBeingExtracted, let valueBeingExtracted = value1BeingExtracted {
//                    observations.append(Observation(attributeText: attributeBeingExtracted,
//                                            valueText1: ValueText(value: valueBeingExtracted, textId: textId),
//                                            valueText2: nil))
//                    value1BeingExtracted = nil
//                }
//
//                attributeTextBeingExtracted = AttributeText(attribute: extractedAttribute, textId: recognizedText.id)

//            } else if let value = artefact.value, let attributeWithId = attributeTextBeingExtracted {
            } else if !extractingAttributes.isEmpty {
                
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
//                var unit = value.unit
//                var value = value
//
//                /// **Heuristic** If the value is missing its unit, *and* we don't have two values available inline, *and* it doesn't allow unit-less values—assign the attribute's default unit to it
//                if unit == nil,
//                   !attributeWithId.attribute.supportsUnitLessValues,
//                   !haveTwoInlineValues(for: recognizedText, forAttribute: attributeWithId.attribute)
//                {
//                    guard let defaultUnit = attributeWithId.attribute.defaultUnit else {
//                        continue
//                    }
//                    value = Value(amount: value.amount, unit: defaultUnit)
//                    unit = defaultUnit
//                }
//
//                if !attributeWithId.attribute.supportsUnitLessValues {
//                    guard let _ = unit else { continue }
//                }
//
//                guard !ignoreNextValueDueToPerPreposition else {
//                    ignoreNextValueDueToPerPreposition = false
//                    continue
//                }
//
//                if let value1 = value1BeingExtracted, let unit1 = value1.unit {
//                    if attributeWithId.attribute.isNutrient {
//                        /// If the unit doesn't match the first one we got, ignore this
//                        guard unit == unit1 else {
//                            continue
//                        }
//                    }
//                    observations.append(Observation(attributeText: attributeWithId,
//                                            valueText1: ValueText(value: value1, textId: textId),
//                                            valueText2: ValueText(value: value, textId: textId)))
//                    attributeTextBeingExtracted = nil
//                    value1BeingExtracted = nil
//                } else {
//                    /// Before setting this as the first value, check that the attribute supports the unit, and that we don't have the RI (required intake) preposition immediately following it
//                    var nextArtefactInvalidatesValue = false
//                    if i < artefacts.count - 1,
//                       let nextArtefactAsPreposition = artefacts[i+1].preposition,
//                       nextArtefactAsPreposition.invalidatesPreviousValueArtefact
//                    {
//                        nextArtefactInvalidatesValue = true
//                    }
//
//                    guard !nextArtefactInvalidatesValue else {
//                        continue
//                    }
//                    if let unit = unit {
//                        guard attributeWithId.attribute.supportsUnit(unit) else {
//                            continue
//                        }
//                    }
//
////                    guard attributeWithId.attribute.supportsUnit(unit), !nextArtefactInvalidatesValue else {
////                        continue
////                    }
//                    value1BeingExtracted = value
//
//                    /// If the attribute doesn't support multiple units (such as `servingsPerContainerAmount`), add the observation and clear the variables now
//                    if !attributeWithId.attribute.supportsMultipleColumns {
//                        observations.append(Observation(attributeText: attributeWithId,
//                                                valueText1: ValueText(value: value, textId: textId),
//                                                valueText2: nil))
//                        value1BeingExtracted = nil
//                        attributeTextBeingExtracted = nil
//                    }
//                }
            }
        }
        
        //TODO: Handle multiple attributes here
        if let extractingAttribute = extractingAttributes.first {
//            if let value1BeingExtracted = value1BeingExtracted {
//                pendingObservations = observations
//                observationBeingExtracted =  Observation(
//                    attributeText: attributeBeingExtracted,
//                    valueText1: ValueText(value: value1BeingExtracted, textId: textId),
//                    valueText2: nil
//                )
//            } else {
//                if attributeBeingExtracted.attribute.supportsPrecedingValue,
//                   let value = artefacts.valuePreceding(attributeBeingExtracted.attribute) {
//                    pendingObservations = observations
//                    observationBeingExtracted = Observation(
//                        attributeText: attributeBeingExtracted,
//                        valueText1: ValueText(value: value, textId: textId),
//                        valueText2: nil
//                    )
//                } else {
                    pendingObservations = observations
                    observationBeingExtracted = Observation(
                        attributeText: extractingAttribute,
                        valueText1: nil,
                        valueText2: nil)
//                }
//            }
        } else {
            pendingObservations = observations
            observationBeingExtracted = nil
        }
    }
    
    func extractServingObservation(_ observation: inout Observation, from recognizedText: RecognizedText) -> (didExtract: Bool, shouldContinue: Bool) {
        
        let didExtract = false
//        var didExtract = false
        for artefact in recognizedText.getServingArtefacts(for: observation.attributeText.attribute, observationBeingExtracted: observation, extractedObservations: observations) {
            
//            if let value = artefact.value {
//
//                /// **Heuristic** If the value is missing its unit and the attribute has a default unit, assign it to it
//                var unit = value.unit
//                var value = value
//                if unit == nil {
//                    guard let defaultUnit = observation.attributeText.attribute.defaultUnit else {
//                        continue
//                    }
//                    value = Value(amount: value.amount, unit: defaultUnit)
//                    unit = defaultUnit
//                }
//                guard let unit = unit else { continue }
//
//                if let value1 = observation.valueText1 {
//                    guard let unit1 = value1.value.unit, unit == unit1 else {
//                        continue
//                    }
//                    observation.valueText2 = ValueText(value: value, textId: recognizedText.id)
//                    didExtract = true
//                    /// Send `false` for algorithm to stop searching inline texts once we have completed the observation
//                    return (didExtract: didExtract, shouldContinue: false)
//                } else if observation.attributeText.attribute.supportsUnit(unit) {
//                    observation.valueText1 = ValueText(value: value, textId: recognizedText.id)
//                    didExtract = true
//                }
//            } else
            if let _ = artefact.attribute {
                /// Send `false` for algorithm to stop searching inline texts once we hit another `Attribute`
                return (didExtract: didExtract, shouldContinue: false)
            }
        }
        /// Send `true` for algorithm to keep searching inline texts if we haven't hit another `Attribute` or completed the `Observation`
        return (didExtract: didExtract, shouldContinue: true)
    }
}
