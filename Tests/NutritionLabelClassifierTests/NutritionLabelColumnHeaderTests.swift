import XCTest
import TabularData

@testable import NutritionLabelClassifier

final class NutritionLabelColumnHeaderTests: XCTestCase {

    let testCases: [(input: String, header: NutritionLabelColumnHeader?)] = [
        /// per100g
        ("Per 100 g", .per100g),
        ("Per 100g", .per100g),
        ("100g", .per100g),
        ("Per 100g", .per100g),

        /// perServing(nil)
        ("Per serving", .perServing(serving: nil)),
        ("Per Serving", .perServing(serving: nil)),
        ("Per serving", .perServing(serving: nil)),
        ("PER SERVE", .perServing(serving: nil)),
        ("Amount per serving", .perServing(serving: nil)),
        ("Amount/Serving", .perServing(serving: nil)),
        ("%DV* Amount/Serving", .perServing(serving: nil)),
        ("trition Amount Per Serving %Daily Value* Amount Per Serving", .perServing(serving: nil)),
        ("Nutrition Facts Amount/Serving %DV* Amount/Serving", .perServing(serving: nil)),

        /// perServing
        ("Per 1 pot", .perServing(serving: "1 pot")),
        ("Serving size: 130g (1 cup)", .perServing(serving: "130g (1 cup)")),
        ("SERVING SIZE: 150g", .perServing(serving: "150g")),

        /// perServingAnd100g
        ("INFORMATION Per 120g Per 100g", .perServingAnd100g(serving: "120g")),
        
        /// per100gAndPerServing
        ("PER 100g 74g (2 tubes)", .per100gAndPerServing(serving: "74g (2 tubes)")),
        ("Nutritional Values (Typical) Per 100 g Per serving (125 g)", .per100gAndPerServing(serving: "serving (125 g)")),
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
