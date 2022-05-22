import SwiftSugar
import TabularData
import VisionSugar
import CoreText

typealias Row = (attribute: Attribute, value1: Value?, value2: Value?)

extension NutritionLabelClassifier {

    static func extractAttribute(_ attribute: Attribute, from recognizedTexts: [RecognizedText]) -> Row {
        return (attribute, nil, nil)
    }
    
    static func processArtefacts(of recognizedText: RecognizedText) -> (rows: [Row], rowBeingExtracted: Row?) {
        
        var rows: [Row] = []
        var attributeBeingExtracted: Attribute? = nil
        var value1BeingExtracted: Value? = nil
        
        var ignoreNextValueDueToPerPreposition = false
        
        let artefacts = recognizedText.artefacts
        for i in artefacts.indices {
            let artefact = artefacts[i]
            if let attribute = artefact.attribute {
                /// if we're in the process of extracting a value, save it as a row
                if let attributeBeingExtracted = attributeBeingExtracted, let valueBeingExtracted = value1BeingExtracted {
                    rows.append((attributeBeingExtracted, valueBeingExtracted, nil))
                    value1BeingExtracted = nil
                }
                attributeBeingExtracted = attribute
            } else if let value = artefact.value, let attribute = attributeBeingExtracted {
                
                /// **Heuristic** If the value is missing its unit and the attribute has a default unit, assign it to it
                var unit = value.unit
                var value = value
                if unit == nil {
                    guard let defaultUnit = attribute.defaultUnit else {
                        continue
                    }
                    value = Value(amount: value.amount, unit: defaultUnit)
                    unit = defaultUnit
                }
                guard let unit = unit else { continue }
                
                guard !ignoreNextValueDueToPerPreposition else {
                    ignoreNextValueDueToPerPreposition = false
                    continue
                }
                
                if let value1 = value1BeingExtracted, let unit1 = value1.unit {
                    /// If the unit doesn't match the first one we got, ignore this
                    guard unit == unit1 else {
//                        rows.append((attribute, value1, nil))
//                        attributeBeingExtracted = nil
//                        value1BeingExtracted = nil
                        continue
                    }
                    rows.append((attribute, value1, value))
                    attributeBeingExtracted = nil
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
                    guard attribute.supportsUnit(unit), !nextArtefactInvalidatesValue else {
                        continue
                    }
                    value1BeingExtracted = value
                }
            } else if let preposition = artefact.preposition {
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
    
    static func extract(_ row: inout Row, from recognizedText: RecognizedText, extractedRows: [Row]) -> (didExtract: Bool, shouldContinue: Bool) {
        
        var didExtract = false
        for artefact in recognizedText.getArtefacts(for: row.attribute, rowBeingExtracted: row, extractedRows: extractedRows) {
            if let value = artefact.value, let unit = value.unit {
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
        ///                         Set the row with (`attributeBeingExtracted, value1, value2)`
        ///                         Reset `attributeBeingExtracted` and `value1`
        ///             Else if it is (another) `Attribute`
        ///                 return false
    }
    
    public static func dataFrameOfNutrients(from recognizedTexts: [RecognizedText]) -> DataFrame {
        
        var rows: [Row] = []
        
        /// Holds onto those that are single `Value`s that have already been used
        var discarded: [RecognizedText] = []

        for recognizedText in recognizedTexts {
            
            let result = processArtefacts(of: recognizedText)
            
            /// Process any attributes that were extracted
            for row in result.rows {
                /// Only add attributes that haven't already been added
                if !rows.contains(where: { $0.attribute == row.attribute }) {
                    rows.append(row)
                }
            }
            
            /// Now do an inline search for any attribute that is still being extracted
            if let row = result.rowBeingExtracted {
                
                /// Skip attributes that have already been added
                guard !rows.contains(where: { $0.attribute == row.attribute }) else {
                    continue
                }

                var rowBeingExtracted = row
                let inlineTextColumns = recognizedTexts.inlineTextColumns(as: recognizedText, ignoring: discarded)
                for column in inlineTextColumns {
                    
                    guard let inlineText = pickInlineText(fromColumn: column) else { continue }
                    
                    let result = extract(&rowBeingExtracted, from: inlineText, extractedRows: rows)
                    /// If we did extract a value, and the `recognizedText` had a single `Value` artefact—add it to the discarded pile so it doesn't get selected as= an inline text again
                    if result.didExtract,
                       inlineText.artefacts.count == 1,
                       let _ = inlineText.artefacts.first?.value
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
    
    static func pickInlineText(fromColumn column: [RecognizedText]) -> RecognizedText? {
        
        /// **Heuristic** In order to account for slightly curved labels that may pick up both a `kJ` and `kcal` `Value` when looking for energy—always pick the `kJ` one (as its larger in value) regardless of how far away it is from the row (as the curvature can sometimes skew this)
        if column.contains(where: { Value(fromString: $0.string)?.unit == .kcal }),
           column.contains(where: { Value(fromString: $0.string)?.unit == .kj }) {
            return column.first(where: { Value(fromString: $0.string)?.unit == .kj })
        }
        
        /// As the defaul fall-back, return the first text (ie. the one closest to the row we're extracted)
        return column.first
    }
}
