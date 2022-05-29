import SwiftSugar
import TabularData
import VisionSugar
import CoreText
import Foundation

extension NutritionLabelClassifier {
    static func extractNutrientObservations(from recognizedTexts: [RecognizedText], into observations: inout [Observation]) {
        
        /// Holds onto those that are single `Value`s that have already been used
        var discarded: [RecognizedText] = []

        for recognizedText in recognizedTexts {
            
            let result: ProcessArtefactsResult
            if heuristicRecognizedTextIsPartOfAttribute(recognizedText, from: recognizedTexts) {
                result = processArtefactsOf(recognizedText, byJoiningWithNextInlineRecognizedTextIn: recognizedTexts, observations: observations, ignoring: discarded)
            } else {
                result = processArtefacts(of: recognizedText, from: recognizedTexts, ignoring: discarded)
            }
            
            /// Process any attributes that were extracted
            for observation in result.observations {
                /// Only add attributes that haven't already been added
                if !observations.contains(where: { $0.attributeText.attribute == observation.attributeText.attribute }) {
                    observations.append(observation)
                }
            }
            
            /// Now do an inline search for any attribute that is still being extracted
            if let observation = result.observationBeingExtracted {
                
                /// If we have a value1 for this observation, make sure we add the recognized text it was added from to the discarded list before checking the inline ones
                if let value1Id = observation.valueText1?.textId,
                    let recognizedTextForValue1 = recognizedTexts.first(where: { $0.id == value1Id })
                {
                    discarded.append(recognizedTextForValue1)
                }
                
                /// Skip attributes that have already been added
                guard !observations.contains(where: { $0.attributeText.attribute == observation.attributeText.attribute }) else {
                    continue
                }

                var observationBeingExtracted = observation
                let inlineTextColumns = recognizedTexts.inlineTextColumns(as: recognizedText, ignoring: discarded)
                for column in inlineTextColumns {
                    
                    guard let inlineText = pickInlineText(fromColumn: column, for: observation.attributeText.attribute) else { continue }
                    
                    let result = extractNutrientObservation(&observationBeingExtracted, from: inlineText, extractedObservations: observations)
                    /// If we did extract a value, and the `recognizedText` had a single `Value` artefact—add it to the discarded pile so it doesn't get selected as= an inline text again
                    if result.didExtract,
                       inlineText.artefacts.count >= 1,
                       let _ = inlineText.artefacts.first?.value
                    {
                        discarded.append(inlineText)
                    }
                    if !result.shouldContinue {
                        break
                    }
                }
                
                /// After going through all inline texts and not completing the observation, add this (possibly incomplete one)
                guard observationBeingExtracted.valueText1 != nil || observationBeingExtracted.valueText2 != nil else {
                    continue
                }
                observations.append(observationBeingExtracted)
            }
        }
    }
    
