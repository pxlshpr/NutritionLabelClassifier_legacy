import XCTest

@testable import NutritionLabelClassifier

let testCasesStringsWithArtefacts: [(input: String, artefacts: [AnyHashable])] = [
    ("ENERGY", [a(.energy)]),
    ("Energy", [a(.energy)]),
    ("Energy 116kcal 96kcal", [a(.energy), v(116, .kcal), v(96, .kcal)]),

    ("CARBOHYDRATE", [a(.carbohydrate)]),
    ("Carbohydrate", [a(.carbohydrate)]),
    ("Carbohydrate 4", [a(.carbohydrate), v(4)]),
    ("Total Carbohydrate 16g", [a(.carbohydrate), v(16, .g)]),
    ("0% Total Carbohydrate 20g 7%", [v(0, .p), a(.carbohydrate), v(20, .g), v(7, .p)]),
    ("0% Total Carbohydrate 19g 6%", [v(0, .p), a(.carbohydrate), v(19, .g), v(6, .p)]),
    ("0% Total Carbohydrates 9g %", [v(0, .p), a(.carbohydrate), v(9, .g)]),

    ("SUGARS", [a(.sugar)]),
    ("sugars", [a(.sugar)]),
    ("of which sugars", [a(.sugar)]),
    ("- SUGARS", [a(.sugar)]),
    ("Sugars 19g", [a(.sugar), v(19, .g)]),
    ("Sugars 9g", [a(.sugar), v(9, .g)]),
    ("Total Sugars 14g", [a(.sugar), v(14, .g)]),
    ("2% Sugars 18g", [v(2, .p), a(.sugar), v(18, .g)]),
    
    //TODO: Handle edge case of "Includes" by reading value before it}
    ("Includes 12g Added Sugars 24%", [p(.includes), v(12, .g), a(.sugar), v(24, .p)]),

    ("Dietary Fibre", [a(.dietaryFibre)]),

    ("FAT, TOTAL", [a(.fat)]),
    ("Fat", [a(.fat)]),

    ("Saturated Fat", [a(.saturatedFat)]),
    ("-SATURATED", [a(.saturatedFat)]),
    ("Caring Suer: Go7z (170g) Saturated Fat", [v(170, .g), a(.saturatedFat)]),
    ("Saturated Fat 13g", [a(.saturatedFat), v(13, .g)]),
    ("Saturated Fat 0g", [a(.saturatedFat), v(0, .g)]),

    ("Trans Fat", [a(.transFat)]),
    ("Trans Fat 0g", [a(.transFat), v(0, .g)]),

    ("Cholesterol", [a(.cholesterol)]),
    ("Cholesterol 0mg", [a(.cholesterol), v(0, .mg)]),
    ("Cholesterol 5mg", [a(.cholesterol), v(5, .mg)]),

    ("PROTEIN", [a(.protein)]),
    ("Protein", [a(.protein)]),
    ("Protein 2g", [a(.protein), v(2, .g)]),
    ("Protein 4", [a(.protein), v(4)]),
    ("0% Protein 14g", [v(0, .p), a(.protein), v(14, .g)]),
    ("2% Protein 12g", [v(2, .p), a(.protein), v(12, .g)]),
    ("3% Protein 15g", [v(3, .p), a(.protein), v(15, .g)]),
    ("0% Protein 23g", [v(0, .p), a(.protein), v(23, .g)]),

    ("SALT", [a(.salt)]),
    ("Salt", [a(.salt)]),
    ("Salt Equivalent", [a(.salt)]),
    ("(equivalent as salt)", [a(.salt)]),

    ("SODIUM", [a(.sodium)]),
    ("Sodium", [a(.sodium)]),
    ("Sodium 65mg", [a(.sodium), v(65, .mg)]),
    ("Sodium 25mq", [a(.sodium), v(25, .mg)]),
    ("Sodium 50mg", [a(.sodium), v(50, .mg)]),
    ("Sodium 105mg", [a(.sodium), v(105, .mg)]),
    ("of which sodium", [a(.sodium)]),

    ("CALCIUM (20% RI* PER 100g))", [a(.calcium), v(20, .p), p(.referenceIntakePer), v(100, .g)]),
    ("CALCIUM", [a(.calcium)]),
    ("Calcium", [a(.calcium)]),
    ("Calcium (% RDA) 128 mg (16%)", [a(.calcium), v(128, .mg), v(16, .p)]),

    //MARK: - Multiples
    ("I Container (150g) Saturated Fat 0g 0% Total Carbohydrate 15g 5%",
     [v(150, .g), a(.saturatedFat), v(0, .g), v(0, .p), a(.carbohydrate), v(15, .g), v(5, .p)]),
    
    ("Calories from Fat 0 Cholesterol <5mg 1% Sugars 7g",
     [v(0), a(.cholesterol), v(5, .mg), v(1, .p), a(.sugar), v(7, .g)]),
    
    ("Vitamin A 0% Vitamin C 2% Calcium 20%",
     [a(.vitaminA), v(0, .p), a(.vitaminC), v(2, .p), a(.calcium), v(20, .p)]),

    ("Vit. D 0mcg 0% Calcium 58mg 4%",
     [a(.vitaminD), v(0, .mcg), v(0, .p), a(.calcium), v(58, .mg), v(4, .p)]),

    ("based on a 2,000 calorie diet. Vit A 0% • Vit C 0% • Calcium 15% • Iron 0% • Vit D 15%",
     [v(2000, .kcal), a(.vitaminA), v(0, .p), a(.vitaminC), v(0, .p), a(.calcium), v(15, .p), a(.iron), v(0, .p), a(.vitaminD), v(15, .p)]),

    ("based on a 2,000 calorie diet. Vitamin A 4% - Vitamin C 0% - Calcium 15% - Iron 0% - Vitamin D 15%",
     [v(2000, .kcal), a(.vitaminA), v(4, .p), a(.vitaminC), v(0, .p), a(.calcium), v(15, .p), a(.iron), v(0, .p), a(.vitaminD), v(15, .p)]),

    ("2000 calorie diet. Vitamin A 0% PRONE ALONE PASTEREONOGAYMAKLIMEANOACINECTRESSERENIOPLIS.LAUSRSLISONER Vitamin C 0% Calcium 30% • Iron",
     [v(2000, .kcal), a(.vitaminA), v(0, .p), a(.vitaminC), v(0, .p), a(.calcium), v(30, .p), a(.iron)]),

    //MARK: - Ingredients (Ignore if needed)
    ("At least 2% lower in saturated fat compared to regular yoghurt",
     [v(2, .p), a(.saturatedFat)]),

    ("SUGAR, YELLOW/BOX HONEY (4.2%), THICKENER", [a(.sugar), v(4.2, .p)]),

    ("CARAMELISED SUGAR, MILK MINERALS LIVE", [a(.sugar)]),
    ("INGREDIENTS: Milk Chocolate [sugar,", [a(.sugar)]),
    ("(coconut, palm kernel), sugar, chocolate,", [a(.sugar)]),
    ("INGREDIENTS: CULTURED GRADE A NON FAT MILK, WATER, STRAWBERRY, SUGAR, FRUCTOSE, CONTAINS LESS THAN 1%", [v(1, .p)]),

    ("(FOR COLOR), SODIUM CITRATE, POTASSIUM SORBATE (TO MAINTAIN FRESHNESS), MALIC ACID, VITAMIN D3.",
     [v(3)]),

    ("STEVIA LEAF EXTRACT, SEA SALT, VITAMIN D3, SODIUM CITRATE.", [v(3), a(.sodium)]),

    ("INGREDIENTS: Low Fat Yogurt, Sugar, Raspherry Purée (2.5%)", [v(2.5, .p)]),
    ("yogurt cultures), Strawberry (10%), Sugar AbarAy", [v(10, .p), a(.sugar)]),
    ("regulators citric acid, calcium citrate), Flavouring,", [a(.calcium)]),

    //MARK: - Unsorted
    ("Calories", [a(.energy)]),
    ("Dietary Fiber 0g", [a(.dietaryFibre), v(0, .g)]),
    ("Iron 0mg 0%", [a(.iron), v(0, .mg), v(0, .p)]),
    ("Potas. 60mg 2%", [a(.potassium), v(60, .mg), v(2, .p)]),
    ("of which saturates", [a(.saturatedFat)]),
    ("FIBRE", [a(.dietaryFibre)]),
    ("VITAMIN D (68% RI* PER 100g)", [a(.vitaminD), v(68, .p), p(.referenceIntakePer), v(100, .g)]),
    ("131 Cal", [v(131, .kcal)]),
    ("196Cal", [v(196, .kcal)]),
    ("Dietary Fiber less than 1g", [a(.dietaryFibre), v(1, .g)]),
    ("(calories 140", [a(.energy), v(140)]),
    ("200 calorie diel.", [v(200, .kcal)]),
    ("Iron 0%", [a(.iron), v(0, .p)]),
    ("Calories 120", [a(.energy), v(120)]),
    ("of which saturates", [a(.saturatedFat)]),
    ("Fibre", [a(.dietaryFibre)]),
    ("0% Dietary Fiber 0g", [v(0, .p), a(.dietaryFibre), v(0, .g)]),
    ("mono-unsaturates", [a(.monounsaturatedFat)]),
    ("polyunsaturates", [a(.polyunsaturatedFat)]),
    ("Calories 140", [a(.energy), v(140)]),

    ("<0.1 g", [v(0.1, .g)]),
    ("120 mg", [v(120, .mg)]),
    ("3.4 ug", [v(3.4, .mcg)]),
    ("0.19", [v(0.19)]),
    ("2", [v(2)]),
    ("0%", [v(0, .p)]),
    ("11%", [v(11, .p)]),
    ("0mg", [v(0, .mg)]),
    ("0.1 g", [v(0.1, .g)]),
    ("133kcal", [v(133, .kcal)]),
    ("2000 kcal", [v(2000, .kcal)]),
    ("5.9g 30%", [v(5.9, .g), v(30, .p)]),
    ("0.5g", [v(0.5, .g)]),
    ("746kJ", [v(746, .kj)]),
    ("210 mg", [v(210, .mg)]),

    /// Edge cases
    ("0.1 c", [v(0.1, .g)]), /// For when vision misreads a 'g' as 'c'

//    ("168ma", [v()]),
//    ("trace", [v()]),
//    ("497k1", [v()]),

//    Servings per package:
//    Serving size: 130g (1 cup)
//    Per serving
//    Servings per package: 8 Serving Size: 125g (1 cup)
//    Per Serving
//    Per 100 g
//    PER 100g 74g (2 tubes)
//    SERVINGS PER TUB:
//    SERVING SIZE: 150g
//    AVE. QTY. %DI* PER AVE. QTY.
//    PER SERVE
//    SERVE PER 100g
//    trition Amount Per Serving %Daily Value* Amount Per Serving
//    (sarins Per Container 1
//    about 40 servings per container
//    Serving size 3 balls (36g)
//    Amount per serving
//    Calories per gram:
//    Amount/Serving
//    %DV* Amount/Serving
//    Serving Size
//    Nutrition Facts Amount/Serving %DV* Amount/Serving
//    Serving Size
//    Servings per package: 8 Serving size: 125g (1 cup)
//    PER TUB: 1
//    SERVINGS E
//    SERVING SE
//    AVE. QTY. %DI* PER
//    PER SERVE
//    INFORMATION Per 120g Per 100g
//    Nutritional Values (Typical) Per 100 g Per serving (125 g)
//    Nutrition Amount Per Serving %Daily Value* Amount Per Serving 50al) Veter)
//    Serving Size:
//    Servings Per Container
//    Per 1 pot

//    13% cream
//    5 Dadson Road
//    1. 22000 369941
//    el 6288 6421
//    150 9001 QMS & 22000 Certined
//    8 888026 252014
//    2te with
//    40, 180 67 852
//    deceit S 00 s
//    AVERAGE ADULT DIET OF 8700kJ.
//    % AFRALA3008. FLAVOURED YOGHURT. KEEP REFRIGERATED BELOW 4°C.
//    from at least 99%
//    1 Divere based on a
//    Lund Parma G/AS7, 4980 FARMA, INC., 669 COUNTY ROAD 25. NEW BERLIN, MY ACAD
//    a serving of food contributes to a daily diet. 2000
//    Keep cool (60-68°F) and dry.
//    (%RDA) (27.9%) (23.3%) 2
//    4.0 0
//    (100g) contains RI* average adult
//    SIZE:
//    Vitamins & minerals
//
//    1 Container (150g)
//    Coz (225g)
//    ⅕ of a pot

]
