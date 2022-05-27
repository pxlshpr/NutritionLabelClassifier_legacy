import Foundation
import TabularData

@testable import NutritionLabelClassifier

extension Output {
    init?(fromExpectedDataFrame dataFrame: DataFrame) {
        //TODO: Get primaryColumnIndex
        self.init(serving: Serving(fromExpectedDataFrame: dataFrame),
                  nutrients: Nutrients(fromExpectedDataFrame: dataFrame),
                  primaryColumnIndex: 0)
    }
}

extension Output.Serving {
    init?(fromExpectedDataFrame dataFrame: DataFrame) {

        var identifiableAmount: Output.IdentifiableDouble? = nil
        var identifiableUnit: Output.IdentifiableUnit? = nil
        var identifiableUnitSizeName: Output.IdentifiableString? = nil
        
        var identifiableEquivalentAmount: Output.IdentifiableDouble? = nil
        var identifiableEquivalentUnit: Output.IdentifiableUnit? = nil
        var identifiableEquivalentUnitSizeName: Output.IdentifiableString? = nil
        var equivalentSize: EquivalentSize? = nil
        
        var identifiablePerContainerAmount: Output.IdentifiableDouble? = nil
        var identifiablePerContainerName: Output.IdentifiableString? = nil
//        var identifiablePerContainerName: Output.Serving.PerContainer.IdentifiableContainerName? = nil
        var perContainer: PerContainer? = nil
        
        for row in dataFrame.rows {
            guard let attributeName = row["attributeString"] as? String,
                  let attribute = Attribute(rawValue: attributeName),
                  attribute.isServingAttribute,
                  let double = row["double"] as? Double?,
                  let string = row["string"] as? String?
            else {
                continue
            }
            
            if attribute == .servingAmount, let double = double {
                identifiableAmount = Output.IdentifiableDouble(double: double, id: defaultUUID)
            }
            
            if attribute == .servingUnit, let string = string, let unit = NutritionUnit(string: string) {
                identifiableUnit = Output.IdentifiableUnit(nutritionUnit: unit, id: defaultUUID)
            }

            if attribute == .servingUnitSize, let string = string {
                identifiableUnitSizeName = Output.IdentifiableString(string: string, id: defaultUUID)
            }
            
            //MARK: Equivalent Amount
            if attribute == .servingEquivalentAmount, let double = double {
                identifiableEquivalentAmount = Output.IdentifiableDouble(double: double, id: defaultUUID)
            }
            if attribute == .servingEquivalentUnit, let string = string, let unit = NutritionUnit(string: string) {
                identifiableEquivalentUnit = Output.IdentifiableUnit(nutritionUnit: unit, id: defaultUUID)
            }
            if attribute == .servingEquivalentUnitSize, let string = string {
                identifiableEquivalentUnitSizeName = Output.IdentifiableString(string: string, id: defaultUUID)
            }
            
            //MARK: Per Container
            if attribute == .servingsPerContainerAmount, let double = double {
                identifiablePerContainerAmount = Output.IdentifiableDouble(double: double, id: defaultUUID)
            }
            if attribute == .servingsPerContainerName, let string = string {
                identifiablePerContainerName = Output.IdentifiableString(
                    string: string,
                    id: defaultUUID)
            }
        }
        
        guard let identifiableAmount = identifiableAmount else {
            return nil
        }
        
        if let identifiableAmount = identifiableEquivalentAmount,
            (identifiableEquivalentUnit != nil || identifiableUnitSizeName != nil) {
            equivalentSize = EquivalentSize(
                identifiableAmount: identifiableAmount,
                identifiableUnit: identifiableEquivalentUnit,
                identifiableUnitSizeName: identifiableEquivalentUnitSizeName)
        }
        
        if let identifiablePerContainerAmount = identifiablePerContainerAmount {
            perContainer = PerContainer(
                identifiableAmount: identifiablePerContainerAmount,
                identifiableName: identifiablePerContainerName)
        }
        
        self.init(
            identifiableAmount: identifiableAmount,
            identifiableUnit: identifiableUnit,
            identifiableUnitSizeName: identifiableUnitSizeName,
            equivalentSize: equivalentSize,
            perContainer: perContainer
        )
    }
}

extension Output.Nutrients {
    init(fromExpectedDataFrame dataFrame: DataFrame) {
        var nutrientRows: [Row] = []
        for row in dataFrame.rows {
            guard let attributeName = row["attributeString"] as? String,
                  let attribute = Attribute(rawValue: attributeName),
                  let value1String = row["value1String"] as? String?,
                  let value2String = row["value2String"] as? String?
            else {
                continue
            }
            
            guard value1String != nil || value2String != nil else {
                continue
            }
            
            var identifiableValue1: Row.IdentifiableValue? = nil
            if let value1String = value1String {
                guard let value = Value(fromString: value1String) else {
                    print("Failed to convert value1String: \(value1String)")
                    continue
                }
                identifiableValue1 = Row.IdentifiableValue(value: value, id: defaultUUID)
            }
            
            var identifiableValue2: Row.IdentifiableValue? = nil
            if let value2String = value2String {
                guard let value = Value(fromString: value2String) else {
                    print("Failed to convert value2String: \(value2String)")
                    continue
                }
                identifiableValue2 = Row.IdentifiableValue(value: value, id: defaultUUID)
            }
            
            let nutrientRow = Row(
                identifiableAttribute: Row.IdentifiableAttribute(
                    attribute: attribute,
                    id: defaultUUID
                ),
                identifiableValue1: identifiableValue1,
                identifiableValue2: identifiableValue2)
            
            nutrientRows.append(nutrientRow)
        }

        self.init(
            identifiableColumnHeader1: nil,
            identifiableColumnHeader2: nil,
            rows: nutrientRows
        )
    }
}
