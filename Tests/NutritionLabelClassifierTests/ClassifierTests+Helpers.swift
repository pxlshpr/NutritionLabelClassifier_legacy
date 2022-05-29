import XCTest
import SwiftSugar
import TabularData
import VisionSugar
import Zip

@testable import NutritionLabelClassifier

let RunLegacyTests = true
let ClassifierTestCases = 1...23
let ClassifierOutputTestCases = 3...3
//let ClassifierTestCases = 100...100
//let ClassifierOutputTestCases = 100...100

let testCasesForColumnSpanningEnergy: [(input: String, kcal: [Double], kj: [Double])] = [
    ("Brennwert Energi 735 kJ (177 kcal) 412 kJ (99 kcal)", [177, 99], [735, 412]),
    ("384kJ/91kcal 284kJ/67 kcal", [91, 67], [384, 284]),
    ("94 kcal (395 kJ 75 kcal (315 kJ", [94, 75], [395, 315]),
    ("(117 kcal (491 kJ| 90 kcal (378 kJ)", [117, 90], [491, 378]),
    ("Energy 116kcal 96kcal", [116, 96], []),
    ("Energy 620kj 154 Kj", [], [620, 154]),
    ("113 kcal (475 kJ) 90 kcal (378 kJ)", [113, 90], [475, 378]),
]

let testCasesForColumnSpanningHeader: [(input: String, header1: ColumnHeaderText?, header2: ColumnHeaderText?)] = [
    ("PER 100g 74g (2 tubes)", .per100g, .perServing(serving: "74g (2 tubes)")),
    ("Nutritional Values (Typical) Per 100 g Per serving (125 g)", .per100g, .perServing(serving: "serving (125 g)"))
]

extension NutritionLabelClassifierTests {
 
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
    
    var testCaseIds: [UUID] {
        let url = URL.documents
            .appendingPathComponent("Test Data", isDirectory: true)
            .appendingPathComponent("Test Cases", isDirectory: true)
            .appendingPathComponent("With Language Correction", isDirectory: true)
        let files: [URL]
        do {
            files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        } catch {
            print("Error getting Test Case Files: \(error)")
            files = []
        }
        return files.compactMap { UUID(uuidString: $0.lastPathComponent.replacingOccurrences(of: ".csv", with: "")) }
    }
    
    //MARK: - Helpers
    func recognizedTextsForTestCase(_ testCase: Int) -> [RecognizedText]? {
        guard let dataFrame = dataFrameForTestCase(testCase) else {
            XCTFail("Couldn't read file for Test Case \(testCase)")
            return nil
        }
        
        return dataFrame.recognizedTexts
    }
    
    //MARK: - Helpers
    func arrayOfRecognizedTextsForTestCase(_ testCase: Int) -> [[RecognizedText]]? {
        guard let recognizedTexts = dataFrameForTestCase(testCase)?.recognizedTexts else {
            XCTFail("Couldn't read file for Test Case \(testCase)")
            return nil
        }

        guard let recognizedTextsWithoutLanugageCorrection = dataFrameForTestCase(testCase, testCaseFileType: .inputWithoutLanguageCorrection)?.recognizedTexts else {
            XCTFail("Couldn't read file for Test Case \(testCase) (Without Lanuage Correction)")
            return nil
        }

        return [recognizedTexts, recognizedTextsWithoutLanugageCorrection]
    }

    func arrayOfRecognizedTextsForTestCase(withId id: UUID) -> [[RecognizedText]]? {
        guard let withLC = dataFrameForTestCase(withId: id, testCaseFileType: .input)?.recognizedTexts else {
            XCTFail("Couldn't read file for Test Case \(id)")
            return nil
        }

        guard let withoutLC = dataFrameForTestCase(withId: id, testCaseFileType: .inputWithoutLanguageCorrection)?.recognizedTexts else {
            XCTFail("Couldn't read file for Test Case \(id)")
            return nil
        }

        return [withLC, withoutLC]
    }

    func dataFrameWithObservationIdsRemoved(from dataFrame: DataFrame) -> DataFrame {
        var newDataFrame = dataFrame
        newDataFrame.transformColumn("value1") { (valueWithId: IdentifiableValue?) -> Value? in
            return valueWithId?.value
        }
        newDataFrame.transformColumn("value2") { (valueWithId: IdentifiableValue?) -> Value? in
            return valueWithId?.value
        }
        return newDataFrame
    }
}
