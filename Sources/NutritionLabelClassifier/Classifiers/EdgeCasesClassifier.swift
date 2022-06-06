import Foundation
import VisionSugar

let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

extension Array where Element == Observation {
    func value1(for attribute: Attribute) -> Value? {
        first(where: { $0.attribute == attribute })?.value1
    }
}

class EdgeCasesClassifier: Classifier {
    let recognizedTexts: [RecognizedText]
    var observations: [Observation]

    var pendingObservations: [Observation] = []
    var observationBeingExtracted: Observation? = nil
    var discarded: [RecognizedText] = []

    init(recognizedTexts: [RecognizedText], observations: [Observation]) {
        self.recognizedTexts = recognizedTexts
        self.observations = observations
    }
    
    static func observations(from recognizedTexts: [RecognizedText], priorObservations observations: [Observation]) -> [Observation] {
        EdgeCasesClassifier(recognizedTexts: recognizedTexts, observations: observations)
            .getObservations()
    }
    
    func getObservations() -> [Observation] {
        
        copyMissingZeroValues()
        correctMissingDecimalPlaces()

        findMissedServingAmount()
        findMissingHeaderType1()
        calculateMissingMacroOrEnergyInSingleColumnOfValues()
        
        clearErraneousValue2Extractions()

        return observations
    }
    
    /// If we have only one column of values, and haven’t already assigned `.headerType1`, look for the text `Amount Per Serving` and then manually set `.headerType1` as `.perServing` if found.
    func findMissingHeaderType1() {
        guard !observations.hasTwoColumnsOfValues, !observations.contains(attribute: .headerType1) else {
            return
        }
        for recognizedText in recognizedTexts {
            if let headerType = HeaderType(string: recognizedText.string),
               let observation = Observation(headerType: headerType,
                                             for: .headerType1,
                                             recognizedText: recognizedText)
            {
                observations.append(observation)
            }
        }
    }
    
    func findMissedServingAmount() {
        /// If we haven't got a serving amount yet
        guard !observations.contains(attribute: .servingAmount),
              !observations.contains(attribute: .servingUnit),
              !observations.contains(attribute: .headerServingAmount),
              !observations.contains(attribute: .headerServingUnit)
        else {
            return
        }
        
        /// Look for a `Value` within brackets such as `(170g)` (that hasn't been used already) and assign that.
        for recognizedText in recognizedTexts {
            let regex = #"\(([0-9]*)[ ]*g\)"#
//            let regex = #"([0-9]*)[ ]*g"#
            let groups = recognizedText.string.capturedGroups(using: regex)
            if groups.count == 2,
               let amount = Double(groups[1]),
               let amountObservation = Observation(
                    double: amount,
                    attribute: .servingAmount,
                    recognizedText: recognizedText
               ),
               let unitObservation = Observation(
                    unit: .g,
                    attribute: .servingUnit,
                    recognizedText: recognizedText
               )
            {
                observations.append(amountObservation)
                observations.append(unitObservation)
            }
        }
    }
    
    /** **Release 0.0.117** Correct missing decimal places by first finding values that don't compare to the other column as does the average observation (ie. its smalle or larger than the other, while most others are the opposite)—then attempting to correct these values by either:
     1. Appending a decimal place in the middle if it happens to be a 2-digit integer
     2. Using the average ratio of the values between both columns (in the correct observations) to extrapolate what the value should be
     */
    func correctMissingDecimalPlaces() {
        if observations.mostNutrientsHaveSmallerValue2 {
            for index in observations.indices {
                guard observations[index].smallerValue1,
                      let value2 = observations[index].value2,
                      let value1 = observations[index].value1
                else { continue }
                
                if let newValue = value2.decrementByAdditionOfDecimalPlace(toBeLessThan: value1) {
                    observations[index].valueText2?.value = newValue
                }
                //TODO: Implement fallback
                /**
                 - As a fallback
                     - Get the average ratio between all the valid rows (ie. that satisfy the comparison condition)
                     - Now apply this ratio to the incorrect observations to correct the values.
                 */
            }
        }
        
        if observations.mostNutrientsHaveSmallerValue1 {
            for index in observations.indices {
                guard observations[index].smallerValue2,
                      let value2 = observations[index].value2,
                      let value1 = observations[index].value1
                else { continue }
                
                if let newValue = value1.decrementByAdditionOfDecimalPlace(toBeLessThan: value2) {
                    observations[index].valueText2?.value = newValue
                }
                //TODO: Implement fallback (see above case)
            }
        }
    }

    /// If more than half of value2 is empty, clear it all, assuming we have erraneous reads
    func clearErraneousValue2Extractions() {
        if observations.percentageOfNilValue2 > 0.5 {
            observations = observations.clearingValue2
        }
    }
    
    /// If we have two values worth of data and any of the cells are missing where one value is 0, simply copy that across
    func copyMissingZeroValues() {
        if observations.hasTwoColumnsOfValues {
            for index in observations.indices {
                let observation = observations[index]
                if observation.valueText2 == nil, let value1 = observation.valueText1, value1.value.amount == 0 {
                    observations[index].valueText2 = value1
                }
            }
        }
    }
}