    static func processArtefacts(of recognizedText: RecognizedText, from recognizedTexts: [RecognizedText], ignoring discarded: [RecognizedText]) -> ProcessArtefactsResult {
        
        let artefacts = recognizedText.artefacts
        let id = recognizedText.id

        var observations: [Observation] = []
        var identifiableAttributeBeingExtracted: AttributeText? = nil
        var value1BeingExtracted: Value? = nil
        
        var ignoreNextValueDueToPerPreposition = false
        
        for i in artefacts.indices {
            let artefact = artefacts[i]
            if let extractedAttribute = artefact.attribute {
                /// if we're in the process of extracting a value, save it as an observation
                if let attributeBeingExtracted = identifiableAttributeBeingExtracted, let valueBeingExtracted = value1BeingExtracted {
                    observations.append(Observation(attributeText: attributeBeingExtracted,
                                            valueText1: ValueText(value: valueBeingExtracted, textId: id),
                                            valueText2: nil))
                    value1BeingExtracted = nil
                }
                identifiableAttributeBeingExtracted = AttributeText(attribute: extractedAttribute, textId: recognizedText.id)
                
            } else if let value = artefact.value, let attributeWithId = identifiableAttributeBeingExtracted {
                
                var unit = value.unit
                var value = value
                
                /// **Heuristic** If the value is missing its unit, *and* we don't have two values available inline, *and* it doesn't allow unit-less values—assign the attribute's default unit to it
                if unit == nil,
                   !attributeWithId.attribute.supportsUnitLessValues,
                   !haveTwoInlineValues(for: recognizedText,
                                        in: recognizedTexts,
                                        forAttribute: attributeWithId.attribute,
                                        ignoring: discarded)
                {
                    guard let defaultUnit = attributeWithId.attribute.defaultUnit else {
                        continue
                    }
                    value = Value(amount: value.amount, unit: defaultUnit)
                    unit = defaultUnit
                }
                
                if !attributeWithId.attribute.supportsUnitLessValues {
                    guard let _ = unit else { continue }
                }
                
                guard !ignoreNextValueDueToPerPreposition else {
                    ignoreNextValueDueToPerPreposition = false
                    continue
                }
                
                if let value1 = value1BeingExtracted, let unit1 = value1.unit {
                    if attributeWithId.attribute.isNutrient {
                        /// If the unit doesn't match the first one we got, ignore this
                        guard unit == unit1 else {
                            continue
                        }
                    }
                    observations.append(Observation(attributeText: attributeWithId,
                                            valueText1: ValueText(value: value1, textId: id),
                                            valueText2: ValueText(value: value, textId: id)))
                    identifiableAttributeBeingExtracted = nil
                    value1BeingExtracted = nil
                } else {
                    /// Before setting this as the first value, check that the attribute supports the unit, and that we don't have the RI (required intake) preposition immediately following it
                    var nextArtefactInvalidatesValue = false
                    if i < artefacts.count - 1,
                       let nextArtefactAsPreposition = artefacts[i+1].preposition,
                       nextArtefactAsPreposition.invalidatesPreviousValueArtefact
                    {
                        nextArtefactInvalidatesValue = true
                    }
                    
                    guard !nextArtefactInvalidatesValue else {
                        continue
                    }
                    if let unit = unit {
                        guard attributeWithId.attribute.supportsUnit(unit) else {
                            continue
                        }
                    }
                    
//                    guard attributeWithId.attribute.supportsUnit(unit), !nextArtefactInvalidatesValue else {
//                        continue
//                    }
                    value1BeingExtracted = value
                    
                    /// If the attribute doesn't support multiple units (such as `servingsPerContainerAmount`), add the observation and clear the variables now
                    if !attributeWithId.attribute.supportsMultipleColumns {
                        observations.append(Observation(attributeText: attributeWithId,
                                                valueText1: ValueText(value: value, textId: id),
                                                valueText2: nil))
                        value1BeingExtracted = nil
                        identifiableAttributeBeingExtracted = nil
                    }
                }
            } else if let preposition = artefact.preposition {
                if preposition.containsPer {
                    ignoreNextValueDueToPerPreposition = true
                }
            }
        }
        
        if let attributeBeingExtracted = identifiableAttributeBeingExtracted {
            if let value1BeingExtracted = value1BeingExtracted {
                return ProcessArtefactsResult(
                    observations: observations,
                    observationBeingExtracted: Observation(attributeText: attributeBeingExtracted,
                                                   valueText1: ValueText(value: value1BeingExtracted, textId: id),
                                                   valueText2: nil)
                )
            } else {
                if attributeBeingExtracted.attribute.supportsPrecedingValue,
                   let value = artefacts.valuePreceding(attributeBeingExtracted.attribute) {
                    return ProcessArtefactsResult(
                        observations: observations,
                        observationBeingExtracted: Observation(attributeText: attributeBeingExtracted,
                                                       valueText1: ValueText(value: value, textId: id),
                                                       valueText2: nil)
                    )
                } else {
                    return ProcessArtefactsResult(
                        observations: observations,
                        observationBeingExtracted: Observation(attributeText: attributeBeingExtracted,
                                                       valueText1: nil,
                                                       valueText2: nil)
                    )
                }
            }
        } else {
            return ProcessArtefactsResult(
                observations: observations,
                observationBeingExtracted: nil
            )
        }
        /// Get the artefacts
        /// For each artefact
        ///     If it is an `Attribute`
        ///         save it as the `attributeBeingExtracted`
        ///     If it is a `Value`,
        ///         If we have a `attributeBeingExtracted`
        ///             If we don't have `value1` and its a supported unit
        ///                 Save it as `value1`
        ///             Else (we have `value1)`
        ///                 If its the same unit as `value1`
        ///                     Set the observation with (`attributeBeingExtracted, value1, value2)`
        ///                     Reset `attributeBeingExtracted` and `value1`
        /// If we have `attributeBeingExtracted`, call the extraction function with it
    }
    
