import SwiftSugar
import TabularData
import VisionSugar

public struct NutritionLabelClassifier {
    public struct Regex {
        static let containsTwoKcalValues = #"(?:^.*[^0-9.]+|^)([0-9.]+)[ ]*kcal.*[^0-9.]+([0-9.]+)[ ]*kcal.*$"#
        static let containsTwoKjValues = #"(?:^.*[^0-9.]+|^)([0-9.]+)[ ]*kj.*[^0-9.]+([0-9.]+)[ ]*kj.*$"#
        
        static let twoColumnHeadersWithPer100OnLeft = #"(?:.*per 100[ ]*g[ ])(?:per[ ])?(.*)"#
        static let twoColumnHeadersWithPer100OnRight = #""# /// Use this once a real-world test case has been encountered and added
        
        static let isColumnHeader = #"^(?=((^|.* )per .*|.*100[ ]*g.*|.*serving.*))(?!^.*Servings per.*$)(?!^.*DI.*$).*$"#
    }
    
    public static func kcalValues(from string: String) -> [Double] {
        string.capturedGroups(using: Regex.containsTwoKcalValues).compactMap { Double($0) }
    }
    
    public static func kjValues(from string: String) -> [Double] {
        string.capturedGroups(using: Regex.containsTwoKjValues).compactMap { Double($0) }
    }
    
    //MARK: - Sort these
    
    static func columnHeadersFromColumnSpanningHeader(_ string: String) -> (header1: NutritionLabelColumnHeader?, header2: NutritionLabelColumnHeader?) {
        if let rightColumn = string.firstCapturedGroup(using: Regex.twoColumnHeadersWithPer100OnLeft) {
            return (.per100g, .perServing(serving: rightColumn))
        }
        return (nil, nil)
    }
    
    static func columnHeader(fromRecognizedText recognizedText: RecognizedText?) -> NutritionLabelColumnHeader? {
        guard let recognizedText = recognizedText else {
            return nil
        }
        return NutritionLabelColumnHeader(string: recognizedText.string)
    }
    
    static func columnHeaderRecognizedText(for dataFrame: DataFrame, withColumnName columnName: String, in recognizedTexts: [RecognizedText]) -> RecognizedText? {
        let column: [RecognizedText] = dataFrame.rows.compactMap({
            ($0[columnName] as? RecognizedText)
        })
        
        guard let smallest = column.sorted(by: { $0.rect.width < $1.rect.width}).first else {
            return nil
        }
        
        let preceding = recognizedTexts.filterSameColumn(as: smallest, preceding: true)
        for recognizedText in preceding {
            if recognizedText.string.matchesRegex(Regex.isColumnHeader) {
                return recognizedText
            }
        }
        return nil
    }

    static func columnHeaders(from recognizedTexts: [RecognizedText], using dataFrame: DataFrame) -> (NutritionLabelColumnHeader?, NutritionLabelColumnHeader?) {
        guard dataFrame.columns.count == 3 else {
            return (nil, nil)
        }
        
        let header1 = columnHeaderRecognizedText(for: dataFrame, withColumnName: "recognizedText1", in: recognizedTexts)
        let header2 = columnHeaderRecognizedText(for: dataFrame, withColumnName: "recognizedText2", in: recognizedTexts)
        
        return (columnHeader(fromRecognizedText: header1),
                columnHeader(fromRecognizedText: header2))
    }
    
    //TODO: Remove this
    static func columnHeadersRecognizedTexts(from recognizedTexts: [RecognizedText], using dataFrame: DataFrame) -> (RecognizedText?, RecognizedText?) {
        guard dataFrame.columns.count == 3 else {
            return (nil, nil)
        }
        
        let header1 = columnHeaderRecognizedText(for: dataFrame, withColumnName: "recognizedTex1", in: recognizedTexts)
        let header2 = columnHeaderRecognizedText(for: dataFrame, withColumnName: "recognizedTex2", in: recognizedTexts)
        return (header1, header2)
    }
    
