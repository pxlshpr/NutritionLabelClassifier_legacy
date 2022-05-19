import XCTest
import TabularData

@testable import NutritionLabelClassifier

final class NutritionLabelColumnHeaderTests: XCTestCase {
    
    let testCasesPer100 = [
        "per 100 g",
        "Per 100"
    ]
    
    func testPer100Headers() throws {
        for testCase in 1...15 {
            guard let dataFrame = dataFrameForTestCase(testCase) else {
                XCTFail("Couldn't read file for Test Case \(testCase)")
                return
            }
            print("DataFrame for Test Case: \(testCase)")
            print(dataFrame)
        }
    }
}

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
