import Foundation

public struct Output {
    public let serving: Serving?
    public let nutrients: Nutrients
    public let primaryColumnIndex: Int
}

public struct AttributeText {
    public let attribute: Attribute
    public let textId: UUID
}

public struct ValueText {
    public let value: Value
    public let textId: UUID
}

public struct DoubleText {
    public let double: Double
    public let textId: UUID
}

extension DoubleText {
    init(_ valueText: ValueText) {
        self.double = valueText.value.amount
        self.textId = valueText.textId
    }
    init(_ doubleText: DoubleText) {
        self.double = doubleText.double
        self.textId = doubleText.textId
    }
}

extension UnitText {
    init?(_ valueText: ValueText) {
        guard let unit = valueText.value.unit else {
            return nil
        }
        self.unit = unit
        self.textId = valueText.textId
    }
    init?(_ stringText: StringText) {
        guard let unit = NutritionUnit(string: stringText.string) else {
            return nil
        }
        self.unit = unit
        self.textId = stringText.textId
    }
}

public struct UnitText {
    public let unit: NutritionUnit
    public let textId: UUID
}

public struct StringText {
    public let string: String
    public let textId: UUID
}

public struct HeaderText {
    public let type: HeaderType
    public let unitName: String?
    public let id: UUID
}

extension Output {
    //MARK: Serving
    public struct Serving {
        
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
