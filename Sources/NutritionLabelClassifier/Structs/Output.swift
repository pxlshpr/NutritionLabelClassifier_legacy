import Foundation

public struct Output {
    public let serving: Serving?
    public let nutrients: Nutrients
}

public struct AttributeText {
    public let attribute: Attribute
    public let textId: UUID
}

public struct ValueText {
    public let value: Value
    public let textId: UUID
    public let attributeTextId: UUID? = nil
}

public struct DoubleText {
    public let double: Double
    public let textId: UUID
    public let attributeTextId: UUID
}

public struct UnitText {
    public let unit: NutritionUnit
    public let textId: UUID
    public let attributeTextId: UUID
}

public struct StringText {
    public let string: String
    public let textId: UUID
    public let attributeTextId: UUID
}

public struct HeaderText {
    public let type: HeaderType
    public let textId: UUID
    public let attributeTextId: UUID
    public let serving: Serving?
    
    public struct Serving {
        public let amount: Double?
        public let unit: NutritionUnit?
        public let unitName: String?
        public let equivalentSize: EquivalentSize?
        
        public struct EquivalentSize {
            public let amount: Double
            public let unit: NutritionUnit?
            public let unitName: String?
        }
    }
}

extension Output {
    //MARK: Serving
    public struct Serving {
        //TODO: Add attribute texts for these too
        public let amountText: DoubleText?
        public let unitText: UnitText?
        public let unitNameText: StringText?
        public let equivalentSize: EquivalentSize?

        public let perContainer: PerContainer?

        public struct EquivalentSize {
            public let amountText: DoubleText
            public let unitText: UnitText?
            public let unitNameText: StringText?
        }

        public struct PerContainer {
            public let amountText: DoubleText
            public let nameText: StringText?
        }
    }
    
    //MARK: Nutrients
    public struct Nutrients {
        public let headerText1: HeaderText?
        public let headerText2: HeaderText?
        
        public let rows: [Row]
        
        public struct Row {
            public let attributeText: AttributeText
            public let valueText1: ValueText?
            public let valueText2: ValueText?
        }
    }
}
