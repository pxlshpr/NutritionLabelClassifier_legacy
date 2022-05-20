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
                .process("Test Data/1.csv"),
                .process("Test Data/2.csv"),
                .process("Test Data/3.csv"),
                .process("Test Data/4.csv"),
                .process("Test Data/5.csv"),
                .process("Test Data/6.csv"),
                .process("Test Data/7.csv"),
                .process("Test Data/8.csv"),
                .process("Test Data/9.csv"),
                .process("Test Data/10.csv"),
                .process("Test Data/11.csv"),
                .process("Test Data/12.csv"),
                .process("Test Data/13.csv"),
                .process("Test Data/14.csv"),
                .process("Test Data/15.csv"),
                .process("Test Data/1-nutrients.csv"),
                .process("Test Data/2-nutrients.csv"),
                .process("Test Data/3-nutrients.csv"),
                .process("Test Data/4-nutrients.csv")
            ]
        ),
    ]
)
