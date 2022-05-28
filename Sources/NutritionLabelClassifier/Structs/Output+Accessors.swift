import Foundation

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
    var columnHeader1Type: ColumnHeaderType? { identifiableColumnHeader1?.type }
    var columnHeader2Type: ColumnHeaderType? { identifiableColumnHeader2?.type }

    var columnHeader1SizeName: String? { identifiableColumnHeader1?.sizeName }
    var columnHeader2SizeName: String? { identifiableColumnHeader2?.sizeName }

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
