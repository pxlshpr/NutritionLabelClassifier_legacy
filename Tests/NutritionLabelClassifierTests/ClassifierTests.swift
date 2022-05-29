import XCTest
import SwiftSugar
import TabularData
import VisionSugar
import Zip

@testable import NutritionLabelClassifier

final class NutritionLabelClassifierTests: XCTestCase {
    func _testClassifierUsingZipFile() throws {
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
    
    func testCase(withId id: UUID) throws {
        print("🧪 Test Case: \(id)")
        
        guard let array = arrayOfRecognizedTextsForTestCase(withId: id) else {
            XCTFail("Couldn't get array of recognized texts for Test Case \(id)")
            return
        }

        let classifierOutput = NutritionLabelClassifier.classify(array)
        
        /// Extract `expectedNutrients` from data frame
        guard let expectedDataFrame = dataFrameForTestCase(withId: id, testCaseFileType: .expectedNutrients) else {
            XCTFail("Couldn't get expected nutrients for Test Case \(id)")
            return
        }
        
        /// Create `Output` from test case file too
        guard let expectedOutput = Output(fromExpectedDataFrame: expectedDataFrame) else {
            XCTFail("Couldn't create expected Output from DataFrame for Test Case \(id)")
            return
        }
        
        /// Now use a specialized function that compares the values between what was generated and what was expected
        compare(classifierOutput: classifierOutput, withExpectedOutput: expectedOutput)
    }
}
