import XCTest
import TabularData

@testable import NutritionLabelClassifier

final class FeatureTests: XCTestCase {

    func testArtefacts() throws {
        testCasesStringsWithArtefacts.forEach {
            XCTAssertEqual($0.input.artefacts, $0.artefacts)
        }
    }

    func testFeatures() throws {
        testCasesStringsWithFeatures.forEach {
            XCTAssertEqual($0.input.features, $0.features)
        }
    }
}