    static func extractNutrientObservation(_ observation: inout Observation, from recognizedText: RecognizedText, extractedObservations: [Observation]) -> (didExtract: Bool, shouldContinue: Bool) {
        
        var didExtract = false
        for artefact in recognizedText.getArtefacts(for: observation.attributeText.attribute, observationBeingExtracted: observation, extractedObservations: extractedObservations) {
            if let value = artefact.value {
                
                /// **Heuristic** If the value is missing its unit and the attribute has a default unit, assign it to it
                var unit = value.unit
                var value = value
                if unit == nil {
                    guard let defaultUnit = observation.attributeText.attribute.defaultUnit else {
                        continue
                    }
                    value = Value(amount: value.amount, unit: defaultUnit)
                    unit = defaultUnit
                }
                guard let unit = unit else { continue }
                
                if let value1 = observation.valueText1 {
                    guard let unit1 = value1.value.unit, unit == unit1 else {
                        continue
                    }
                    observation.valueText2 = ValueText(value: value, textId: recognizedText.id)
                    didExtract = true
                    /// Send `false` for algorithm to stop searching inline texts once we have completed the observation
                    return (didExtract: didExtract, shouldContinue: false)
                } else if observation.attributeText.attribute.supportsUnit(unit) {
                    observation.valueText1 = ValueText(value: value, textId: recognizedText.id)
                    didExtract = true
                }
            } else if let _ = artefact.attribute {
                /// Send `false` for algorithm to stop searching inline texts once we hit another `Attribute`
                return (didExtract: didExtract, shouldContinue: false)
            }
        }
        /// Send `true` for algorithm to keep searching inline texts if we haven't hit another `Attribute` or completed the `Row`
        return (didExtract: didExtract, shouldContinue: true)
        
        ///         For each of its artefacts
        ///             If it is a `Value`
        ///                 If we don't have `value1` and its a supported unit
        ///                     Save it as `value1`
        ///                 Else (we have `value1)`
        ///                     If its the same unit as `value1`
        ///                         Set the observation with (`attributeBeingExtracted, value1, value2)`
        ///                         Reset `attributeBeingExtracted` and `value1`
        ///             Else if it is (another) `Attribute`
        ///                 return false
    }
}

//MARK: - Helpers
extension NutritionLabelClassifier {
    private static func heuristicRecognizedTextIsPartOfAttribute(_ recognizedText: RecognizedText, from recognizedTexts: [RecognizedText]) -> Bool {
        recognizedText.string.lowercased() == "vitamin"
    }
    
    private static func processArtefactsOf(_ recognizedText: RecognizedText, byJoiningWithNextInlineRecognizedTextIn recognizedTexts: [RecognizedText], observations: [Observation], ignoring discarded: [RecognizedText]) ->  ProcessArtefactsResult
    {
        guard let nextRecognizedText = recognizedTexts.inlineTextColumns(as: recognizedText).first?.first else {
            return ProcessArtefactsResult(
                observations: observations,
                observationBeingExtracted: nil
            )
        }
        let combinedRecognizedText = RecognizedText(
            id: nextRecognizedText.id,
            rectString: NSCoder.string(for: nextRecognizedText.rect),
            boundingBoxString: NSCoder.string(for: nextRecognizedText.boundingBox),
            candidates: ["\(recognizedText.string) \(nextRecognizedText.string)"])
        return processArtefacts(of: combinedRecognizedText, from: recognizedTexts, ignoring: discarded)
    }
    
    static func haveTwoInlineValues(for recognizedText: RecognizedText, in recognizedTexts: [RecognizedText], forAttribute attribute: Attribute, ignoring discarded: [RecognizedText]) -> Bool {
        let inlineTextColumns = recognizedTexts.inlineTextColumns(as: recognizedText, ignoring: discarded)
        var inlineValueCount = 0
        for column in inlineTextColumns {
            guard let inlineText = pickInlineText(fromColumn: column, for: attribute) else { continue }
            if inlineText.artefacts.contains(where: { $0.value != nil }) {
                inlineValueCount += 1
            }
        }
        return inlineValueCount > 1
    }
    static func pickInlineText(fromColumn column: [RecognizedText], for attribute: Attribute) -> RecognizedText? {
        
        /// **Heuristic** In order to account for slightly curved labels that may pick up both a `kJ` and `kcal` `Value` when looking for energy—always pick the `kJ` one (as its larger in value) regardless of how far away it is from the observation (as the curvature can sometimes skew this)
        if column.contains(where: { Value(fromString: $0.string)?.unit == .kcal }),
           column.contains(where: { Value(fromString: $0.string)?.unit == .kj }) {
            return column.first(where: { Value(fromString: $0.string)?.unit == .kj })
        }
        
        /// **Heuristic** Remove any texts that contain no artefacts before returning the closest one, if we have more than 1 in a column (see Test Case 22 for how `Alimentaires` and `1.5 g` fall in the same column, with the former overlapping with `Protein` more, and thus `1.5 g` getting ignored
        var column = column.filter {
            $0.artefacts.count > 0
//            Value(fromString: $0.string) != nil
        }
        
        /// **Heuristic** Remove any values that aren't supported by the attribute we're extracting
        column = column.filter {
            if let unit = Value(fromString: $0.string)?.unit {
                return attribute.supportsUnit(unit)
            }
            return true
        }
        
        /// As the defaul fall-back, return the first text (ie. the one closest to the observation we're extracted)
        return column.first
    }
}
