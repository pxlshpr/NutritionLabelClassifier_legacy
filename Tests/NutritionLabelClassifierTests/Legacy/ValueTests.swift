import XCTest
import TabularData

@testable import NutritionLabelClassifier

final class NutritionLabelValueTests: XCTestCase {
    
    func _testValueAtStartOfString() throws {
        testCasesValueAtStartOfString.forEach {
            XCTAssertEqual(Value(fromString: $0.input), $0.value)
        }
    }
    
    func _testValueFromEntireString() throws {
        for testCase in testCasesValueFromEntireString_Legacy {
            XCTAssertEqual(Value(string: testCase.input), testCase.value)
        }
    }
}
