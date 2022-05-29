import Foundation
import NutritionLabelClassifier
import XCTest

extension NutritionLabelClassifierTests {

    func compare(classifierOutput observed: Output, withExpectedOutput expected: Output) {
        compare(observedServing: observed.serving, withExpectedServing: expected.serving)
        compare(observedNutrients: observed.nutrients, toExpectedNutrients: expected.nutrients)
    }
    
    func compare(observedServing: Output.Serving?, withExpectedServing expectedServing: Output.Serving?) {
        guard let expectedServing = expectedServing else {
            return
        }
        guard let observedServing = observedServing else {
            XCTFail("Missing observed serving")
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
    
    func compare(observedNutrients: Output.Nutrients, toExpectedNutrients expectedNutrients: Output.Nutrients) {
        compare(observedRows: observedNutrients.rows, withExpectedRows: expectedNutrients.rows)
        compareHeader1(ofObservedNutrients: observedNutrients, withExpectedNutrients: expectedNutrients)
        compareHeader2(ofObservedNutrients: observedNutrients, withExpectedNutrients: expectedNutrients)
    }
    
    func compareHeader1(ofObservedNutrients observedNutrients: Output.Nutrients, withExpectedNutrients expectedNutrients: Output.Nutrients) {
        guard isEqual(observedHeaderText: observedNutrients.headerText1,
                      toExpectedHeaderText: expectedNutrients.headerText1) else {
            XCTFail("Observed Column Header 1 doesn't match")
            return
        }
    }

    func compareHeader2(ofObservedNutrients observedNutrients: Output.Nutrients, withExpectedNutrients expectedNutrients: Output.Nutrients) {
        guard isEqual(observedHeaderText: observedNutrients.headerText2,
                      toExpectedHeaderText: expectedNutrients.headerText2) else {
            XCTFail("Observed Column Header 2 doesn't match")
            return
        }
    }

    func isEqual(observedHeaderText: HeaderText?, toExpectedHeaderText expectedHeaderText: HeaderText?) -> Bool {
        guard let expectedHeaderText = expectedHeaderText else {
            return true
        }
        guard let observedHeaderText = observedHeaderText else {
            print("⚠️ Missing observed column header 1")
            return false
        }
        
        guard observedHeaderText.type == expectedHeaderText.type else {
            print("⚠️ Column header 1 type doesn't match")
            return false
        }

        guard observedHeaderText.unitName == expectedHeaderText.unitName else {
            print("⚠️ Column header 1 sizeName doesn't match")
            return false
        }

        return true
    }
    
    func compare(observedRows: [Output.Nutrients.Row], withExpectedRows expectedRows: [Output.Nutrients.Row]) {
        /// For each expected row
        for expectedRow in expectedRows {
            guard let observedRow = observedRows.first(where: { $0.attribute == expectedRow.attribute }) else {
                XCTFail("Classifier failed to observe expected row for attribute: \(expectedRow.attribute)")
                return
            }
            
            guard observedRow.value1 == expectedRow.value1 else {
                XCTFail("Observed Value1 (\(observedRow.value1?.description ?? "nil")) for Attribute: \(expectedRow.attribute) did not match expectation (\(expectedRow.value1?.description ?? "nil"))")
                return
            }

            guard observedRow.value2 == expectedRow.value2 else {
                XCTFail("Observed Value2 (\(observedRow.value2?.description ?? "nil")) for Attribute: \(expectedRow.attribute) did not match expectation (\(expectedRow.value2?.description ?? "nil"))")
                return
            }
            print("✅ \(expectedRow.attribute)")

        }
    }
}
