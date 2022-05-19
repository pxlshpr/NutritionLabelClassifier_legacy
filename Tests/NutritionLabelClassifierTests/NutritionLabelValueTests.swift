import XCTest
import TabularData

@testable import NutritionLabelClassifier

final class NutritionLabelValueTests: XCTestCase {
    
    static func value(_ amount: Double, u unit: NutritionLabelUnit?) -> NutritionLabelValue {
        NutritionLabelValue(amount: amount, unit: unit)
    }
    
    let testCases: [(input: String, value: NutritionLabelValue?)] = [
        ("9.0 g", value(9, u: .g)),
        ("9.0g", value(9, u: .g)),
        ("9 g", value(9, u: .g)),
        ("9g", value(9, u: .g)),
        ("0.01 g", value(0.01, u: .g)),
        ("0.01g", value(0.01, u: .g)),
        (".01g", value(0.01, u: .g)),
        
        ("9.0 mg", value(9, u: .mg)),
        ("9.0mg", value(9, u: .mg)),
        ("9 mg", value(9, u: .mg)),
        ("9mg", value(9, u: .mg)),
        ("0.01 mg", value(0.01, u: .mg)),
        ("0.01mg", value(0.01, u: .mg)),
        (".01mg", value(0.01, u: .mg)),
        
        ("9.0 mcg", value(9, u: .mcg)),
        ("9.0mcg", value(9, u: .mcg)),
        ("9 mcg", value(9, u: .mcg)),
        ("9mcg", value(9, u: .mcg)),
        ("0.01 mcg", value(0.01, u: .mcg)),
        ("0.01mcg", value(0.01, u: .mcg)),
        (".01mcg", value(0.01, u: .mcg)),
        
        ("9.0 kj", value(9, u: .kj)),
        ("9.0kJ", value(9, u: .kj)),
        ("9 kj", value(9, u: .kj)),
        ("9kcal", value(9, u: .kcal)),
        ("0.01 ug", value(0.01, u: .ug)),
        ("0.01ug", value(0.01, u: .ug)),
        (".01ug", value(0.01, u: .ug)),
        
        ("9.0 mcag", nil),
        ("9.0ghas", nil),
        ("9 mcgh", nil),
        ("9mcqg", nil),
        ("0.01aa mcg", nil),
        ("0.a01mcg", nil),
        ("a.01mcg", nil),
        
        //MARK: - Test Cases from Test Images 1-15
        
        /// Standard
        ("12.1 g", value(12.1, u: .g)),
        ("9.0 g", value(9, u: .g)),
        ("10.9 g", value(10.9, u: .g)),
        ("8.1 g", value(8.1, u: .g)),
        ("3.7 g", value(3.7, u: .g)),
        ("2.7 g", value(2.7, u: .g)),
        ("0.15 g", value(0.15, u: .g)),
        ("0.11 g", value(0.11, u: .g)),
        ("5.5 g", value(5.5, u: .g)),
        ("4.2 g", value(4.2, u: .g)),
        ("1.4 g", value(1.4, u: .g)),
        ("1.1 g", value(1.1, u: .g)),
        ("0.1 g", value(0.1, u: .g)),
        ("0.1 g", value(0.1, u: .g)),
        ("10 mg", value(10, u: .mg)),
        ("8 mg", value(8, u: .mg)),
        ("19.5 g", value(19.5, u: .g)),
        ("15.0 g", value(15, u: .g)),
        ("0.7 g", value(0.7, u: .g)),
        ("0.5 g", value(0.5, u: .g)),
        ("72 mg", value(72, u: .mg)),
        ("55 mg", value(55, u: .mg)),
        ("169 mg", value(169, u: .mg)),
        ("130 mg", value(130, u: .mg)),
        ("5.4 g", value(5.4, u: .g)),
        ("43 g", value(43, u: .g)),
        ("0.1 g", value(0.1, u: .g)),
        ("0.1 g", value(0.1, u: .g)),
        ("0g", value(0, u: .g)),
        ("0 g", value(0, u: .g)),
        ("4 mg", value(4, u: .mg)),
        ("3 mg", value(3, u: .mg)),
        ("14.2 g", value(14.2, u: .g)),
        ("0.1 g", value(0.1, u: .g)),
        ("84 mg", value(84, u: .mg)),
        ("67 mg", value(67, u: .mg)),
        ("225 mg", value(225, u: .mg)),
        ("180 mg", value(180, u: .mg)),
        ("5.6g", value(5.6, u: .g)),
        ("3.7g", value(3.7, u: .g)),
        ("9.5g", value(9.5, u: .g)),
        ("6.3g", value(6.3, u: .g)),
        ("6.2g", value(6.2, u: .g)),
        ("4.1 g", value(4.1, u: .g)),
        ("21.9g", value(21.9, u: .g)),
        ("14.6g", value(14.6, u: .g)),
        ("21.3g", value(21.3, u: .g)),
        ("14.2 g", value(14.2, u: .g)),
        ("38mg", value(38, u: .mg)),
        ("124mg", value(124, u: .mg)),
        ("6.3 g", value(6.3, u: .g)),
        ("5.0 g", value(5, u: .g)),
        ("1.6 g", value(1.6, u: .g)),
        ("1.3 g", value(1.3, u: .g)),
        ("8 mg", value(8, u: .mg)),
        ("6 mg", value(6, u: .mg)),
        ("16.6 g", value(16.6, u: .g)),
        ("13.3 g", value(13.3, u: .g)),
        ("0.0 g", value(0, u: .g)),
        ("0.0 g", value(0, u: .g)),
        ("88 mg", value(88, u: .mg)),
        ("70 mg", value(70, u: .mg)),
        ("200 mg", value(200, u: .mg)),
        ("160 mg", value(160, u: .mg)),
        ("70g", value(70, u: .g)),
        ("7.3g", value(7.3, u: .g)),
        ("6.8g", value(6.8, u: .g)),
        ("90g", value(90, u: .g)),
        ("4.3g", value(4.3, u: .g)),
        ("5.7g", value(5.7, u: .g)),
        ("9.5g", value(9.5, u: .g)),
        ("6.3g", value(6.3, u: .g)),
        ("6.2 g", value(6.2, u: .g)),
        ("4.1g", value(4.1, u: .g)),
        ("17.4g", value(17.4, u: .g)),
        ("11.6g", value(11.6, u: .g)),
        ("17.1g", value(17.1, u: .g)),
        ("11.4g", value(11.4, u: .g)),
        ("59mg", value(59, u: .mg)),
        ("39mg", value(39, u: .mg)),
        ("142 mg", value(142, u: .mg)),
        ("5.9g", value(5.9, u: .g)),
        ("4.9 g", value(4.9, u: .g)),
        ("18.1 g", value(18.1, u: .g)),
        ("15.1 g", value(15.1, u: .g)),
        ("18.1 g", value(18.1, u: .g)),
        ("15.1 g", value(15.1, u: .g)),
        ("2.2g", value(2.2, u: .g)),
        ("1.8g", value(1.8, u: .g)),
        ("0.1g", value(0.1, u: .g)),
        ("0.1 g", value(0.1, u: .g)),
        ("0.2g", value(0.2, u: .g)),
        ("0.2g", value(0.2, u: .g)),
        ("3.5 g", value(3.5, u: .g)),
        ("4.4 g", value(4.4, u: .g)),
        ("12.8 g", value(12.8, u: .g)),
        ("16.0 g", value(16.0, u: .g)),
        ("12.7 g", value(12.7, u: .g)),
        ("15.9 g", value(15.9, u: .g)),
        ("3.2 g", value(3.2, u: .g)),
        ("0.06 g", value(0.06, u: .g)),
        ("0.08 g", value(0.08, u: .g)),
        ("4.9g", value(4.9, u: .g)),
        ("6.1g", value(6.1, u: .g)),
        ("6.9g", value(6.9, u: .g)),
        ("8.6g", value(8.6, u: .g)),
        ("6.9g", value(6.9, u: .g)),
        ("8.6g", value(8.6, u: .g)),
        ("1.5g", value(1.5, u: .g)),
        ("1.9g", value(1.9, u: .g)),
        ("0.2 g", value(0.2, u: .g)),
        ("0.3g", value(0.3, u: .g)),
        
        /// To be corrected
        ("17:8 g", value(17.8, u: .g)),
        ("0:1 mg", value(0.1, u: .mg)),
        
        /// To be extracted from end
        ("Trans Fat 0g", value(0, u: .g)),
        ("Cholesterol 0mg", value(0, u: .mg)),
        ("Sodium 65mg", value(65, u: .mg)),
        ("Saturated Fat 13g", value(13, u: .g)),
        ("Trans Fat 0g", value(0, u: .g)),
        ("Cholesterol 5mg", value(5, u: .mg)),
        ("Total Carbohydrate 16g", value(16, u: .g)),
        ("Total Sugars 14g", value(14, u: .g)),
        ("Protein 2g", value(2, u: .g)),
        ("Saturated Fat 0g", value(0, u: .g)),
        ("Trans Fat 0g", value(0, u: .g)),
        ("Cholesterol 5mg", value(5, u: .mg)),
        ("Sodium 50mg", value(50, u: .mg)),
        ("Trans Fat 0g", value(0, u: .g)),
        ("Sodium 65mg", value(65, u: .mg)),
        ("(0.2 g", value(0.2, u: .g)),
        ("Saturated Fat 0g", value(0, u: .g)),
        ("Trans Fat 0g", value(0, u: .g)),
        ("Cholesterol 0mg", value(0, u: .mg)),
        ("Sodium 105mg", value(105, u: .mg)),
        
        /// Extract from start or middle
        ("186mg 23% RDI*", value(186, u: .mg)),
        ("Includes 12g Added Sugars 24%", value(12, u: .g)),
        ("9.5g 14%", value(9.5, u: .g)),
        ("213mg 27% RDI*", value(213, u: .mg)),
        ("(0.2 g)", value(0.2, u: .g)),
        ("Calcium (% RDA) 128 mg (16%)", value(128, u: .mg)),
        
        ("819kJ", value(819, u: .kj)),
        ("546kJ", value(546, u: .kj)),
        ("553kJ", value(553, u: .kj)),
        ("8400kJ", value(8400, u: .kj)),
        ("256 kJ", value(256, u: .kj)),
        ("320 kJ", value(320, u: .kj)),
        
        /// Need to extract percent first
        ("0% Total Carbohydrates 9g %", value(9, u: .g)),
        ("0% Total Carbohydrate 20g 7%", value(20, u: .g)),
        
        /// invalids
        ("CALCIUM (20% RI* PER 100g))", nil), /// invalidated by "PER 100g"
        ("CALCIUM 20% RI* PER 100g", nil), /// invalidated by "PER 100g"
        ("Caring Suer: Go7z (170g) Saturated Fat", nil), /// invalidated by '7' in text before value
        ("Serving Size: Something (170g) Saturated Fat", nil), /// invalidated by semi-colon before value
        ("Serving Size Something (170g) Saturated Fat", nil), /// invalidated by extra-large value

        /// both energy values
        ("396kJ/94kcal", value(396, u: .kj)),
        ("495 kJ/118kcal", value(495, u: .kj)),

        /// 4 energy values
//        ("384kJ/91kcal 284kJ/67 kcal", value(0, u: .kj)),
//        ("(117 kcal (491 kJ| 90 kcal (378 kJ)", value(0, u: .kj)),
//        ("94 kcal (395 kJ) 75 kcal (315 kJ)", value(0, u: .kj)),
//        ("113 kcal (475 kJ) 90 kcal (378 kJ)", value(0, u: .kj)),

        /// multiples
//        ("Energy 116kcal 96kcal", value(0, u: .kj)),
//        ("223mg 186mg", value(0, u: .kj)),
        
        // MARK: - Erranousely parsed values (should have been detected multiple attributes)
        
        /// `Vitamin D` and `Calcium`
//        ("Vit. D 0mcg 0% Calcium 58mg 4%", value(0, u: .kj)),
        
        /// `Saturated Fat` and `Carbohydrate`
//        ("I Container (150g) Saturated Fat 0g 0% Total Carbohydrate 15g 5%", value(0, u: .kj)),
        
        /// `Cholesterol` and `Sugar`
//        ("Calories from Fat 0 Cholesterol <5mg 1% Sugars 7g", value(0, u: .kj)),
    ]
    
    func testColumnHeaders() throws {
        for testCase in testCases {
            XCTAssertEqual(NutritionLabelValue(string: testCase.input), testCase.value)
        }
    }
}
