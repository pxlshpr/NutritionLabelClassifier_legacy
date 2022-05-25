import Foundation

public enum ContainerName {
    case container
    case package
    case unknown
}

public struct Output {

    
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

    public struct Serving {
        public struct Amount {

            public struct EquivalentSize {
                public let name: StringWithId
                public let value: DoubleWithId
            }
            
            public let value: DoubleWithId
            public let unit: UnitWithId?
            public let unitSize: StringWithId?
            public let equivalentSize: EquivalentSize?
        }
        
        public struct PerContainer {
            
            public struct ContainerNameWithId {
                public let containerName: ContainerName
                public let id: UUID
            }
            
            public let value: DoubleWithId
            public let name: ContainerNameWithId?
        }
        
        public let amount: Amount?
        public let perContainer: PerContainer?
    }
    
    public struct Nutrients {
        public struct ColumnHeaderWithId {
            public let columnHeader: ColumnHeader
            public let id: UUID
        }
        
        public struct NutrientRow {
            
            public struct AttributeWithId {
                public let attribute: Attribute
                public let id: UUID
            }
            
            public struct ValueWithId {
                public let value: Value
            }
            
            public let attribute: AttributeWithId
            public let value1: ValueWithId?
            public let value2: ValueWithId?
        }
        
        public let columnHeader1: ColumnHeaderWithId?
        public let columnHeader2: ColumnHeaderWithId?
        public let rows: [NutrientRow]
    }
    
    public let serving: Serving?
    public let nutrients: Nutrients
    public let primaryColumnIndex: Int
}
