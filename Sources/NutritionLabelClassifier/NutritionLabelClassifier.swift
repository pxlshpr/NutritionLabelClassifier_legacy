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
            return (.per100g, .per(serving: rightColumn))
        }
        return (nil, nil)
    }
    
    static func columnHeaderFromBox(_ box: RecognizedText?) -> NutritionLabelColumnHeader? {
        return nil
    }
    
    static func columnHeaderBox(for dataFrame: DataFrame, withColumnName columnName: String, in boxes: [RecognizedText]) -> RecognizedText? {
        let columnBoxes: [RecognizedText] = dataFrame.rows.compactMap({
            ($0[columnName] as? RecognizedText)
        })
        
        guard let smallestBox = columnBoxes.sorted(by: { $0.rect.width < $1.rect.width}).first else {
            return nil
        }
        
//        for box in columnBoxes {
            let precedingBoxes = boxes.boxesOnSameColumn(as: smallestBox, preceding: true)
            for precedingBox in precedingBoxes {
                if precedingBox.string.matchesRegex(Regex.isColumnHeader) {
                    return precedingBox
                }
            }
//        }
        return nil
    }

    static func columnHeaders(from boxes: [RecognizedText], using dataFrame: DataFrame) -> (NutritionLabelColumnHeader?, NutritionLabelColumnHeader?) {
        guard dataFrame.columns.count == 3 else {
            return (nil, nil)
        }
        
        let header1Box = columnHeaderBox(for: dataFrame, withColumnName: "value1", in: boxes)
        let header2Box = columnHeaderBox(for: dataFrame, withColumnName: "value2", in: boxes)
        
        return (columnHeaderFromBox(header1Box),
                columnHeaderFromBox(header2Box))
    }
    
    //TODO: Remove this
    static func columnHeadersBoxes(from boxes: [RecognizedText], using dataFrame: DataFrame) -> (RecognizedText?, RecognizedText?) {
        guard dataFrame.columns.count == 3 else {
            return (nil, nil)
        }
        
        let header1 = columnHeaderBox(for: dataFrame, withColumnName: "value1", in: boxes)
        let header2 = columnHeaderBox(for: dataFrame, withColumnName: "value2", in: boxes)
        return (header1, header2)
    }
    
    static func dataFrameOfNutrients(from boxes: [RecognizedText]) -> DataFrame {
        
        var processedBoxes: [RecognizedText] = []
        var dataFrame = DataFrame()
        
        var attributes: [NutritionLabelAttribute] = []
        var column1Boxes: [RecognizedText?] = []
        var column2Boxes: [RecognizedText?] = []

        for box in boxes {
            guard !processedBoxes.contains(box),
                  box.isValueBasedClass,
                  let attribute = box.attribute
            else { continue }
            
            if box.containsValue {
                attributes.append(attribute)
                column1Boxes.append(box)
                processedBoxes.append(box)
                
                if let inlineValueBox = boxes.valueBoxOnSameLine(as: box), !processedBoxes.contains(inlineValueBox) {
                    column2Boxes.append(inlineValueBox)
                    processedBoxes.append(inlineValueBox)
                } else {
                    column2Boxes.append(nil)
                }
            } else if let inlineValueBox = boxes.valueBoxOnSameLine(as: box) {
                
                guard !processedBoxes.contains(inlineValueBox) else {
                    guard let inlineValueBox = boxes.valueBoxOnSameLine(as: box, inSecondColumn: true),
                       !processedBoxes.contains(inlineValueBox) else {
                        continue
                    }
                    attributes.append(attribute)
                    column1Boxes.append(nil)
                    column2Boxes.append(inlineValueBox)
                    processedBoxes.append(inlineValueBox)
                    continue
                }
                
                attributes.append(attribute)
                column1Boxes.append(inlineValueBox)
                processedBoxes.append(inlineValueBox)
                
                if let inlineValueBox = boxes.valueBoxOnSameLine(as: box, inSecondColumn: true),
                   !processedBoxes.contains(inlineValueBox)
                {
                    column2Boxes.append(inlineValueBox)
                    processedBoxes.append(inlineValueBox)
                } else {
                    column2Boxes.append(nil)
                }
            }
        }
        
        let labelColumn = Column(name: "attribute", contents: attributes)
        let column1Id = ColumnID("value1", RecognizedText?.self)
        let column2Id = ColumnID("value2", RecognizedText?.self)
        let column1 = Column(column1Id, contents: column1Boxes)
        let column2 = Column(column2Id, contents: column2Boxes)

           dataFrame.append(column: labelColumn)
        dataFrame.append(column: column1)
        dataFrame.append(column: column2)
        return dataFrame
    }
}
