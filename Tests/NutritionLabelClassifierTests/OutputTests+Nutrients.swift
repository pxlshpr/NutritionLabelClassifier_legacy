import Foundation
import NutritionLabelClassifier
import XCTest

extension OutputTests {
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
            print("⚠️ Missing observed column header")
            return false
        }
        
        guard observedHeaderText.type == expectedHeaderText.type else {
            print("⚠️ Column header type doesn't match")
            return false
        }

        guard isEqual(observedHeaderServing: observedHeaderText.serving, toExpectedHeaderServing: expectedHeaderText.serving) else {
            print("⚠️ Header Servings do not match")
            return false
        }

//        if let expectedHeaderServing = expectedHeaderText.serving {
//            guard let observedHeaderServing = observedHeaderText.serving else {
//                print("⚠️ Missing observed column header")
//                return false
//            }
//
//        }
//
        return true
    }
    
    func isEqual(observedHeaderServing: HeaderText.Serving?, toExpectedHeaderServing expectedHeaderServing: HeaderText.Serving?) -> Bool {

        guard observedHeaderServing?.amount == expectedHeaderServing?.amount else {
            print("⚠️ Header serving amounts do not match")
            return false
        }

        guard observedHeaderServing?.unit == expectedHeaderServing?.unit else {
            print("⚠️ Header serving units do not match")
            return false
        }

        guard observedHeaderServing?.unitName == expectedHeaderServing?.unitName else {
            print("⚠️ Header serving unit names do not match")
            return false
        }
        
        guard isEqual(observedHeaderServingEquivalentSize: observedHeaderServing?.equivalentSize, expectedHeaderServingEquivalentSize: expectedHeaderServing?.equivalentSize) else {
            print("⚠️ Header serving equivalent sizes do not match")
            return false
        }

        return true
    }
    
    func isEqual(observedHeaderServingEquivalentSize observedEquivalentSize: HeaderText.Serving.EquivalentSize?, expectedHeaderServingEquivalentSize expectedEquivalentSize: HeaderText.Serving.EquivalentSize?) -> Bool
    {
        guard observedEquivalentSize?.amount == expectedEquivalentSize?.amount else {
            print("⚠️ Header serving equivalent size amounts do not match")
            return false
        }

        guard observedEquivalentSize?.unit == expectedEquivalentSize?.unit else {
            print("⚠️ Header serving equivalent size units do not match")
            return false
        }

        guard observedEquivalentSize?.unitName == expectedEquivalentSize?.unitName else {
            print("⚠️ Header serving equivalent size unit names do not match")
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
