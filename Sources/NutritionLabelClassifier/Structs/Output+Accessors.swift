import Foundation

public extension Output.Serving {
    var amount: Double? { amountText?.double }
    var unit: NutritionUnit? { unitText?.unit }
    var unitSizeName: String? { unitNameText?.string }
    
    var amountId: UUID? { amountText?.textId }
    var unitId: UUID? { unitText?.textId }
    var unitSizeNameId: UUID? { unitNameText?.textId }
}

public extension Output.Serving.EquivalentSize {
    var amount: Double { amountText.double }
    var unit: NutritionUnit? { unitText?.unit }
    var sizeName: String? { unitNameText?.string }
    
    var amountId: UUID { amountText.textId }
    var unitId: UUID? { unitText?.textId }
    var sizeNameId: UUID? { unitNameText?.textId }
}

public extension Output.Serving.PerContainer {
    var amount: Double { amountText.double }
    var name: String? { nameText?.string }
//    var containerName: ContainerName? { identifiableContainerName?.containerName }
    
    var amountId: UUID { amountText.textId }
    var nameId: UUID? { nameText?.textId }
//    var containerNameId: UUID? { identifiableContainerName?.id }
}

public extension Output.Nutrients {
    var columnHeader1Type: ColumnHeaderType? { headerText1?.type }
    var columnHeader2Type: ColumnHeaderType? { headerText2?.type }

    var columnHeader1SizeName: String? { headerText1?.sizeName }
    var columnHeader2SizeName: String? { headerText2?.sizeName }

    var columnHeader1Id: UUID? { headerText1?.id }
    var columnHeader2Id: UUID? { headerText2?.id }
}

public extension Output.Nutrients.Row {
    var attribute: Attribute { attributeText.attribute }
    var value1: Value? { valueText1?.value }
    var value2: Value? { valueText2?.value }
    
    var attributeId: UUID { attributeText.textId }
    var value1Id: UUID? { valueText1?.textId }
    var value2Id: UUID? { valueText2?.textId }
}
