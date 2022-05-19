import XCTest
import SwiftSugar
import TabularData

@testable import NutritionLabelClassifier

let testCases: [(input: String, kcal: [Double], kj: [Double])] = [
    ("Brennwert Energi 735 kJ (177 kcal) 412 kJ (99 kcal)", [177, 99], [735, 412]),
    ("384kJ/91kcal 284kJ/67 kcal", [91, 67], [384, 284]),
    ("94 kcal (395 kJ 75 kcal (315 kJ", [94, 75], [395, 315]),
    ("(117 kcal (491 kJ| 90 kcal (378 kJ)", [117, 90], [491, 378]),
    ("Energy 116kcal 96kcal", [116, 96], []),
    ("Energy 620kj 154 Kj", [], [620, 154]),
    ("113 kcal (475 kJ) 90 kcal (378 kJ)", [113, 90], [475, 378]),
]

final class NLClassifierTests: XCTestCase {
    func testContainsTwoKcalValues() throws {
        for testCase in testCases {
            let kcalValues = NutritionLabelClassifier.kcalValues(from: testCase.input)
            XCTAssertEqual(kcalValues, testCase.kcal)
        }
    }
    
    func testContainsTwoKjValues() throws {
        for testCase in testCases {
            let kjValues = NutritionLabelClassifier.kjValues(from: testCase.input)
            XCTAssertEqual(kjValues, testCase.kj)
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
    
    //MARK: - Helpers
    
    func dataFrameForTestCase(_ caseNumber: Int) -> DataFrame? {
        guard let path = Bundle.module.path(forResource: "\(caseNumber)", ofType: "csv") else {
            XCTFail("Couldn't get path for \"\(caseNumber).csv\"")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        var dataFrame = DataFrame.read(from: url)
        dataFrame?.transformColumn("rectString", { (string: String) -> CGRect in
            return NSCoder.cgRect(for: string)
        })
        return dataFrame
    }
    
    func contentsOfFileForTestCase(_ caseNumber: Int) -> String? {
        guard let path = Bundle.module.path(forResource: "\(caseNumber)", ofType: "csv") else {
            XCTFail("Couldn't get path for \"\(caseNumber).csv\"")
            return nil
        }
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch let error {
            XCTFail("Couldn't read test data file: \"\(caseNumber).csv\": \(error)")
        }
        return nil
    }
}
