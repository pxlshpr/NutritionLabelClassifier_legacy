import XCTest
import TabularData

@testable import NutritionLabelClassifier

final class NutritionLabelColumnHeaderTests: XCTestCase {

    let testCases: [(input: String, header: NutritionLabelColumnHeader?)] = [
        ("Per 100 g", nil),
        ("Per 100g", nil),
        ("100g", nil),
        ("Per 100g", nil),

        ("Per serving", nil),
        ("Per Serving", nil),
        ("Per serving", nil),
        ("PER SERVE", nil),
        ("Amount per serving", nil),
        ("Amount/Serving", nil),
        ("%DV* Amount/Serving", nil),

        ("Per 1 pot", nil),
        ("Serving size: 130g (1 cup)", nil),
        ("SERVING SIZE: 150g", nil),

        ("PER 100g 74g (2 tubes)", nil),
        ("INFORMATION Per 120g Per 100g", nil),
        ("Nutritional Values (Typical) Per 100 g Per serving (125 g)", nil),

        ("trition Amount Per Serving %Daily Value* Amount Per Serving", nil),
        ("Nutrition Facts Amount/Serving %DV* Amount/Serving", nil)
    ]
    
    func testColumnHeaders() throws {
        for testCase in testCases {
            XCTAssertEqual(NutritionLabelColumnHeader(string: testCase.input), testCase.header)
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
