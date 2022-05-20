import XCTest
import TabularData

@testable import NutritionLabelClassifier

enum TestCaseFileType {
    case input
    case expectedNutrients
    case expectedFeatures
    
    func fileName(for testCase: Int) -> String {
        switch self {
        case .input:
            return "\(testCase)"
        case .expectedNutrients:
            return "\(testCase)-nutrients"
        case .expectedFeatures:
            return "\(testCase)-features"
        }
    }
}

func dataFrameForTestCase(_ testCase: Int, testCaseFileType: TestCaseFileType = .input) -> DataFrame? {
    guard let path = Bundle.module.path(forResource: "\(testCaseFileType.fileName(for: testCase))", ofType: "csv") else {
        XCTFail("Couldn't get path for \"\(testCase).csv\"")
        return nil
    }
    let url = URL(fileURLWithPath: path)
    return DataFrame.read(from: url)
}

func f(_ attribute: Attribute, _ a: Double? = nil, _ u: NutritionUnit? = nil) -> Feature {
    let value: Value?
    if let amount = a {
        value = Value(amount: amount, unit: u)
    } else {
        value = nil
    }
    return Feature(attribute: attribute, value: value)
}

func p(_ preposition: Preposition) -> Preposition {
    preposition
}

func v(_ amount: Double, _ unit: NutritionUnit? = nil) -> Value {
    Value(amount: amount, unit: unit)
}

func a(_ attribute: Attribute) -> Attribute {
    attribute
}
