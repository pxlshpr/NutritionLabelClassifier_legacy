import XCTest
import TabularData
import VisionSugar

@testable import NutritionLabelClassifier

final class FeatureTests: XCTestCase {

    func testArtefacts() throws {
        testCasesStringsWithArtefacts.forEach {
            let dummyRecognizedText = RecognizedText(id: defaultUUID, rectString: "", candidates: [$0.input])
            XCTAssertEqual(dummyRecognizedText.artefacts, $0.artefacts)
        }
    }

    func testFeatures() throws {
        testCasesStringsWithFeatures.forEach {
            let dummyRecognizedText = RecognizedText(id: defaultUUID, rectString: "", candidates: [$0.input])
            XCTAssertEqual(dummyRecognizedText.features, $0.features)
        }
    }
}
