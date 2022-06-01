import Foundation
import NutritionLabelClassifier
import XCTest
    
extension OutputTests {

    func compareServings() {
        
        guard let expectedServing = expectedOutput?.serving else {
            if observedOutput?.serving != nil {
                XCTFail("Serving was observed without an expectation (\(currentTestCaseId))")
            }
            return
        }
        
        guard let observedServing = observedOutput?.serving else {
            XCTFail("Expected Output.Serving wasn't observed (\(currentTestCaseId))")
            return
        }
        
        guard observedServing.amount == expectedServing.amount else {
            XCTFail("Observed serving amount \(observedServing.amount ?? 0) ≠ Expected serving amount \(expectedServing.amount ?? 0)")
            return
        }

        guard observedServing.unit == expectedServing.unit else {
            XCTFail("Serving units do not match")
            return
        }
        
        guard observedServing.unitName == expectedServing.unitName else {
            XCTFail("Serving unit name's do not match")
            return
        }
        
        guard compare(observedEquivalentSize: observedServing.equivalentSize,
                      toExpectedEquivalentSize: expectedServing.equivalentSize) else {
            return
        }
        print("✅ Serving: Equivalent Size")

        guard compare(observedPerContainer: observedServing.perContainer,
                      toExpectedPerContainer: expectedServing.perContainer) else {
            return
        }
        print("✅ Serving: Per Container")

        print("✅ Serving")
    }
    
    func compare(observedEquivalentSize: Output.Serving.EquivalentSize?, toExpectedEquivalentSize expectedEquivalentSize: Output.Serving.EquivalentSize?) -> Bool {
        guard let expectedEquivalentSize = expectedEquivalentSize else {
            return true
        }
        guard let observedEquivalentSize = observedEquivalentSize else {
            XCTFail("Missing equivalent size")
            return false
        }
        
        guard observedEquivalentSize.amount == expectedEquivalentSize.amount else {
            XCTFail("Equivalent size amount's do not match")
            return false
        }
        
        guard observedEquivalentSize.unit == expectedEquivalentSize.unit else {
            XCTFail("Equivalent size unit's do not match")
            return false
        }
        
        guard observedEquivalentSize.sizeName == expectedEquivalentSize.sizeName else {
            XCTFail("Equivalent size unit name's do not match")
            return false
        }
        return true
    }
    
    func compare(observedPerContainer: Output.Serving.PerContainer?, toExpectedPerContainer expectedPerContainer: Output.Serving.PerContainer?) -> Bool {
        guard let expectedPerContainer = expectedPerContainer else {
            return true
        }
        
        guard let observedPerContainer = observedPerContainer else {
            XCTFail("Missing per container")
            return false
        }
        
        guard observedPerContainer.amount == expectedPerContainer.amount else {
            XCTFail("Per Container amount's do not match")
            return false
        }
        
        guard observedPerContainer.name == expectedPerContainer.name else {
            XCTFail("Per Container name's do not match")
            return false
        }
        
        return true
    }
}
