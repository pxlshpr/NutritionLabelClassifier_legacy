import XCTest
import SwiftSugar
import TabularData

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

let testCasesForColumnSpanningHeader: [(input: String, header1: NutritionLabelColumnHeader?, header2: NutritionLabelColumnHeader?)] = [
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
        for testCase in 1...15 {
            guard let dataFrame = dataFrameForTestCase(testCase) else {
                XCTFail("Couldn't read file for Test Case \(testCase)")
                return
            }
            print("DataFrame for Test Case: \(testCase)")
            print(dataFrame)
        }
    }    
}
