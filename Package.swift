// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NutritionLabelClassifier",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NutritionLabelClassifier",
            targets: ["NutritionLabelClassifier"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/SwiftSugar", from: "0.0.49"),
        .package(url: "https://github.com/pxlshpr/VisionSugar", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NutritionLabelClassifier",
            dependencies: [
                .product(name: "SwiftSugar", package: "swiftsugar"),
                .product(name: "VisionSugar", package: "visionsugar")
            ],
            resources: []
        ),
        .testTarget(
            name: "NutritionLabelClassifierTests",
            dependencies: ["NutritionLabelClassifier"],
            resources: [
                .process("Test Data/Input/With Language Correction/1.csv"),
                .process("Test Data/Input/With Language Correction/2.csv"),
                .process("Test Data/Input/With Language Correction/3.csv"),
                .process("Test Data/Input/With Language Correction/4.csv"),
                .process("Test Data/Input/With Language Correction/5.csv"),
                .process("Test Data/Input/With Language Correction/6.csv"),
                .process("Test Data/Input/With Language Correction/7.csv"),
                .process("Test Data/Input/With Language Correction/8.csv"),
                .process("Test Data/Input/With Language Correction/9.csv"),
                .process("Test Data/Input/With Language Correction/10.csv"),
                .process("Test Data/Input/With Language Correction/11.csv"),
                .process("Test Data/Input/With Language Correction/12.csv"),
                .process("Test Data/Input/With Language Correction/13.csv"),
                .process("Test Data/Input/With Language Correction/14.csv"),
                .process("Test Data/Input/With Language Correction/15.csv"),
                .process("Test Data/Input/With Language Correction/16.csv"),
                .process("Test Data/Input/With Language Correction/17.csv"),
                .process("Test Data/Input/With Language Correction/18.csv"),
                .process("Test Data/Input/With Language Correction/19.csv"),
                .process("Test Data/Input/With Language Correction/20.csv"),
                .process("Test Data/Input/Without Language Correction/1-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/2-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/3-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/4-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/5-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/6-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/7-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/8-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/9-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/10-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/11-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/12-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/13-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/14-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/15-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/16-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/17-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/18-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/19-without_language_correction.csv"),
                .process("Test Data/Input/Without Language Correction/20-without_language_correction.csv"),
                .process("Test Data/Expected/1-nutrients.csv"),
                .process("Test Data/Expected/2-nutrients.csv"),
                .process("Test Data/Expected/3-nutrients.csv"),
                .process("Test Data/Expected/4-nutrients.csv"),
                .process("Test Data/Expected/5-nutrients.csv"),
                .process("Test Data/Expected/6-nutrients.csv"),
                .process("Test Data/Expected/7-nutrients.csv"),
                .process("Test Data/Expected/8-nutrients.csv"),
                .process("Test Data/Expected/9-nutrients.csv"),
                .process("Test Data/Expected/10-nutrients.csv"),
                .process("Test Data/Expected/11-nutrients.csv"),
                .process("Test Data/Expected/12-nutrients.csv"),
                .process("Test Data/Expected/13-nutrients.csv"),
                .process("Test Data/Expected/14-nutrients.csv"),
                .process("Test Data/Expected/15-nutrients.csv"),
                .process("Test Data/Expected/16-nutrients.csv"),
                .process("Test Data/Expected/17-nutrients.csv"),
                .process("Test Data/Expected/18-nutrients.csv"),
                .process("Test Data/Expected/19-nutrients.csv"),
                .process("Test Data/Expected/20-nutrients.csv")
            ]
        ),
    ]
)
