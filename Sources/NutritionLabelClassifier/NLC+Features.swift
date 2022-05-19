import Foundation
import VisionSugar
import TabularData

extension NutritionLabelClassifier {
    
    public static func features(from boxes: [RecognizedText]) -> DataFrame? {
        let dataFrame = dataFrameOfNutrients(from: boxes)
        let columnHeaders = columnHeadersBoxes(from: boxes, using: dataFrame)
        
        if let header1 = columnHeaders.0 {
            if let header2 = columnHeaders.1 {
                /// Column1 AND Column2
                if header1.id == header2.id {
                    //TODO: Figure out which side is 100g by parsing the string
                    print("Handle case where: header1.id == header2.id")
                } else {
                    if header1.string.matchesRegex(#"100[ ]*g"#) {
                        return dataFrame.selecting(columnNames: "attribute", "value1")
                    } else if header2.string.matchesRegex(#"100[ ]*g"#) {
                        return dataFrame.selecting(columnNames: "attribute", "value2")
                    }
                }
            } else {
                /// Column1 but no Column2
                print("Handle case where: We have Column1 but no Column2")
            }
        } else if let header2 = columnHeaders.1 {
            /// Column2 but no Column1
            print("Handle case where: We have Column2 but no Column1")
        }
        return nil
    }
}
