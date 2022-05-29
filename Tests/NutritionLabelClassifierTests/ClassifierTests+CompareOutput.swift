import Foundation
import NutritionLabelClassifier
import XCTest

extension NutritionLabelClassifierTests {

    func compare(classifierOutput observed: Output, withExpectedOutput expected: Output) {
        /// If anything that was expected is missing or is incorrect, fail the test
        /// Decide if we'll be failing tests when we have values in the output that wasn't included in the expected results
        compare(observedRows: observed.nutrients.rows, withExpectedRows: expected.nutrients.rows)
    }
    
    func compare(observedRows: [Output.Nutrients.Row], withExpectedRows expectedRows: [Output.Nutrients.Row]) {
        /// For each expected row
        for expectedRow in expectedRows {
            guard let observedRow = observedRows.first(where: { $0.attribute == expectedRow.attribute }) else {
                XCTFail("Classifier failed to observe expected row for attribute: \(expectedRow.attribute)")
                return
            }
            
            guard observedRow.value1 == expectedRow.value1 else {
                XCTFail("Observed Value1 (\(observedRow.value1?.description ?? "nil")) for Attribute: \(expectedRow.attribute) did not match expectation (\(expectedRow.value1?.description ?? "nil"))")
                return
            }
            print("✅ \(expectedRow.attribute) Value1: Observation \(observedRow.value1?.description ?? "nil") matches Expectation \(expectedRow.value1?.description ?? "nil")")

            guard observedRow.value2 == expectedRow.value2 else {
                XCTFail("Observed Value2 (\(observedRow.value2?.description ?? "nil")) for Attribute: \(expectedRow.attribute) did not match expectation (\(expectedRow.value2?.description ?? "nil"))")
                return
            }
            print("✅ \(expectedRow.attribute) Value2: Observation \(observedRow.value2?.description ?? "nil") matches Expectation \(expectedRow.value2?.description ?? "nil")")

        }
    }
}
