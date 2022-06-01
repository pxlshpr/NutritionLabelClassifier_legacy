import XCTest
import SwiftSugar
import TabularData
import VisionSugar
import Zip
import NutritionLabelClassifier

extension OutputTests {
    
    func compareHeader1() {
        guard let expectedHeaderText = expectedOutput?.nutrients.headerText1 else {
            if observedOutput?.nutrients.headerText1 != nil {
                XCTFail(m("Observed observedOutput.nutrients.headerText1 without an expectation"))
            }
            return
        }
        
        guard let observedHeaderText = observedOutput?.nutrients.headerText1 else {
            XCTFail(m("Expected expectedOutput.nutrients.headerText1 wasn't observed"))
            return
        }

        compareHeaderTexts(observed: observedHeaderText, expected: expectedHeaderText, headerNumber: 1)
    }

    func compareHeader2() {
        guard let expectedHeaderText = expectedOutput?.nutrients.headerText2 else {
            if observedOutput?.nutrients.headerText2 != nil {
                XCTFail(m("Observed observedOutput.nutrients.headerText2 without an expectation"))
            }
            return
        }
        
        guard let observedHeaderText = observedOutput?.nutrients.headerText2 else {
            XCTFail(m("Expected expectedOutput.nutrients.headerText2 wasn't observed"))
            return
        }

        compareHeaderTexts(observed: observedHeaderText, expected: expectedHeaderText, headerNumber: 2)
    }

    func compareHeaderTexts(observed: HeaderText, expected: HeaderText, headerNumber i: Int) {
        XCTAssertEqual(
            observed.type,
            expected.type,
            m("headerText\(i).type — observed: \(observed.type.description) ≠ expected: \(expected.type)")
        )
        compareHeaderServings(observed: observed.serving, expected: expected.serving, headerNumber: i)
    }
    
    func compareHeaderServings(observed: HeaderText.Serving?, expected: HeaderText.Serving?, headerNumber i: Int) {
        guard let expected = expected else {
            if observed != nil {
                XCTFail(m("Observed observedOutput.nutrients.headerText\(i).serving without an expectation"))
            }
            return
        }
        
        guard let observed = observed else {
            XCTFail(m("Expected expectedOutput.nutrients.headerText\(i).serving wasn't observed"))
            return
        }

        XCTAssertEqual(
            observed.amount,
            expected.amount,
            m("headerText\(i).serving.amount — observed: \(observed.amount?.clean ?? "(nil)") ≠ expected: \(expected.amount?.clean ?? "(nil)")")
        )

        XCTAssertEqual(
            observed.unit,
            expected.unit,
            m("headerText\(i).serving.unit — observed: \(observed.unit?.description ?? "(nil)") ≠ expected: \(expected.unit?.description ?? "(nil)")")
        )

        XCTAssertEqual(
            observed.unitName,
            expected.unitName,
            m("headerText\(i).serving.unitName — observed: \(observed.unitName ?? "(nil)") ≠ expected: \(expected.unitName ?? "(nil)")")
        )

        compareHeaderServingEquivalentSizes(
            observed: observed.equivalentSize,
            expected: expected.equivalentSize,
            headerNumber: i)
    }
    
    func compareHeaderServingEquivalentSizes(observed: HeaderText.Serving.EquivalentSize?, expected: HeaderText.Serving.EquivalentSize?, headerNumber i: Int) {
        guard let expected = expected else {
            if observed != nil {
                XCTFail(m("Observed observedOutput.nutrients.headerText\(i).serving.equivalentSize without an expectation"))
            }
            return
        }
        
        guard let observed = observed else {
            XCTFail(m("Expected expectedOutput.nutrients.headerText\(i).serving.equivalent wasn't observed"))
            return
        }

        XCTAssertEqual(
            observed.amount, expected.amount,
            m("headerText\(i).serving.equivalentSize.amount — observed: \(observed.amount.clean) ≠ expected: \(expected.amount.clean)")
        )

        XCTAssertEqual(
            observed.unit, expected.unit,
            m("headerText\(i).serving.equivalentSize.unit — observed: \(observed.unit?.description ?? "(nil)") ≠ expected: \(expected.unit?.description ?? "(nil)")")
        )

        XCTAssertEqual(
            observed.unitName, expected.unitName,
            m("headerText\(i).serving.equivalentSize.unitName — observed: \(observed.unitName ?? "(nil)") ≠ expected: \(expected.unitName ?? "(nil)")")
        )
    }
}
