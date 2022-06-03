import XCTest
import TabularData

@testable import NutritionLabelClassifier

//TODO: Remove this
final class HeaderStringTests: XCTestCase {

    let testCases: [(input: String, header: HeaderString?)] = [
        /// per100g
        ("Per 100 g", .per100),
        ("Per 100g", .per100),
        ("100g", .per100),
        ("Per 100g", .per100),
        ("SERVE PER 100g", .per100),

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

        /// perServingAnd100g
        ("INFORMATION Per 120g Per 100g", .perServingAnd100(serving: "120g")),
        
        /// per100gAndPerServing
        ("PER 100g 74g (2 tubes)", .per100AndPerServing(serving: "74g (2 tubes)")),
        ("Nutritional Values (Typical) Per 100 g Per serving (125 g)", .per100AndPerServing(serving: "serving (125 g)")),
    ]
    
    func testColumnHeaders() throws {
        guard SingledOutTestCaseId == nil else { return }
        for testCase in testCases {
            XCTAssertEqual(
                HeaderString(string: testCase.input),
                testCase.header,
                "for '\(testCase.input)'"
            )
        }
    }
}
