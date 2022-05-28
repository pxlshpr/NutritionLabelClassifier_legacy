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
        .package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.14"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NutritionLabelClassifier",
            dependencies: [
                .product(name: "SwiftSugar", package: "swiftsugar"),
                .product(name: "VisionSugar", package: "visionsugar"),
                .product(name: "ZIPFoundation", package: "zipfoundation")
            ],
            resources: []
        ),
        .testTarget(
            name: "NutritionLabelClassifierTests",
            dependencies: ["NutritionLabelClassifier"],
            resources: [
                .process("TestData/NutritionClassifier-Test_Data.zip"),
                .process("TestData/Input/1.csv"),
                .process("TestData/Input/2.csv"),
                .process("TestData/Input/3.csv"),
                .process("TestData/Input/4.csv"),
                .process("TestData/Input/5.csv"),
                .process("TestData/Input/6.csv"),
                .process("TestData/Input/7.csv"),
                .process("TestData/Input/8.csv"),
                .process("TestData/Input/9.csv"),
                .process("TestData/Input/10.csv"),
                .process("TestData/Input/11.csv"),
                .process("TestData/Input/12.csv"),
                .process("TestData/Input/13.csv"),
                .process("TestData/Input/14.csv"),
                .process("TestData/Input/15.csv"),
                .process("TestData/Input/16.csv"),
                .process("TestData/Input/17.csv"),
                .process("TestData/Input/18.csv"),
                .process("TestData/Input/19.csv"),
                .process("TestData/Input/20.csv"),
                .process("TestData/Input/21.csv"),
                .process("TestData/Input/22.csv"),
                .process("TestData/Input/23.csv"),
                .process("TestData/Input/100.csv"),
                .process("TestData/Input/1-without_language_correction.csv"),
                .process("TestData/Input/2-without_language_correction.csv"),
                .process("TestData/Input/3-without_language_correction.csv"),
                .process("TestData/Input/4-without_language_correction.csv"),
                .process("TestData/Input/5-without_language_correction.csv"),
                .process("TestData/Input/6-without_language_correction.csv"),
                .process("TestData/Input/7-without_language_correction.csv"),
                .process("TestData/Input/8-without_language_correction.csv"),
                .process("TestData/Input/9-without_language_correction.csv"),
                .process("TestData/Input/10-without_language_correction.csv"),
                .process("TestData/Input/11-without_language_correction.csv"),
                .process("TestData/Input/12-without_language_correction.csv"),
                .process("TestData/Input/13-without_language_correction.csv"),
                .process("TestData/Input/14-without_language_correction.csv"),
                .process("TestData/Input/15-without_language_correction.csv"),
                .process("TestData/Input/16-without_language_correction.csv"),
                .process("TestData/Input/17-without_language_correction.csv"),
                .process("TestData/Input/18-without_language_correction.csv"),
                .process("TestData/Input/19-without_language_correction.csv"),
                .process("TestData/Input/20-without_language_correction.csv"),
                .process("TestData/Input/21-without_language_correction.csv"),
                .process("TestData/Input/22-without_language_correction.csv"),
                .process("TestData/Input/23-without_language_correction.csv"),
                .process("TestData/Input/100-without_language_correction.csv"),
                .process("TestData/Expected/1-nutrients.csv"),
                .process("TestData/Expected/2-nutrients.csv"),
                .process("TestData/Expected/3-nutrients.csv"),
                .process("TestData/Expected/4-nutrients.csv"),
                .process("TestData/Expected/5-nutrients.csv"),
                .process("TestData/Expected/6-nutrients.csv"),
                .process("TestData/Expected/7-nutrients.csv"),
                .process("TestData/Expected/8-nutrients.csv"),
                .process("TestData/Expected/9-nutrients.csv"),
                .process("TestData/Expected/10-nutrients.csv"),
                .process("TestData/Expected/11-nutrients.csv"),
                .process("TestData/Expected/12-nutrients.csv"),
                .process("TestData/Expected/13-nutrients.csv"),
                .process("TestData/Expected/14-nutrients.csv"),
                .process("TestData/Expected/15-nutrients.csv"),
                .process("TestData/Expected/16-nutrients.csv"),
                .process("TestData/Expected/17-nutrients.csv"),
                .process("TestData/Expected/18-nutrients.csv"),
                .process("TestData/Expected/19-nutrients.csv"),
                .process("TestData/Expected/20-nutrients.csv"),
                .process("TestData/Expected/21-nutrients.csv"),
                .process("TestData/Expected/22-nutrients.csv"),
                .process("TestData/Expected/23-nutrients.csv"),
                .process("TestData/Expected/100-nutrients.csv"),
            ]
        ),
    ]
)
