import XCTest
import TabularData

@testable import NutritionLabelClassifier

final class NutritionLabelValueTests: XCTestCase {
    
    let testCases: [(input: String, value: NutritionLabelValue?)] = [
        ("9.0 g", NutritionLabelValue(amount: 9, unit: .g)),
        ("9.0g", NutritionLabelValue(amount: 9, unit: .g)),
        ("9 g", NutritionLabelValue(amount: 9, unit: .g)),
        ("9g", NutritionLabelValue(amount: 9, unit: .g)),
        ("0.01 g", NutritionLabelValue(amount: 0.01, unit: .g)),
        ("0.01g", NutritionLabelValue(amount: 0.01, unit: .g)),
        (".01g", NutritionLabelValue(amount: 0.01, unit: .g)),
        
        ("9.0 mg", NutritionLabelValue(amount: 9, unit: .mg)),
        ("9.0mg", NutritionLabelValue(amount: 9, unit: .mg)),
        ("9 mg", NutritionLabelValue(amount: 9, unit: .mg)),
        ("9mg", NutritionLabelValue(amount: 9, unit: .mg)),
        ("0.01 mg", NutritionLabelValue(amount: 0.01, unit: .mg)),
        ("0.01mg", NutritionLabelValue(amount: 0.01, unit: .mg)),
        (".01mg", NutritionLabelValue(amount: 0.01, unit: .mg)),
        
        ("9.0 mcg", NutritionLabelValue(amount: 9, unit: .mcg)),
        ("9.0mcg", NutritionLabelValue(amount: 9, unit: .mcg)),
        ("9 mcg", NutritionLabelValue(amount: 9, unit: .mcg)),
        ("9mcg", NutritionLabelValue(amount: 9, unit: .mcg)),
        ("0.01 mcg", NutritionLabelValue(amount: 0.01, unit: .mcg)),
        ("0.01mcg", NutritionLabelValue(amount: 0.01, unit: .mcg)),
        (".01mcg", NutritionLabelValue(amount: 0.01, unit: .mcg)),
        
        ("9.0 kj", NutritionLabelValue(amount: 9, unit: .kj)),
        ("9.0kJ", NutritionLabelValue(amount: 9, unit: .kj)),
        ("9 kj", NutritionLabelValue(amount: 9, unit: .kj)),
        ("9kcal", NutritionLabelValue(amount: 9, unit: .kcal)),
        ("0.01 ug", NutritionLabelValue(amount: 0.01, unit: .ug)),
        ("0.01ug", NutritionLabelValue(amount: 0.01, unit: .ug)),
        (".01ug", NutritionLabelValue(amount: 0.01, unit: .ug)),
        
        ("9.0 mcag", nil),
        ("9.0ghas", nil),
        ("9 mcgh", nil),
        ("9mcqg", nil),
        ("0.01aa mcg", nil),
        ("0.a01mcg", nil),
        ("a.01mcg", nil),
        
        //MARK: - Test Cases from Test Images 1-15
        
        /// Standard
        ("12.1 g", NutritionLabelValue(amount: 12.1, unit: .g)),
        ("9.0 g", NutritionLabelValue(amount: 9, unit: .g)),
        ("10.9 g", NutritionLabelValue(amount: 10.9, unit: .g)),
        ("8.1 g", NutritionLabelValue(amount: 8.1, unit: .g)),
        ("3.7 g", NutritionLabelValue(amount: 3.7, unit: .g)),
        ("2.7 g", NutritionLabelValue(amount: 2.7, unit: .g)),
        ("0.15 g", NutritionLabelValue(amount: 0.15, unit: .g)),
        ("0.11 g", NutritionLabelValue(amount: 0.11, unit: .g)),
        ("5.5 g", NutritionLabelValue(amount: 5.5, unit: .g)),
        ("4.2 g", NutritionLabelValue(amount: 4.2, unit: .g)),
        ("1.4 g", NutritionLabelValue(amount: 1.4, unit: .g)),
        ("1.1 g", NutritionLabelValue(amount: 1.1, unit: .g)),
        ("0.1 g", NutritionLabelValue(amount: 0.1, unit: .g)),
        ("0.1 g", NutritionLabelValue(amount: 0.1, unit: .g)),
        ("10 mg", NutritionLabelValue(amount: 10, unit: .mg)),
        ("8 mg", NutritionLabelValue(amount: 8, unit: .mg)),
        ("19.5 g", NutritionLabelValue(amount: 19.5, unit: .g)),
        ("15.0 g", NutritionLabelValue(amount: 15, unit: .g)),
        ("0.7 g", NutritionLabelValue(amount: 0.7, unit: .g)),
        ("0.5 g", NutritionLabelValue(amount: 0.5, unit: .g)),
        ("72 mg", NutritionLabelValue(amount: 72, unit: .mg)),
        ("55 mg", NutritionLabelValue(amount: 55, unit: .mg)),
        ("169 mg", NutritionLabelValue(amount: 169, unit: .mg)),
        ("130 mg", NutritionLabelValue(amount: 130, unit: .mg)),
        ("5.4 g", NutritionLabelValue(amount: 5.4, unit: .g)),
        ("43 g", NutritionLabelValue(amount: 43, unit: .g)),
        ("0.1 g", NutritionLabelValue(amount: 0.1, unit: .g)),
        ("0.1 g", NutritionLabelValue(amount: 0.1, unit: .g)),
        ("0g", NutritionLabelValue(amount: 0, unit: .g)),
        ("0 g", NutritionLabelValue(amount: 0, unit: .g)),
        ("4 mg", NutritionLabelValue(amount: 4, unit: .mg)),
        ("3 mg", NutritionLabelValue(amount: 3, unit: .mg)),
        ("14.2 g", NutritionLabelValue(amount: 14.2, unit: .g)),
        ("0.1 g", NutritionLabelValue(amount: 0.1, unit: .g)),
        ("84 mg", NutritionLabelValue(amount: 84, unit: .mg)),
        ("67 mg", NutritionLabelValue(amount: 67, unit: .mg)),
        ("225 mg", NutritionLabelValue(amount: 225, unit: .mg)),
        ("180 mg", NutritionLabelValue(amount: 180, unit: .mg)),
        ("5.6g", NutritionLabelValue(amount: 5.6, unit: .g)),
        ("3.7g", NutritionLabelValue(amount: 3.7, unit: .g)),
        ("9.5g", NutritionLabelValue(amount: 9.5, unit: .g)),
        ("6.3g", NutritionLabelValue(amount: 6.3, unit: .g)),
        ("6.2g", NutritionLabelValue(amount: 6.2, unit: .g)),
        ("4.1 g", NutritionLabelValue(amount: 4.1, unit: .g)),
        ("21.9g", NutritionLabelValue(amount: 21.9, unit: .g)),
        ("14.6g", NutritionLabelValue(amount: 14.6, unit: .g)),
        ("21.3g", NutritionLabelValue(amount: 21.3, unit: .g)),
        ("14.2 g", NutritionLabelValue(amount: 14.2, unit: .g)),
        ("38mg", NutritionLabelValue(amount: 38, unit: .mg)),
        ("124mg", NutritionLabelValue(amount: 124, unit: .mg)),
        ("6.3 g", NutritionLabelValue(amount: 6.3, unit: .g)),
        ("5.0 g", NutritionLabelValue(amount: 5, unit: .g)),
        ("1.6 g", NutritionLabelValue(amount: 1.6, unit: .g)),
        ("1.3 g", NutritionLabelValue(amount: 1.3, unit: .g)),
        ("8 mg", NutritionLabelValue(amount: 8, unit: .mg)),
        ("6 mg", NutritionLabelValue(amount: 6, unit: .mg)),
        ("16.6 g", NutritionLabelValue(amount: 16.6, unit: .g)),
        ("13.3 g", NutritionLabelValue(amount: 13.3, unit: .g)),
        ("0.0 g", NutritionLabelValue(amount: 0, unit: .g)),
        ("0.0 g", NutritionLabelValue(amount: 0, unit: .g)),
        ("88 mg", NutritionLabelValue(amount: 88, unit: .mg)),
        ("70 mg", NutritionLabelValue(amount: 70, unit: .mg)),
        ("200 mg", NutritionLabelValue(amount: 200, unit: .mg)),
        ("160 mg", NutritionLabelValue(amount: 160, unit: .mg)),
        ("70g", NutritionLabelValue(amount: 70, unit: .g)),
        ("7.3g", NutritionLabelValue(amount: 7.3, unit: .g)),
        ("6.8g", NutritionLabelValue(amount: 6.8, unit: .g)),
        ("90g", NutritionLabelValue(amount: 90, unit: .g)),
        ("4.3g", NutritionLabelValue(amount: 4.3, unit: .g)),
        ("5.7g", NutritionLabelValue(amount: 5.7, unit: .g)),
        ("9.5g", NutritionLabelValue(amount: 9.5, unit: .g)),
        ("6.3g", NutritionLabelValue(amount: 6.3, unit: .g)),
        ("6.2 g", NutritionLabelValue(amount: 6.2, unit: .g)),
        ("4.1g", NutritionLabelValue(amount: 4.1, unit: .g)),
        ("17.4g", NutritionLabelValue(amount: 17.4, unit: .g)),
        ("11.6g", NutritionLabelValue(amount: 11.6, unit: .g)),
        ("17.1g", NutritionLabelValue(amount: 17.1, unit: .g)),
        ("11.4g", NutritionLabelValue(amount: 11.4, unit: .g)),
        ("59mg", NutritionLabelValue(amount: 59, unit: .mg)),
        ("39mg", NutritionLabelValue(amount: 39, unit: .mg)),
        ("142 mg", NutritionLabelValue(amount: 142, unit: .mg)),
        ("5.9g", NutritionLabelValue(amount: 5.9, unit: .g)),
        ("4.9 g", NutritionLabelValue(amount: 4.9, unit: .g)),
        ("18.1 g", NutritionLabelValue(amount: 18.1, unit: .g)),
        ("15.1 g", NutritionLabelValue(amount: 15.1, unit: .g)),
        ("18.1 g", NutritionLabelValue(amount: 18.1, unit: .g)),
        ("15.1 g", NutritionLabelValue(amount: 15.1, unit: .g)),
        ("2.2g", NutritionLabelValue(amount: 2.2, unit: .g)),
        ("1.8g", NutritionLabelValue(amount: 1.8, unit: .g)),
        ("0.1g", NutritionLabelValue(amount: 0.1, unit: .g)),
        ("0.1 g", NutritionLabelValue(amount: 0.1, unit: .g)),
        ("0.2g", NutritionLabelValue(amount: 0.2, unit: .g)),
        ("0.2g", NutritionLabelValue(amount: 0.2, unit: .g)),
        ("3.5 g", NutritionLabelValue(amount: 3.5, unit: .g)),
        ("4.4 g", NutritionLabelValue(amount: 4.4, unit: .g)),
        ("12.8 g", NutritionLabelValue(amount: 12.8, unit: .g)),
        ("16.0 g", NutritionLabelValue(amount: 16.0, unit: .g)),
        ("12.7 g", NutritionLabelValue(amount: 12.7, unit: .g)),
        ("15.9 g", NutritionLabelValue(amount: 15.9, unit: .g)),
        ("3.2 g", NutritionLabelValue(amount: 3.2, unit: .g)),
        ("0.06 g", NutritionLabelValue(amount: 0.06, unit: .g)),
        ("0.08 g", NutritionLabelValue(amount: 0.08, unit: .g)),
        ("4.9g", NutritionLabelValue(amount: 4.9, unit: .g)),
        ("6.1g", NutritionLabelValue(amount: 6.1, unit: .g)),
        ("6.9g", NutritionLabelValue(amount: 6.9, unit: .g)),
        ("8.6g", NutritionLabelValue(amount: 8.6, unit: .g)),
        ("6.9g", NutritionLabelValue(amount: 6.9, unit: .g)),
        ("8.6g", NutritionLabelValue(amount: 8.6, unit: .g)),
        ("1.5g", NutritionLabelValue(amount: 1.5, unit: .g)),
        ("1.9g", NutritionLabelValue(amount: 1.9, unit: .g)),
        ("0.2 g", NutritionLabelValue(amount: 0.2, unit: .g)),
        ("0.3g", NutritionLabelValue(amount: 0.3, unit: .g)),
        
        /// To be corrected
        ("17:8 g", NutritionLabelValue(amount: 17.8, unit: .g)),
        ("0:1 mg", NutritionLabelValue(amount: 0.1, unit: .mg)),
        
        /// To be extracted from end
        ("Trans Fat 0g", NutritionLabelValue(amount: 0, unit: .g)),
        ("Cholesterol 0mg", NutritionLabelValue(amount: 0, unit: .mg)),
        ("Sodium 65mg", NutritionLabelValue(amount: 65, unit: .mg)),
        ("Saturated Fat 13g", NutritionLabelValue(amount: 13, unit: .g)),
        ("Trans Fat 0g", NutritionLabelValue(amount: 0, unit: .g)),
        ("Cholesterol 5mg", NutritionLabelValue(amount: 5, unit: .mg)),
        ("Total Carbohydrate 16g", NutritionLabelValue(amount: 16, unit: .g)),
        ("Total Sugars 14g", NutritionLabelValue(amount: 14, unit: .g)),
        ("Protein 2g", NutritionLabelValue(amount: 2, unit: .g)),
        ("Saturated Fat 0g", NutritionLabelValue(amount: 0, unit: .g)),
        ("Trans Fat 0g", NutritionLabelValue(amount: 0, unit: .g)),
        ("Cholesterol 5mg", NutritionLabelValue(amount: 5, unit: .mg)),
        ("Sodium 50mg", NutritionLabelValue(amount: 50, unit: .mg)),
        ("Trans Fat 0g", NutritionLabelValue(amount: 0, unit: .g)),
        ("Sodium 65mg", NutritionLabelValue(amount: 65, unit: .mg)),
        ("(0.2 g", NutritionLabelValue(amount: 0.2, unit: .g)),
        ("Saturated Fat 0g", NutritionLabelValue(amount: 0, unit: .g)),
        ("Trans Fat 0g", NutritionLabelValue(amount: 0, unit: .g)),
        ("Cholesterol 0mg", NutritionLabelValue(amount: 0, unit: .mg)),
        ("Sodium 105mg", NutritionLabelValue(amount: 105, unit: .mg)),
        
        /// Extract from start or middle
        ("186mg 23% RDI*", NutritionLabelValue(amount: 186, unit: .mg)),
        ("Includes 12g Added Sugars 24%", NutritionLabelValue(amount: 12, unit: .g)),
        ("9.5g 14%", NutritionLabelValue(amount: 9.5, unit: .g)),
        ("213mg 27% RDI*", NutritionLabelValue(amount: 213, unit: .mg)),
        ("(0.2 g)", NutritionLabelValue(amount: 0.2, unit: .g)),
        ("Calcium (% RDA) 128 mg (16%)", NutritionLabelValue(amount: 128, unit: .mg)),
//        ("0% Total Carbohydrates 9g %", NutritionLabelValue(amount: 9, unit: .g)),
//        ("0% Total Carbohydrate 20g 7%", NutritionLabelValue(amount: 20, unit: .g)),
        
        
        //384kJ/91kcal 284kJ/67 kcal
        //(117 kcal (491 kJ| 90 kcal (378 kJ)
        //94 kcal (395 kJ) 75 kcal (315 kJ)
        //113 kcal (475 kJ) 90 kcal (378 kJ)

        //396kJ/94kcal
        //495 kJ/118kcal

        //819kJ
        //546kJ
        //553kJ
        //8400kJ
        //256 kJ
        //320 kJ

        // multiples
        //Energy 116kcal 96kcal
        //Vit. D 0mcg 0% Calcium 58mg 4%
        //I Container (150g) Saturated Fat 0g 0% Total Carbohydrate 15g 5%
        //Calories from Fat 0 Cholesterol <5mg 1% Sugars 7g
        //223mg 186mg

        // invalids
        //CALCIUM (20% RI* PER 100g))
        //Caring Suer: Go7z (170g) Saturated Fat
    ]
    
    func testColumnHeaders() throws {
        for testCase in testCases {
            XCTAssertEqual(NutritionLabelValue(string: testCase.input), testCase.value)
        }
    }
}
