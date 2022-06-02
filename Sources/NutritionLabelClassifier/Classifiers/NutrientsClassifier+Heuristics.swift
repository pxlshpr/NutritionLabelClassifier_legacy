import Foundation
import VisionSugar

extension Array where Element == Observation {
    
    var twoColumnedNutrientObservations: [Observation] {
        filter {
            $0.attribute.isNutrientAttribute
            && $0.valueText1 != nil
            && $0.valueText2 != nil
        }
    }

    func checkIfMostNutrientsHave(smallerValue1: Bool) -> Bool {
        var numberOfObservationsWithASmallerValue1: Int = 0
        var numberOfObservationsWithASmallerValue2: Int = 0
        for observation in twoColumnedNutrientObservations {
            guard let value1 = observation.value1, let value2 = observation.value2 else {
                continue
            }
            if value1.amount < value2.amount {
                numberOfObservationsWithASmallerValue1 += 1
            } else if value2.amount < value1.amount {
                numberOfObservationsWithASmallerValue2 += 1
            }
        }
        if smallerValue1 {
            return numberOfObservationsWithASmallerValue1 > numberOfObservationsWithASmallerValue2
        }
        if !smallerValue1 {
            return numberOfObservationsWithASmallerValue2 > numberOfObservationsWithASmallerValue1
        }
        return false
    }
    
    var mostNutrientsHaveSmallerValue1: Bool {
        checkIfMostNutrientsHave(smallerValue1: true)
    }
    var mostNutrientsHaveSmallerValue2: Bool {
        checkIfMostNutrientsHave(smallerValue1: false)
    }
    
    var nutrientsWithSmallerValue2: [Observation] {
        twoColumnedNutrientObservations.filter {
            guard let value1 = $0.value1, let value2 = $0.value2 else { return false }
            return value2.amount < value1.amount
        }
    }

    var nutrientsWithSmallerValue1: [Observation] {
        twoColumnedNutrientObservations.filter {
            guard let value1 = $0.value1, let value2 = $0.value2 else { return false }
            return value1.amount < value2.amount
        }
    }
}

extension Observation {
    var smallerValue2: Bool {
        guard let value1 = value1, let value2 = value2 else { return false }
        return value2.amount < value1.amount
    }
    
    var smallerValue1: Bool {
        guard let value1 = value1, let value2 = value2 else { return false }
        return value1.amount < value2.amount
    }
}
extension NutrientsClassifier {
    
    func checkPostExtractionHeuristics() {
        clearErraneousValue2Extractions()
        copyMissingZeroValues()
        correctValuesMismatchingAverageComparisionCondition()
    }

    /// Fill in the other missing values by simply using the ratio of values for what we had extracted successfully
    //TODO: Remove the (incorrect) assumption we're making that the incorrect value is value2. To facilitate this, we may need to restrict these corrections to macros and energy values, as we can determine which column has the correct values (if any) by using the energy calculation based off the macros (with room for slight errors).
    func correctValuesMismatchingAverageComparisionCondition() {
        /**
         - Add a heuristic at the end of getting all the nutrients that
           - First determines whether `value1` or `value2` is larger (by checking what the majority of the rows return)
           - Goes through each nutrient row and make sure `value2` is `<` or `>` `value1` depending on what was determined
           - If it fails this check
             - First if we have a 2-digit `Int` `Value` for `value2` or `value1`
                 - See if placing a decimal place in between the numbers satisfies the comparison condition.
                 - If it does, correct the value to this
             - As a fallback
                 - Get the average ratio between all the valid rows (ie. that satisfy the comparison condition)
                 - Now apply this ratio to the incorrect observations to correct the values.
         */
        let smallerValue2 = observations.mostNutrientsHaveSmallerValue2
        if smallerValue2 {
            for index in observations.indices {
                guard observations[index].smallerValue1,
                      let value2 = observations[index].value2,
                      let value1 = observations[index].value1
                else { continue }
                
                let newValue = heuristicCorrectedValue2(value2, forValue1: value1)
                observations[index].valueText2?.value = newValue
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
    
    /// If `value2 > value1`, and we have a 2 digit `Value` for `value2`—see if placing a decimal place in between the numbers satisfies this condition and if so, use that value.
    func heuristicCorrectedValue2(_ value2: Value, forValue1 value1: Value) -> Value {
        let valueIsTwoDigitInt = value2.amount >= 10
            && value2.amount < 100
            && value2.amount.isInt

        guard value2.amount >= value1.amount, valueIsTwoDigitInt else {
            return value2
        }

        var value2String = "\(Int(value2.amount))"
        value2String.insert(".", at: value2String.index(value2String.startIndex, offsetBy: 1))
        
        guard let newAmount = Double(value2String) else {
            return value2
        }
        
        return Value(amount: newAmount, unit: value2.unit)
    }
    
    func heuristicRecognizedTextIsPartOfAttribute(_ recognizedText: RecognizedText) -> Bool {
        recognizedText.string.lowercased() == "vitamin"
    }
    
    //MARK: - Helpers
    
}
