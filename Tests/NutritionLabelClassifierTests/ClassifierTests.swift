import XCTest
import SwiftSugar
import TabularData
import VisionSugar
import Zip

@testable import NutritionLabelClassifier

let RunLegacyTests = false
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

    func testCase(withId id: UUID) throws {
        print("🧪 Test Case: \(id)")
        
        guard let array = arrayOfRecognizedTextsForTestCase(withId: id) else {
            XCTFail("Couldn't get array of recognized texts for Test Case \(id)")
            return
        }

        let output = NutritionLabelClassifier.classify(array)
//            let nutrientsDataFrame = NutritionLabelClassifier.dataFrameOfNutrients(from: arrayOfRecognizedTexts)
//            print("🧬 Output: \(output)")
//            print(dataFrameWithObservationIdsRemoved(from: output))
        
        /// Extract `expectedNutrients` from data frame
        guard let expectedDataFrame = dataFrameForTestCase(withId: id, testCaseFileType: .expectedNutrients) else {
            XCTFail("Couldn't get expected nutrients for Test Case \(id)")
            return
        }
        print("👀 Expected DataFrame for Test Case: \(id)")
        print(expectedDataFrame)
        
        let exepectedOutput = Output(fromExpectedDataFrame: expectedDataFrame)
        print("We've got it")
        /// Create `Output` from test case file too
        /// Now use a specialized function that compares the values between what was generated and what was expected
        /// If anything that was expected is missing or is incorrect, fail the test
        /// Decide if we'll be failing tests when we have values in the output that wasn't included in the expected results
    }
    
    func testClassifierUsingZipFile() throws {
        print(URL.documents)
        let filePath = Bundle.module.url(forResource: "NutritionClassifier-Test_Data", withExtension: "zip")!
        let testDataUrl = URL.documents.appendingPathComponent("Test Data", isDirectory: true)
        
        /// Remove directory and create it again
        try FileManager.default.removeItem(at: testDataUrl)
        try FileManager.default.createDirectory(at: testDataUrl, withIntermediateDirectories: true)

        /// Unzip Test Data contents
        try Zip.unzipFile(filePath, destination: testDataUrl, overwrite: true, password: nil, progress: { (progress) -> () in
            print(progress)
        })
        
        /// For each UUID in Test Cases/With Lanugage Correction
        for testCaseId in testCaseIds {
            try testCase(withId: testCaseId)
        }
        /// Get its associated recognized texts file, and expectations file and feed these to a test function

//        let zipFilePath = documentsFolder.appendingPathComponent("archive.zip")
//        try Zip.zipFiles([filePath], zipFilePath: zipFilePath, password: "password", progress: { (progress) -> () in
//            print(progress)
//        }) //Zip
//
//        }
//        catch {
//          print("Something went wrong")
//        }
        
    }
    
    func testClassifier() throws {
        guard RunLegacyTests else { return }
//        for testCase in 6...6 {
        for testCase in ClassifierTestCases {
//        for testCase in 23...23 {
            
//            guard let recognizedTexts = recognizedTextsForTestCase(testCase) else {
//                XCTFail("Couldn't get recognized texts for Test Case \(testCase)")
//                return
//            }
//
//            let nutrientsDataFrame = NutritionLabelClassifier.dataFrameOfNutrients(from: recognizedTexts)

            guard let arrayOfRecognizedTexts = arrayOfRecognizedTextsForTestCase(testCase) else {
                XCTFail("Couldn't get array of recognized texts for Test Case \(testCase)")
                return
            }

            let nutrientsDataFrame = NutritionLabelClassifier.dataFrameOfNutrients(from: arrayOfRecognizedTexts)

            /// Extract `processedNutrients` from data frame
            var processedNutrients: [Attribute: (value1: Value?, value2: Value?)] = [:]
            for row in nutrientsDataFrame.rows {
                guard let attributeWithId = row["attribute"] as? AttributeWithId,
                      let valueWithId1 = row["value1"] as? ValueWithId?,
                      let valueWithId2 = row["value2"] as? ValueWithId?
                else {
                    XCTFail("Failed to get a processed nutrient for \(testCase)")
                    return
                }
                
                processedNutrients[attributeWithId.attribute] = (valueWithId1?.value, valueWithId2?.value)
            }
            
            print("🧬 Nutrients for Test Case: \(testCase)")
            print(dataFrameWithObservationIdsRemoved(from: nutrientsDataFrame))

            /// Extract `expectedNutrients` from data frame
            guard let expectedNutrientsDataFrame = dataFrameForTestCase(testCase, testCaseFileType: .expectedNutrients) else {
                XCTFail("Couldn't get expected nutrients for Test Case \(testCase)")
                return
            }
            print("📃 Expected Nutrients for Test Case: \(testCase)")
            print(expectedNutrientsDataFrame)

            var expectedNutrients: [Attribute: (value1: Value?, value2: Value?)] = [:]
            for row in expectedNutrientsDataFrame.rows {
                guard let attributeName = row["attributeString"] as? String,
                      let attribute = Attribute(rawValue: attributeName),
                      let value1String = row["value1String"] as? String?,
                      let value2String = row["value2String"] as? String?
                else {
                    XCTFail("Failed to read an expected nutrient for \(row) in Test Case: \(testCase)")
                    return
                }
                
                guard value1String != nil || value2String != nil else {
                    continue
                }
                
                var value1: Value? = nil
                if let value1String = value1String {
                    guard let value = Value(fromString: value1String) else {
                        XCTFail("Failed to convert value1String: \(value1String) for \(testCase)")
                        return
                    }
                    value1 = value
                }
                
                var value2: Value? = nil
                if let value2String = value2String {
                    guard let value = Value(fromString: value2String) else {
                        XCTFail("Failed to convert value2String: \(value2String) for \(testCase)")
                        return
                    }
                    value2 = value
                }

                
                expectedNutrients[attribute] = (value1, value2)
            }
            
            for attribute in expectedNutrients.keys {
                guard let values = processedNutrients[attribute] else {
                    XCTFail("Missing Attribute: \(attribute) for Test Case: \(testCase)")
                    return
                }
                XCTAssertEqual(values.value1, expectedNutrients[attribute]?.value1, "TestCase: \(testCase), Attribute: \(attribute)")
                XCTAssertEqual(values.value2, expectedNutrients[attribute]?.value2, "TestCase: \(testCase), Attribute: \(attribute)")
            }
        }
    }
    
    func testClassifierOutput() throws {
        for testCase in ClassifierOutputTestCases {
            guard let arrayOfRecognizedTexts = arrayOfRecognizedTextsForTestCase(testCase) else {
                XCTFail("Couldn't get array of recognized texts for Test Case \(testCase)")
                return
            }

            let output = NutritionLabelClassifier.classify(arrayOfRecognizedTexts)
            let nutrientsDataFrame = NutritionLabelClassifier.dataFrameOfNutrients(from: arrayOfRecognizedTexts)
//            print("🧬 Output: \(output)")
            print(nutrientsDataFrame)
//            print(dataFrameWithObservationIdsRemoved(from: output))
            
            /// Extract `expectedNutrients` from data frame
            guard let expectedDataFrame = dataFrameForTestCase(testCase, testCaseFileType: .expectedNutrients) else {
                XCTFail("Couldn't get expected nutrients for Test Case \(testCase)")
                return
            }
            print("📃 Expected DataFrame for Test Case: \(testCase)")
            print(expectedDataFrame)
            
            let exepectedOutput = Output(fromExpectedDataFrame: expectedDataFrame)
            print("We've got it")
            /// Create `Output` from test case file too
            /// Now use a specialized function that compares the values between what was generated and what was expected
            /// If anything that was expected is missing or is incorrect, fail the test
            /// Decide if we'll be failing tests when we have values in the output that wasn't included in the expected results
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
        newDataFrame.transformColumn("value1") { (valueWithId: ValueWithId?) -> Value? in
            return valueWithId?.value
        }
        newDataFrame.transformColumn("value2") { (valueWithId: ValueWithId?) -> Value? in
            return valueWithId?.value
        }
        return newDataFrame
    }
}
