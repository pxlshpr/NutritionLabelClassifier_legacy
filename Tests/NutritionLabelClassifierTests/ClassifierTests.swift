import XCTest
import SwiftSugar
import TabularData
import VisionSugar

@testable import NutritionLabelClassifier

let testCasesForColumnSpanningEnergy: [(input: String, kcal: [Double], kj: [Double])] = [
    ("Brennwert Energi 735 kJ (177 kcal) 412 kJ (99 kcal)", [177, 99], [735, 412]),
    ("384kJ/91kcal 284kJ/67 kcal", [91, 67], [384, 284]),
    ("94 kcal (395 kJ 75 kcal (315 kJ", [94, 75], [395, 315]),
    ("(117 kcal (491 kJ| 90 kcal (378 kJ)", [117, 90], [491, 378]),
    ("Energy 116kcal 96kcal", [116, 96], []),
    ("Energy 620kj 154 Kj", [], [620, 154]),
    ("113 kcal (475 kJ) 90 kcal (378 kJ)", [113, 90], [475, 378]),
]

let testCasesForColumnSpanningHeader: [(input: String, header1: ColumnHeader?, header2: ColumnHeader?)] = [
    ("PER 100g 74g (2 tubes)", .per100g, .perServing(serving: "74g (2 tubes)")),
    ("Nutritional Values (Typical) Per 100 g Per serving (125 g)", .per100g, .perServing(serving: "serving (125 g)"))
]

final class NutritionLabelClassifierTests: XCTestCase {
    func testContainsTwoKcalValues() throws {
        for testCase in testCasesForColumnSpanningEnergy {
            let kcalValues = NutritionLabelClassifier.kcalValues(from: testCase.input)
            XCTAssertEqual(kcalValues, testCase.kcal)
        }
    }
    
    func testContainsTwoKjValues() throws {
        for testCase in testCasesForColumnSpanningEnergy {
            let kjValues = NutritionLabelClassifier.kjValues(from: testCase.input)
            XCTAssertEqual(kjValues, testCase.kj)
        }
    }

    func testColumnSpanningHeader() throws {
        for testCase in testCasesForColumnSpanningHeader {
            let headers = NutritionLabelClassifier.columnHeadersFromColumnSpanningHeader(testCase.input)
            XCTAssertEqual(headers.header1, testCase.header1)
            XCTAssertEqual(headers.header2, testCase.header2)
        }
    }

    func testClassifier() throws {
        for testCase in 1...1 {
            guard let recognizedTexts = recognizedTextsForTestCase(testCase) else {
                XCTFail("Couldn't get recognized texts for Test Case \(testCase)")
                return
            }

            let nutrientsDataFrame = NutritionLabelClassifier.dataFrameOfNutrients(from: recognizedTexts)
            print("🧬 Nutrients for Test Case: \(testCase)")
            print(nutrientsDataFrame)
            continue
            
            var processedNutrients: [Attribute: (recognizedText1: RecognizedText?, recognizedText2: RecognizedText?)] = [:]
            for row in nutrientsDataFrame.rows {
                guard let attribute = row["attribute"] as? Attribute,
                      let recognizedText1 = row["recognizedText1"] as? RecognizedText?,
                      let recognizedText2 = row["recognizedText2"] as? RecognizedText?
                else {
                    XCTFail("Failed to get a parsed nutrient for \(testCase)")
                    return
                }
                
                processedNutrients[attribute] = (recognizedText1, recognizedText2)
            }
            
            guard let expectedNutrientsDataFrame = dataFrameForTestCase(testCase, testCaseFileType: .expectedNutrients) else {
                XCTFail("Couldn't get expected nutrients for Test Case \(testCase)")
                return
            }
//            print(expectedNutrientsDataFrame)
            var expectedNutrients: [Attribute: (string1: String?, string2: String?)] = [:]
            for row in expectedNutrientsDataFrame.rows {
                guard let attributeName = row["attributeString"] as? String,
                      let attribute = Attribute(rawValue: attributeName),
                      let value1 = row["recognizedText1String"] as? String?,
                      let value2 = row["recognizedText2String"] as? String?
                else {
                    XCTFail("Failed to read an expected nutrient for \(testCase)")
                    return
                }
                expectedNutrients[attribute] = (value1, value2)
            }
            
            
            for attribute in expectedNutrients.keys {
                guard let recognizedTexts = processedNutrients[attribute] else {
                    XCTFail("Missing Attribute: \(attribute) for Test Case: \(testCase)")
                    return
                }
                
                XCTAssertEqual(recognizedTexts.recognizedText1?.string, expectedNutrients[attribute]?.string1)
                XCTAssertEqual(recognizedTexts.recognizedText2?.string, expectedNutrients[attribute]?.string2)
            }
        }
    }
    
    //MARK: - Helpers
    func recognizedTextsForTestCase(_ testCase: Int) -> [RecognizedText]? {
        guard let dataFrame = dataFrameForTestCase(testCase) else {
            XCTFail("Couldn't read file for Test Case \(testCase)")
            return nil
        }
        return dataFrame.recognizedTexts
    }
}