    static func dataFrameOfNutrients(from recognizedTexts: [RecognizedText]) -> DataFrame {
        
        var processed: [RecognizedText] = []
        var dataFrame = DataFrame()
        
        var attributes: [NutritionLabelAttribute] = []
        var column1: [RecognizedText?] = []
        var column2: [RecognizedText?] = []

        for recognizedText in recognizedTexts {
            guard !processed.contains(recognizedText),
                  recognizedText.isValueBasedClass,
                  let attribute = recognizedText.attribute
            else { continue }
            
            if recognizedText.containsValue {
                print(recognizedText.string)
                attributes.append(attribute)
                column1.append(recognizedText)
                processed.append(recognizedText)
                
                if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText), !processed.contains(inlineValue) {
                    column2.append(inlineValue)
                    processed.append(inlineValue)
                } else {
                    column2.append(nil)
                }
            } else if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText) {

                guard !processed.contains(inlineValue) else {
                    guard let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText, inSecondColumn: true),
                       !processed.contains(inlineValue) else {
                        continue
                    }
                    attributes.append(attribute)
                    column1.append(nil)
                    column2.append(inlineValue)
                    processed.append(inlineValue)
                    
                    print(inlineValue.string)

                    continue
                }
                
                attributes.append(attribute)
                column1.append(inlineValue)
                processed.append(inlineValue)

                print(inlineValue.string)

                if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText, inSecondColumn: true),
                   !processed.contains(inlineValue)
                {
                    print(inlineValue.string)
                    column2.append(inlineValue)
                    processed.append(inlineValue)
                } else {
                    column2.append(nil)
                }
            }
        }
        
        let labelColumn = Column(name: "attribute", contents: attributes)
        let column1Id = ColumnID("recognizedText1", RecognizedText?.self)
        let column2Id = ColumnID("recognizedText2", RecognizedText?.self)

        dataFrame.append(column: labelColumn)
        dataFrame.append(column: Column(column1Id, contents: column1))
        dataFrame.append(column: Column(column2Id, contents: column2))
        return dataFrame
    }
    
    static func dataFrameOfNutrients_legacy(from recognizedTexts: [RecognizedText]) -> DataFrame {
        
        var processed: [RecognizedText] = []
        var dataFrame = DataFrame()
        
        var attributes: [NutritionLabelAttribute] = []
        var column1: [RecognizedText?] = []
        var column2: [RecognizedText?] = []

        for recognizedText in recognizedTexts {
            guard !processed.contains(recognizedText),
                  recognizedText.isValueBasedClass,
                  let attribute = recognizedText.attribute
            else { continue }
            
            if recognizedText.containsValue {
                attributes.append(attribute)
                column1.append(recognizedText)
                processed.append(recognizedText)
                
                if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText), !processed.contains(inlineValue) {
                    column2.append(inlineValue)
                    processed.append(inlineValue)
                } else {
                    column2.append(nil)
                }
            } else if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText) {
                
                guard !processed.contains(inlineValue) else {
                    guard let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText, inSecondColumn: true),
                       !processed.contains(inlineValue) else {
                        continue
                    }
                    attributes.append(attribute)
                    column1.append(nil)
                    column2.append(inlineValue)
                    processed.append(inlineValue)
                    continue
                }
                
                attributes.append(attribute)
                column1.append(inlineValue)
                processed.append(inlineValue)
                
                if let inlineValue = recognizedTexts.valueOnSameLine(as: recognizedText, inSecondColumn: true),
                   !processed.contains(inlineValue)
                {
                    column2.append(inlineValue)
                    processed.append(inlineValue)
                } else {
                    column2.append(nil)
                }
            }
        }
        
        let labelColumn = Column(name: "attribute", contents: attributes)
        let column1Id = ColumnID("recognizedText1", RecognizedText?.self)
        let column2Id = ColumnID("recognizedText2", RecognizedText?.self)

        dataFrame.append(column: labelColumn)
        dataFrame.append(column: Column(column1Id, contents: column1))
        dataFrame.append(column: Column(column2Id, contents: column2))
        return dataFrame
    }
}
