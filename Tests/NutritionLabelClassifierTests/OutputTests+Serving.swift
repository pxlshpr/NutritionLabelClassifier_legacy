import Foundation
import NutritionLabelClassifier
import XCTest
    
extension OutputTests {

    func compareServings() {
        
        guard let expected = expectedOutput?.serving else {
            if observedOutput?.serving != nil {
                XCTFail(m("Observed observedOutput.serving without an expectation"))
            }
            return
        }
        
        guard let observed = observedOutput?.serving else {
            XCTFail(m("Expected expectedOutput.serving wasn't observed"))
            return
        }
        
        XCTAssertEqual(
            observed.amount, expected.amount,
            m("serving.amount — observed: \(observed.amount?.clean ?? "(nil)") ≠ expected: \(expected.amount?.clean ?? "(nil)")")
        )

        XCTAssertEqual(
            observed.unit,
            expected.unit,
            m("serving.unit — observed: \(observed.unit?.description ?? "(nil)") ≠ expected: \(expected.unit?.description ?? "(nil)")")
        )

        XCTAssertEqual(
            observed.unitName,
            expected.unitName,
            m("serving.unitName — observed: \(observed.unitName ?? "(nil)") ≠ expected: \(expected.unitName ?? "(nil)")")
        )
        
        compareServingEquivalentSizes()
        compareServingPerContainers()
    }
    
    func compareServingEquivalentSizes() {
        guard let expected = expectedOutput?.serving?.equivalentSize else {
            if observedOutput?.serving?.equivalentSize != nil {
                XCTFail(m("Observed observedOutput.serving.equivalentSize without an expectation"))
            }
            return
        }
        
        guard let equivalent = observedOutput?.serving?.equivalentSize else {
            XCTFail(m("Expected expectedOutput.serving.equivalentSize wasn't observed"))
            return
        }

        XCTAssertEqual(
            equivalent.amount, expected.amount,
            m("serving.equivalentSize.amount — observed: \(equivalent.amount.clean) ≠ expected: \(expected.amount.clean)")
        )

        XCTAssertEqual(
            equivalent.unit, expected.unit,
            m("serving.equivalentSize.unit — observed: \(equivalent.unit?.description ?? "(nil)") ≠ expected: \(expected.unit?.description ?? "(nil)")")
        )

        XCTAssertEqual(
            equivalent.unitName, expected.unitName,
            m("serving.equivalentSize.unitName — observed: \(equivalent.unitName ?? "(nil)") ≠ expected: \(expected.unitName ?? "(nil)")")
        )
    }
    
    func compareServingPerContainers() {
        guard let expected = expectedOutput?.serving?.perContainer else {
            if observedOutput?.serving?.perContainer != nil {
                XCTFail(m("Observed observedOutput.serving.perContainer without an expectation"))
            }
            return
        }
        
        guard let observed = observedOutput?.serving?.perContainer else {
            XCTFail(m("Expected expectedOutput.serving.perContainer wasn't observed"))
            return
        }

        XCTAssertEqual(
            observed.amount, expected.amount,
            m("serving.perContainer.amount — observed: \(observed.amount.clean) ≠ expected: \(expected.amount.clean)")
        )
        
        XCTAssertEqual(
            observed.name, expected.name,
            m("serving.perContainer.name — observed: \(observed.name ?? "(nil)") ≠ expected: \(expected.name ?? "(nil)")")
        )
    }
}
