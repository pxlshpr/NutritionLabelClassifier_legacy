import XCTest
import SwiftSugar
import TabularData
import VisionSugar
import Zip

@testable import NutritionLabelClassifier

let RunLegacyTests = true
//let SingledOutTestCaseId: UUID? = UUID(uuidString: "C132B648-8974-457A-8EE6-824688D901EA")
let SingledOutTestCaseId: UUID? = nil

final class OutputTests: XCTestCase {

    var currentTestCaseId: UUID = defaultUUID
    var observedOutput: Output? = nil
    var expectedOutput: Output? = nil

    func testClassifierUsingZipFile() throws {
        print("🤖 Running Tests on Zip File")
        let filePath = Bundle.module.url(forResource: "NutritionClassifier-Test_Data", withExtension: "zip")!
        let testDataUrl = URL.documents.appendingPathComponent("Test Data", isDirectory: true)
        
        /// Remove directory and create it again
        try FileManager.default.removeItem(at: testDataUrl)
        try FileManager.default.createDirectory(at: testDataUrl, withIntermediateDirectories: true)

        /// Unzip Test Data contents
        try Zip.unzipFile(filePath, destination: testDataUrl, overwrite: true, password: nil)
        
        /// For each UUID in Test Cases/With Lanugage Correction
        for testCaseId in testCaseIds {
            if let singledOutTestCaseId = SingledOutTestCaseId {
                guard testCaseId == singledOutTestCaseId else {
                    continue
                }
            }
            
            try runTestsForTestCase(withId: testCaseId)
        }        
    }
    
    func runTestsForTestCase(withId id: UUID) throws {
        currentTestCaseId = id
        print("🧪 Test Case: \(id)")
        
        guard let array = arrayOfRecognizedTextsForTestCase(withId: id) else {
            XCTFail("Couldn't get array of recognized texts for Test Case \(id)")
            return
        }

        observedOutput = NutritionLabelClassifier.classify(array)
        
        /// Extract `expectedNutrients` from data frame
        guard let expectedDataFrame = dataFrameForTestCase(withId: id, testCaseFileType: .expectedNutrients) else {
            XCTFail("Couldn't get expected nutrients for Test Case \(id)")
            return
        }

        print("📃 Expectations:")
        print(expectedDataFrame)

        /// Create `Output` from test case file too
        guard let expectedOutput = Output(fromExpectedDataFrame: expectedDataFrame) else {
            XCTFail("Couldn't create expected Output from DataFrame for Test Case \(id)")
            return
        }
        self.expectedOutput = expectedOutput

        let dataFrame = NutritionLabelClassifier(arrayOfRecognizedTexts: array).dataFrameOfObservations()
        print("👀 Observations:")
        print(dataFrameWithTextIdsRemoved(from: dataFrame))
        
        try compareOutputs()
        
        print("✅ Passed")
    }
    
    func compareOutputs() throws {
        try compareServings()
        try compareNutrients()
    }
    
    //MARK: - Helpers
    
    func m(_ message: String) -> String {
        "\(message) (\(currentTestCaseId))"
    }
}
