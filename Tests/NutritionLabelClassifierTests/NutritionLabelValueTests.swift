import XCTest
import TabularData

@testable import NutritionLabelClassifier

final class NutritionLabelValueTests: XCTestCase {

    let testCases: [(input: String, value: NutritionLabelValue?)] = [
        ("9.0", NutritionLabelValue(amount: 9)),
        ("9.0", NutritionLabelValue(amount: 9)),
        ("9", NutritionLabelValue(amount: 9)),
        ("9", NutritionLabelValue(amount: 9)),
        ("0.01", NutritionLabelValue(amount: 0.01)),
        ("0.01", NutritionLabelValue(amount: 0.01)),
        (".01", NutritionLabelValue(amount: 0.01)),
        
        ("9.0 g", NutritionLabelValue(amount: 9, unit: .g)),
        ("9.0g", NutritionLabelValue(amount: 9, unit: .g)),
        ("9 g", NutritionLabelValue(amount: 9, unit: .g)),
        ("9g", NutritionLabelValue(amount: 9, unit: .g)),
        ("0.01 g", NutritionLabelValue(amount: 0.01, unit: .g)),
        ("0.01g", NutritionLabelValue(amount: 0.01, unit: .g)),
        (".01g", NutritionLabelValue(amount: 0.01, unit: .g)),

        ("9.0 mg", NutritionLabelValue(amount: 9, unit: .mg)),
        ("9.0mg", NutritionLabelValue(amount: 9, unit: .mg)),
        ("9 mg", NutritionLabelValue(amount: 9, unit: .mg)),
        ("9mg", NutritionLabelValue(amount: 9, unit: .mg)),
        ("0.01 mg", NutritionLabelValue(amount: 0.01, unit: .mg)),
        ("0.01mg", NutritionLabelValue(amount: 0.01, unit: .mg)),
        (".01mg", NutritionLabelValue(amount: 0.01, unit: .mg)),

        ("9.0 mcg", NutritionLabelValue(amount: 9, unit: .mcg)),
        ("9.0mcg", NutritionLabelValue(amount: 9, unit: .mcg)),
        ("9 mcg", NutritionLabelValue(amount: 9, unit: .mcg)),
        ("9mcg", NutritionLabelValue(amount: 9, unit: .mcg)),
        ("0.01 mcg", NutritionLabelValue(amount: 0.01, unit: .mcg)),
        ("0.01mcg", NutritionLabelValue(amount: 0.01, unit: .mcg)),
        (".01mcg", NutritionLabelValue(amount: 0.01, unit: .mcg)),

        ("9.0 mcag", nil),
        ("9.0ghas", nil),
        ("9 mcgh", nil),
        ("9mcqg", nil),
        ("0.01aa mcg", nil),
        ("0.a01mcg", nil),
        ("a.01mcg", nil),
    ]
    
    func testColumnHeaders() throws {
        for testCase in testCases {
            XCTAssertEqual(NutritionLabelValue(string: testCase.input), testCase.value)
        }
    }
}
