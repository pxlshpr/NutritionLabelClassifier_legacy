import Foundation

public struct Output {
    public let serving: Serving?
    public let nutrients: Nutrients
    public let primaryColumnIndex: Int
}

extension Output {
    //MARK: Serving
    public struct Serving {
        public let amount: Amount?
        public let perContainer: PerContainer?

        public struct Amount {
            public let valueWithId: DoubleWithId
            public let unitWithId: UnitWithId?
            public let unitSizeWIthId: StringWithId?
            public let equivalentSize: EquivalentSize?

            public struct EquivalentSize {
                public let nameWithId: StringWithId
                public let valueWithId: DoubleWithId
            }
        }
        
        public struct PerContainer {
            public let valueWithId: DoubleWithId
            public let nameWithId: ContainerNameWithId?

            public struct ContainerNameWithId {
                public let containerName: ContainerName
                public let id: UUID
            }
        }
    }
    
    //MARK: Nutrients
    public struct Nutrients {
        public let columnHeader1: ColumnHeaderWithId?
        public let columnHeader2: ColumnHeaderWithId?
        public let rows: [NutrientRow]
        
        public struct ColumnHeaderWithId {
            public let columnHeader: ColumnHeader
            public let id: UUID
        }
        
    }
    
    //MARK: Containers
    public struct DoubleWithId {
        public let double: Double
        public let id: UUID
    }
    
    public struct UnitWithId {
        public let nutritionUnit: NutritionUnit
        public let id: UUID
    }
    
    public struct StringWithId {
        public let string: String
        public let id: UUID
    }
    
    public struct NutrientRow {
        public let attributeWithId: AttributeWithId
        public let value1WithId: ValueWithId?
        public let value2WithId: ValueWithId?

        public struct AttributeWithId {
            public let attribute: Attribute
            public let id: UUID
        }
        
        public struct ValueWithId {
            public let value: Value
            public let id: UUID
        }
    }
}

public enum ContainerName: String {
    case container
    case package
    case unknown
}
