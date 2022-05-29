import Foundation

public struct Output {
    public let serving: Serving?
    public let nutrients: Nutrients
    public let primaryColumnIndex: Int
}

public struct IdentifiableAttribute {
    public let attribute: Attribute
    public let id: UUID
}

public struct IdentifiableValue {
    public let value: Value
    public let id: UUID
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
            public let type: ColumnHeaderType
            public let sizeName: String?
            public let id: UUID
        }
        
        public struct Row {
            public let identifiableAttribute: IdentifiableAttribute
            public let identifiableValue1: IdentifiableValue?
            public let identifiableValue2: IdentifiableValue?
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
