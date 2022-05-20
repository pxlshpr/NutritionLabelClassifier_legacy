import SwiftSugar
import TabularData
import VisionSugar
import CoreText

extension NutritionLabelClassifier {
    typealias Row = (attribute: Attribute, value1: Value?, value2: Value?)

    static func extractAttribute(_ attribute: Attribute, from recognizedTexts: [RecognizedText]) -> Row {
        return (attribute, nil, nil)
    }
    
    static func processArtefacts(of string: String) -> (rows: [Row], rowBeingExtracted: Row?) {
        
        var rows: [Row] = []
        var attributeBeingExtracted: Attribute? = nil
        var value1BeingExtracted: Value? = nil
        
        var ignoreNextValueDueToPerPreposition = false
        
        let artefacts = string.artefacts
        for i in artefacts.indices {
            let artefact = artefacts[i]
            if let attribute = artefact as? Attribute {
                /// if we're in the process of extracting a value, save it as a row
                if let attributeBeingExtracted = attributeBeingExtracted, let valueBeingExtracted = value1BeingExtracted {
                    rows.append((attributeBeingExtracted, valueBeingExtracted, nil))
                    value1BeingExtracted = nil
                }
                attributeBeingExtracted = attribute
            } else if let value = artefact as? Value, let unit = value.unit, let attribute = attributeBeingExtracted {
                guard !ignoreNextValueDueToPerPreposition else {
                    ignoreNextValueDueToPerPreposition = false
                    continue
                }
                
                if let value1 = value1BeingExtracted, let unit1 = value1.unit, unit == unit1 {
                    rows.append((attribute, value1, value))
                    attributeBeingExtracted = nil
                    value1BeingExtracted = nil
                } else {
                    /// Before setting this as the first value, check that the attribute supports the unit, and that we don't have the RI (required intake) preposition immediately following it
                    var nextArtefactInvalidatesValue = false
                    if i < artefacts.count - 1,
                       let nextArtefactAsPreposition = artefacts[i+1] as? Preposition,
                       nextArtefactAsPreposition.invalidatesPreviousValueArtefact
                    {
                        nextArtefactInvalidatesValue = true
                    }
                    guard attribute.supportsUnit(unit), !nextArtefactInvalidatesValue else {
                        continue
                    }
                    value1BeingExtracted = value
                }
            } else if let preposition = artefact as? Preposition {
                if preposition.containsPer {
                    ignoreNextValueDueToPerPreposition = true
                }
            }
        }
        
        if let attributeBeingExtracted = attributeBeingExtracted {
            return (rows, (attributeBeingExtracted, value1BeingExtracted, nil))
        } else {
            return (rows, nil)
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
        ///                     Set the row with (`attributeBeingExtracted, value1, value2)`
        ///                     Reset `attributeBeingExtracted` and `value1`
        /// If we have `attributeBeingExtracted`, call the extraction function with it
    }
    
    static func extract(_ row: inout Row, from string: String) -> (didExtract: Bool, shouldContinue: Bool) {
        
        var didExtract = false
        for artefact in string.artefacts {
            if let value = artefact as? Value, let unit = value.unit {
                if let value1 = row.value1 {
                    guard let unit1 = value1.unit, unit == unit1 else {
                        continue
                    }
                    row.value2 = value
                    didExtract = true
                    /// Send `false` for algorithm to stop searching inline texts once we have completed the row
                    return (didExtract: didExtract, shouldContinue: false)
                } else if row.attribute.supportsUnit(unit) {
                    row.value1 = value
                    didExtract = true
                }
            } else if let _ = artefact as? Attribute {
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
        ///                         Set the row with (`attributeBeingExtracted, value1, value2)`
        ///                         Reset `attributeBeingExtracted` and `value1`
        ///             Else if it is (another) `Attribute`
        ///                 return false
    }
    
    static func dataFrameOfNutrients(from recognizedTexts: [RecognizedText]) -> DataFrame {
        
        var rows: [Row] = []
        
        /// Holds onto those that are single `Value`s that have already been used
        var discarded: [RecognizedText] = []

        for recognizedText in recognizedTexts {
            
            let result = processArtefacts(of: recognizedText.string)
            
            /// Process any attributes that were extracted
            for row in result.rows {
                rows.append(row)
            }
            
            /// Now do an inline search for any attribute that is still being extracted
            if let row = result.rowBeingExtracted {
                
                var rowBeingExtracted = row
                let inlineTexts = recognizedTexts.filterSameRow(as: recognizedText, ignoring: discarded)
                for inlineText in inlineTexts {
                    let result = extract(&rowBeingExtracted, from: inlineText.string)
                    /// If we did extract a value, and the `recognizedText` had a single `Value` artefact—add it to the discarded pile so it doesn't get selected as an inline text again
                    if result.didExtract,
                       inlineText.string.artefacts.count == 1,
                       let _ = inlineText.string.artefacts.first as? Value
                    {
                        discarded.append(inlineText)
                    }
                    if !result.shouldContinue {
                        break
                    }
                }
                
                /// After going through all inline texts and not completing the row, add this (possibly incomplete one)
                guard rowBeingExtracted.value1 != nil || rowBeingExtracted.value2 != nil else {
                    continue
                }
                rows.append(rowBeingExtracted)
            }
        }
        
        var dataFrame = DataFrame()
        let labelColumn = Column(name: "attribute", contents: rows.map { $0.attribute })
        let value1Column = Column(name: "value1", contents: rows.map { $0.value1 })
        let value2Column = Column(name: "value2", contents: rows.map { $0.value2 })
//        let column1Id = ColumnID("values1", Value?.self)
//        let column2Id = ColumnID("values2", Value?.self)
//
        dataFrame.append(column: labelColumn)
        dataFrame.append(column: value1Column)
        dataFrame.append(column: value2Column)
        return dataFrame
    }
}
