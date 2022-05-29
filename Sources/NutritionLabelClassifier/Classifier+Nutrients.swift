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
                if !observations.contains(where: { $0.identifiableAttribute.attribute == observation.identifiableAttribute.attribute }) {
                    observations.append(observation)
                }
            }
            
            /// Now do an inline search for any attribute that is still being extracted
            if let observation = result.observationBeingExtracted {
                
                /// If we have a value1 for this observation, make sure we add the recognized text it was added from to the discarded list before checking the inline ones
                if let value1Id = observation.identifiableValue1?.id,
                    let recognizedTextForValue1 = recognizedTexts.first(where: { $0.id == value1Id })
                {
                    discarded.append(recognizedTextForValue1)
                }
                
                /// Skip attributes that have already been added
                guard !observations.contains(where: { $0.identifiableAttribute.attribute == observation.identifiableAttribute.attribute }) else {
                    continue
                }

                var observationBeingExtracted = observation
                let inlineTextColumns = recognizedTexts.inlineTextColumns(as: recognizedText, ignoring: discarded)
                for column in inlineTextColumns {
                    
                    guard let inlineText = pickInlineText(fromColumn: column, for: observation.identifiableAttribute.attribute) else { continue }
                    
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
                guard observationBeingExtracted.identifiableValue1 != nil || observationBeingExtracted.identifiableValue2 != nil else {
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
        var identifiableAttributeBeingExtracted: IdentifiableAttribute? = nil
        var value1BeingExtracted: Value? = nil
        
        var ignoreNextValueDueToPerPreposition = false
        
        for i in artefacts.indices {
            let artefact = artefacts[i]
            if let extractedAttribute = artefact.attribute {
                /// if we're in the process of extracting a value, save it as an observation
                if let attributeBeingExtracted = identifiableAttributeBeingExtracted, let valueBeingExtracted = value1BeingExtracted {
                    observations.append(Observation(identifiableAttribute: attributeBeingExtracted,
                                            identifiableValue1: IdentifiableValue(value: valueBeingExtracted, id: id),
                                            identifiableValue2: nil))
                    value1BeingExtracted = nil
                }
                identifiableAttributeBeingExtracted = IdentifiableAttribute(attribute: extractedAttribute, id: recognizedText.id)
                
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
                    observations.append(Observation(identifiableAttribute: attributeWithId,
                                            identifiableValue1: IdentifiableValue(value: value1, id: id),
                                            identifiableValue2: IdentifiableValue(value: value, id: id)))
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
                        observations.append(Observation(identifiableAttribute: attributeWithId,
                                                identifiableValue1: IdentifiableValue(value: value, id: id),
                                                identifiableValue2: nil))
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
                    observationBeingExtracted: Observation(identifiableAttribute: attributeBeingExtracted,
                                                   identifiableValue1: IdentifiableValue(value: value1BeingExtracted, id: id),
                                                   identifiableValue2: nil)
                )
            } else {
                if attributeBeingExtracted.attribute.supportsPrecedingValue,
                   let value = artefacts.valuePreceding(attributeBeingExtracted.attribute) {
                    return ProcessArtefactsResult(
                        observations: observations,
                        observationBeingExtracted: Observation(identifiableAttribute: attributeBeingExtracted,
                                                       identifiableValue1: IdentifiableValue(value: value, id: id),
                                                       identifiableValue2: nil)
                    )
                } else {
                    return ProcessArtefactsResult(
                        observations: observations,
                        observationBeingExtracted: Observation(identifiableAttribute: attributeBeingExtracted,
                                                       identifiableValue1: nil,
                                                       identifiableValue2: nil)
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
        for artefact in recognizedText.getArtefacts(for: observation.identifiableAttribute.attribute, observationBeingExtracted: observation, extractedObservations: extractedObservations) {
            if let value = artefact.value {
                
                /// **Heuristic** If the value is missing its unit and the attribute has a default unit, assign it to it
                var unit = value.unit
                var value = value
                if unit == nil {
                    guard let defaultUnit = observation.identifiableAttribute.attribute.defaultUnit else {
                        continue
                    }
                    value = Value(amount: value.amount, unit: defaultUnit)
                    unit = defaultUnit
                }
                guard let unit = unit else { continue }
                
                if let value1 = observation.identifiableValue1 {
                    guard let unit1 = value1.value.unit, unit == unit1 else {
                        continue
                    }
                    observation.identifiableValue2 = IdentifiableValue(value: value, id: recognizedText.id)
                    didExtract = true
                    /// Send `false` for algorithm to stop searching inline texts once we have completed the observation
                    return (didExtract: didExtract, shouldContinue: false)
                } else if observation.identifiableAttribute.attribute.supportsUnit(unit) {
                    observation.identifiableValue1 = IdentifiableValue(value: value, id: recognizedText.id)
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
    

}
