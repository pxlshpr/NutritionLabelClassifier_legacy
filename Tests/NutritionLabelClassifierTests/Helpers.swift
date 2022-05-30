import XCTest
import TabularData

@testable import NutritionLabelClassifier

let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

enum TestCaseFileType: String {
    case input
    case inputWithoutLanguageCorrection
    case expectedNutrients
    case expectedFeatures
    
    func fileName(for testCase: Int) -> String {
        switch self {
        case .input:
            return "\(testCase)"
        case .inputWithoutLanguageCorrection:
            return "\(testCase)-without_language_correction"
        case .expectedNutrients:
            return "\(testCase)-nutrients"
        case .expectedFeatures:
            return "\(testCase)-features"
        }
    }
    
    var directoryUrl: URL {
        let testDataUrl = URL.documents.appendingPathComponent("Test Data", isDirectory: true)
        let testCasesUrl = testDataUrl.appendingPathComponent("Test Cases", isDirectory: true)
        switch self {
        case .input:
            return testCasesUrl.appendingPathComponent("With Language Correction", isDirectory: true)
        case .inputWithoutLanguageCorrection:
            return testCasesUrl.appendingPathComponent("Without Language Correction", isDirectory: true)
        case .expectedNutrients:
            return testDataUrl.appendingPathComponent("Expectations", isDirectory: true)
        default:
            return URL.documents
        }
    }
}

func dataFrameForTestCase(withId id: UUID, testCaseFileType type: TestCaseFileType = .input) -> DataFrame? {
    let csvUrl = type.directoryUrl.appendingPathComponent("\(id).csv", isDirectory: false)
    do {
        return try DataFrame(contentsOfCSVFile: csvUrl, types: [.double:.double])
    } catch {
        print("Error reading CSV: \(error)")
        return nil
    }
}


func dataFrameForTestCase(_ testCase: Int, testCaseFileType: TestCaseFileType = .input) -> DataFrame? {
    guard let path = Bundle.module.path(forResource: "\(testCaseFileType.fileName(for: testCase))", ofType: "csv") else {
        XCTFail("Couldn't get path for \"\(testCaseFileType.fileName(for: testCase))\" for testCaseFileType: \(testCaseFileType.rawValue)")
        return nil
    }
    let url = URL(fileURLWithPath: path)
    do {
        return try DataFrame(
            contentsOfCSVFile: url,
            types: [.double:.double]
        )
    } catch {
        print("Error reading CSV: \(error)")
        return nil
    }
//    return DataFrame.read(from: url)
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

func ap(_ preposition: Preposition) -> NutrientArtefact {
    NutrientArtefact(preposition: preposition, textId: defaultUUID)
}

func av(_ amount: Double, _ unit: NutritionUnit? = nil) -> NutrientArtefact {
    NutrientArtefact(value: Value(amount: amount, unit: unit), textId: defaultUUID)
}

func aa(_ attribute: Attribute) -> NutrientArtefact {
    NutrientArtefact(attribute: attribute, textId: defaultUUID)
}
