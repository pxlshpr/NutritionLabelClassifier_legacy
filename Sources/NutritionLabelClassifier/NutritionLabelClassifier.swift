import SwiftSugar
import TabularData
import VisionSugar

public struct NutritionLabelClassifier {
    public struct Regex {
        static let containsTwoKcalValues = #"(?:^.*[^0-9.]+|^)([0-9.]+)[ ]*kcal.*[^0-9.]+([0-9.]+)[ ]*kcal.*$"#
        static let containsTwoKjValues = #"(?:^.*[^0-9.]+|^)([0-9.]+)[ ]*kj.*[^0-9.]+([0-9.]+)[ ]*kj.*$"#
    }
    
    public static func kcalValues(from string: String) -> [Double] {
        string.capturedGroups(using: Regex.containsTwoKcalValues).compactMap { Double($0) }
    }
    
    public static func kjValues(from string: String) -> [Double] {
        string.capturedGroups(using: Regex.containsTwoKjValues).compactMap { Double($0) }
    }
    
    //MARK: - Sort these
    
    public static func dataFrameOfValues(from boxes: [Box]) -> DataFrame? {
        let dataFrame = dataFrameOfNutrients(from: boxes)
        let columnHeaders = columnHeaders(from: boxes, using: dataFrame)
        if let header1 = columnHeaders.0 {
            if let header2 = columnHeaders.1 {
                /// Column1 AND Column2
                if header1.id == header2.id {
                    //TODO: Figure out which side is 100g
                } else {
                    if header1.string.matchesRegex(#"100[ ]*g"#) {
                        return dataFrame.selecting(columnNames: "label", "col1")
                    } else if header2.string.matchesRegex(#"100[ ]*g"#) {
                        return dataFrame.selecting(columnNames: "label", "col2")
                    }
                }
            } else {
                /// Column1 but no Column2
            }
        } else if let header2 = columnHeaders.1 {
            /// Column2 but no Column1
        }
        return nil
    }
    
    static func columnHeader(for dataFrame: DataFrame, withColumnName columnName: String, in boxes: [Box]) -> Box? {
        let columnBoxes: [Box] = dataFrame.rows.compactMap({
            ($0[columnName] as? Box)
        })
        
        guard let smallestBox = columnBoxes.sorted(by: { $0.rect.width < $1.rect.width}).first else {
            return nil
        }
        
//        for box in columnBoxes {
            let precedingBoxes = boxes.boxesOnSameColumn(as: smallestBox, preceding: true)
            for precedingBox in precedingBoxes {
                if precedingBox.string.matchesRegex(#"^(?=((^|.* )per .*|.*100[ ]*g.*|.*serving.*))(?!^.*Servings per.*$)(?!^.*DI.*$).*$"#) {
                    return precedingBox
                }
            }
//        }
        return nil
    }
    
    static func columnHeaders(from boxes: [Box], using dataFrame: DataFrame) -> (Box?, Box?) {
        guard dataFrame.columns.count == 3 else {
            return (nil, nil)
        }
        
        let header1 = columnHeader(for: dataFrame, withColumnName: "values1", in: boxes)
        let header2 = columnHeader(for: dataFrame, withColumnName: "values2", in: boxes)
        return (header1, header2)
    }
    
    static func dataFrameOfNutrients(from boxes: [Box]) -> DataFrame {
        
        var processedBoxes: [Box] = []
        var dataFrame = DataFrame()
        
        var attributes: [NutritionLabelAttribute] = []
        var column1Boxes: [Box?] = []
        var column2Boxes: [Box?] = []

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
        
        let labelColumn = Column(name: "attributes", contents: attributes)
        let column1Id = ColumnID("values1", Box?.self)
        let column2Id = ColumnID("values2", Box?.self)
        let column1 = Column(column1Id, contents: column1Boxes)
        let column2 = Column(column2Id, contents: column2Boxes)

           dataFrame.append(column: labelColumn)
        dataFrame.append(column: column1)
        dataFrame.append(column: column2)
        print(dataFrame)
        return dataFrame
    }
}
