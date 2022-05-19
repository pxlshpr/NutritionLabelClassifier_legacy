import XCTest
import TabularData

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
