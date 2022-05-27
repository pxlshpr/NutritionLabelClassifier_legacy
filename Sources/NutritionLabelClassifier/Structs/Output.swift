import Foundation

public struct Output {
    public let serving: Serving?
    public let nutrients: Nutrients
    public let primaryColumnIndex: Int
}

extension Output {
    //MARK: Serving
    public struct Serving {
        
        public let identifiableAmount: IdentifiableDouble?
        public let identifiableUnit: IdentifiableUnit?
        public let identifiableUnitSizeName: IdentifiableString?
        public let equivalentSize: EquivalentSize?

        public let perContainer: PerContainer?

        public struct EquivalentSize {
            public let identifiableAmount: IdentifiableDouble
            public let identifiableUnit: IdentifiableUnit?
            public let identifiableUnitSizeName: IdentifiableString?
        }

        public struct PerContainer {
            public let identifiableAmount: IdentifiableDouble
//            public let identifiableContainerName: IdentifiableContainerName?
            public let identifiableName: IdentifiableString?

//            public struct IdentifiableContainerName {
//                public let containerName: ContainerName
//                public let id: UUID
//            }
        }
    }
    
    //MARK: Nutrients
    public struct Nutrients {
        public let identifiableColumnHeader1: IdentifiableColumnHeader?
        public let identifiableColumnHeader2: IdentifiableColumnHeader?
        public let rows: [Row]
        
        public struct IdentifiableColumnHeader {
            public let columnHeader: ColumnHeader
            public let id: UUID
        }
        
        public struct Row {
            public let identifiableAttribute: IdentifiableAttribute
            public let identifiableValue1: IdentifiableValue?
            public let identifiableValue2: IdentifiableValue?

            public struct IdentifiableAttribute {
                public let attribute: Attribute
                public let id: UUID
            }
            
            public struct IdentifiableValue {
                public let value: Value
                public let id: UUID
            }
        }
    }
    
    //MARK: Containers
    public struct IdentifiableDouble {
        public let double: Double
        public let id: UUID
    }
    
    public struct IdentifiableUnit {
        public let nutritionUnit: NutritionUnit
        public let id: UUID
    }
    
    public struct IdentifiableString {
        public let string: String
        public let id: UUID
    }
}

//public enum ContainerName: String {
//    case container
//    case package
//    case unknown
//
//    init(string: String) {
//        switch string.lowercased() {
//        case "container":
//            self = .container
//        case "package":
//            self = .package
//        default:
//            self = .unknown
//        }
//    }
//}

//MARK: - Helpers

/// These are simplified accessors that remove the `identifiable` naming convention

public extension Output.Serving {
    var amount: Double? { identifiableAmount?.double }
    var unit: NutritionUnit? { identifiableUnit?.nutritionUnit }
    var unitSizeName: String? { identifiableUnitSizeName?.string }
    
    var amountId: UUID? { identifiableAmount?.id }
    var unitId: UUID? { identifiableUnit?.id }
    var unitSizeNameId: UUID? { identifiableUnitSizeName?.id }
}

public extension Output.Serving.EquivalentSize {
    var amount: Double { identifiableAmount.double }
    var unit: NutritionUnit? { identifiableUnit?.nutritionUnit }
    var sizeName: String? { identifiableUnitSizeName?.string }
    
    var amountId: UUID { identifiableAmount.id }
    var unitId: UUID? { identifiableUnit?.id }
    var sizeNameId: UUID? { identifiableUnitSizeName?.id }
}

public extension Output.Serving.PerContainer {
    var amount: Double { identifiableAmount.double }
    var name: String? { identifiableName?.string }
//    var containerName: ContainerName? { identifiableContainerName?.containerName }
    
    var amountId: UUID { identifiableAmount.id }
    var nameId: UUID? { identifiableName?.id }
//    var containerNameId: UUID? { identifiableContainerName?.id }
}

public extension Output.Nutrients {
    var columnHeader1: ColumnHeader? { identifiableColumnHeader1?.columnHeader }
    var columnHeader2: ColumnHeader? { identifiableColumnHeader2?.columnHeader }

    var columnHeader1Id: UUID? { identifiableColumnHeader1?.id }
    var columnHeader2Id: UUID? { identifiableColumnHeader2?.id }
}

public extension Output.Nutrients.Row {
    var attribute: Attribute { identifiableAttribute.attribute }
    var value1: Value? { identifiableValue1?.value }
    var value2: Value? { identifiableValue2?.value }
    
    var attributeId: UUID { identifiableAttribute.id }
    var value1Id: UUID? { identifiableValue1?.id }
    var value2Id: UUID? { identifiableValue2?.id }
}
