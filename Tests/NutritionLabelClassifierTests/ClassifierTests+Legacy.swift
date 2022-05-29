import XCTest

@testable import NutritionLabelClassifier

extension NutritionLabelClassifierTests {
    
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

            let classifier = NutritionLabelClassifier(arrayOfRecognizedTexts: arrayOfRecognizedTexts)
            let nutrientsDataFrame = classifier.dataFrameOfNutrients()
//            let nutrientsDataFrame = NutritionLabelClassifier.dataFrameOfNutrients(from: arrayOfRecognizedTexts)

            /// Extract `processedNutrients` from data frame
            var processedNutrients: [Attribute: (value1: Value?, value2: Value?)] = [:]
            for row in nutrientsDataFrame.rows {
                guard let attributeWithId = row["attribute"] as? AttributeText,
                      let valueWithId1 = row["value1"] as? ValueText?,
                      let valueWithId2 = row["value2"] as? ValueText?
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
    
//    func _testClassifierOutput() throws {
//        for testCase in ClassifierOutputTestCases {
//            guard let arrayOfRecognizedTexts = arrayOfRecognizedTextsForTestCase(testCase) else {
//                XCTFail("Couldn't get array of recognized texts for Test Case \(testCase)")
//                return
//            }
//
//            let output = NutritionLabelClassifier.classify(arrayOfRecognizedTexts)
//            let nutrientsDataFrame = NutritionLabelClassifier.dataFrameOfNutrients(from: arrayOfRecognizedTexts)
////            print("🧬 Output: \(output)")
//            print(nutrientsDataFrame)
////            print(dataFrameWithObservationIdsRemoved(from: output))
//
//            /// Extract `expectedNutrients` from data frame
//            guard let expectedDataFrame = dataFrameForTestCase(testCase, testCaseFileType: .expectedNutrients) else {
//                XCTFail("Couldn't get expected nutrients for Test Case \(testCase)")
//                return
//            }
//            print("📃 Expected DataFrame for Test Case: \(testCase)")
//            print(expectedDataFrame)
//
//            let exepectedOutput = Output(fromExpectedDataFrame: expectedDataFrame)
//            print("We've got it")
//            /// Create `Output` from test case file too
//            /// Now use a specialized function that compares the values between what was generated and what was expected
//            /// If anything that was expected is missing or is incorrect, fail the test
//            /// Decide if we'll be failing tests when we have values in the output that wasn't included in the expected results
//        }
//    }
}
