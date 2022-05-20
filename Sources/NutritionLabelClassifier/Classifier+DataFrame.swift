import SwiftSugar
import TabularData
import VisionSugar

extension NutritionLabelClassifier {
    
    static func dataFrameOfNutrients(from recognizedTexts: [RecognizedText]) -> DataFrame {
        
        var rows: [(Attribute, Value?, Value?)] = []

        for recognizedText in recognizedTexts {
            
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
            ///                     continue to the next `recognizedText`

            /// If we have an `attributeBeingExtracted`
            ///     Get the inline recognized texts
            ///     For each one in order
            ///         Get the artefacts
            ///             If it is a `Value`
            ///                 If we don't have `value1` and its a supported unit
            ///                     Save it as `value1`
            ///                 Else (we have `value1)`
            ///                     If its the same unit as `value1`
            ///                         Set the row with (`attributeBeingExtracted, value1, value2)`
            ///                         Reset `attributeBeingExtracted` and `value1`
            ///                         continue to the next `recognizedText`
            ///             Else If it is an `Attribute`
            ///                 If we've already got `value1` extracted
            ///                     Set the row with (`attributeBeingExtracted, value1, nil)`
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
//            guard let attribute = Attribute(fromString: recognizedText.string) else {
//                print("↪️ \(recognizedText) is NOT an attribute, so skipping it")
//                continue
//            }
//
//    //            /// if the recognized text contains more than 1 value-based attribute
//    //            if recognizedText.containsMultipleValueBasedAttributes {
//    //
//    //            }
//            /// Separate them out into an array
//            /// For each element of the array, run the following code—making sure we allow the *final* array element to have an inline value that's not within the same box (whereas the rest should have it within the string itself)
//
//    //            print("(\"\(recognizedText)\", [.\(attribute)]),")
//    //            print(recognizedText)
//    //            continue
//
//            //TODO: Make sure we're using the array of units instead of harcoding them in containsValue
//            if recognizedText.containsValue {
//    //                print(recognizedText.string)
//                attributes.append(attribute)
//                values1.append(recognizedText)
//                processed.append(recognizedText)
//
//                if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText), !processed.contains(inlineValue) {
//                    values2.append(inlineValue)
//                    processed.append(inlineValue)
//                } else {
//                    values2.append(nil)
//                }
//            } else if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText) {
//
//                /// Check if we have the special case of 4 energy values, and if so, split them into two separate values that gets treated as each one lying in a different column
//
//                /// Also check if we have 2 values, and if so, determine that we're spanning both columns and process them and append them at the same time, continuing afterwards
//
//                //TODO: Comment why we're doing this
//                guard !processed.contains(inlineValue) else {
//                    guard let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText, inSecondColumn: true),
//                       !processed.contains(inlineValue) else {
//                        continue
//                    }
//                    attributes.append(attribute)
//                    values1.append(nil)
//                    values2.append(inlineValue)
//                    processed.append(inlineValue)
//
//    //                    print(inlineValue.string)
//
//                    continue
//                }
//
//                attributes.append(attribute)
//                values1.append(inlineValue)
//                processed.append(inlineValue)
//
//    //                print(inlineValue.string)
//
//                if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText, inSecondColumn: true),
//                   !processed.contains(inlineValue)
//                {
//    //                    print(inlineValue.string)
//                    values2.append(inlineValue)
//                    processed.append(inlineValue)
//                } else {
//                    values2.append(nil)
//                }
//            }
        }
        
        var dataFrame = DataFrame()

//        let labelColumn = Column(name: "attribute", contents: attributes)
//        let column1Id = ColumnID("values1", Value?.self)
//        let column2Id = ColumnID("values2", Value?.self)
//
//        dataFrame.append(column: labelColumn)
//        dataFrame.append(column: Column(column1Id, contents: values1))
//        dataFrame.append(column: Column(column2Id, contents: values2))
        return dataFrame
    }
}
