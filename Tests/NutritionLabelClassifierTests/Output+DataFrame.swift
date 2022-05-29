import Foundation
import TabularData

@testable import NutritionLabelClassifier

extension Output {
    init?(fromExpectedDataFrame dataFrame: DataFrame) {
        var primaryColumnIndex = 0
        if let row = dataFrame.rowForExpectedAttribute(.primaryColumnIndex),
           let double = row["double"] as? Double
        {
            primaryColumnIndex = Int(double)
        }
        self.init(serving: Serving(fromExpectedDataFrame: dataFrame),
                  nutrients: Nutrients(fromExpectedDataFrame: dataFrame),
                  primaryColumnIndex: primaryColumnIndex)
    }
}

extension Output.Serving {
    init?(fromExpectedDataFrame dataFrame: DataFrame) {

        var identifiableAmount: IdentifiableDouble? = nil
        var identifiableUnit: IdentifiableUnit? = nil
        var identifiableUnitSizeName: IdentifiableString? = nil
        
        var identifiableEquivalentAmount: IdentifiableDouble? = nil
        var identifiableEquivalentUnit: IdentifiableUnit? = nil
        var identifiableEquivalentUnitSizeName: IdentifiableString? = nil
        var equivalentSize: EquivalentSize? = nil
        
        var identifiablePerContainerAmount: IdentifiableDouble? = nil
        var identifiablePerContainerName: IdentifiableString? = nil
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
                identifiableAmount = IdentifiableDouble(double: double, id: defaultUUID)
            }
            
            if attribute == .servingUnit, let string = string, let unit = NutritionUnit(string: string) {
                identifiableUnit = IdentifiableUnit(nutritionUnit: unit, id: defaultUUID)
            }

            if attribute == .servingUnitSize, let string = string {
                identifiableUnitSizeName = IdentifiableString(string: string, id: defaultUUID)
            }
            
            //MARK: Equivalent Amount
            if attribute == .servingEquivalentAmount, let double = double {
                identifiableEquivalentAmount = IdentifiableDouble(double: double, id: defaultUUID)
            }
            if attribute == .servingEquivalentUnit, let string = string, let unit = NutritionUnit(string: string) {
                identifiableEquivalentUnit = IdentifiableUnit(nutritionUnit: unit, id: defaultUUID)
            }
            if attribute == .servingEquivalentUnitSize, let string = string {
                identifiableEquivalentUnitSizeName = IdentifiableString(string: string, id: defaultUUID)
            }
            
            //MARK: Per Container
            if attribute == .servingsPerContainerAmount, let double = double {
                identifiablePerContainerAmount = IdentifiableDouble(double: double, id: defaultUUID)
            }
            if attribute == .servingsPerContainerName, let string = string {
                identifiablePerContainerName = IdentifiableString(
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

extension DataFrame {
    func rowForExpectedAttribute(_ attribute: Attribute) -> DataFrame.Rows.Element? {
        rows.first(where: {
            guard let attributeName = $0["attributeString"] as? String,
                  let attr = Attribute(rawValue: attributeName) else {
                return false
            }
            return attr == attribute
        })
    }
}
extension Output.Nutrients {
    init(fromExpectedDataFrame dataFrame: DataFrame) {
        
        let columnHeader1: IdentifiableColumnHeader?
        if let row = dataFrame.rowForExpectedAttribute(.columnHeader1Type),
           let typeDouble = row["double"] as? Double,
           let type = ColumnHeaderType(rawValue: Int(typeDouble))
        {
            let sizeName: String?
            if let row = dataFrame.rowForExpectedAttribute(.columnHeader1Size),
               let string = row["string"] as? String {
                sizeName = string
            } else {
                sizeName = nil
            }
            columnHeader1 = IdentifiableColumnHeader(type: type, sizeName: sizeName, id: defaultUUID)
        } else {
            columnHeader1 = nil
        }

        let columnHeader2: IdentifiableColumnHeader?
        if let row = dataFrame.rowForExpectedAttribute(.columnHeader2Type),
           let typeDouble = row["double"] as? Double,
           let type = ColumnHeaderType(rawValue: Int(typeDouble))
        {
            let sizeName: String?
            if let row = dataFrame.rowForExpectedAttribute(.columnHeader2Size),
               let string = row["string"] as? String {
                sizeName = string
            } else {
                sizeName = nil
            }
            columnHeader2 = IdentifiableColumnHeader(type: type, sizeName: sizeName, id: defaultUUID)
        } else {
            columnHeader2 = nil
        }

        /// Rows
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
            
            var identifiableValue1: IdentifiableValue? = nil
            if let value1String = value1String {
                guard let value = Value(fromString: value1String) else {
                    print("Failed to convert value1String: \(value1String)")
                    continue
                }
                identifiableValue1 = IdentifiableValue(value: value, id: defaultUUID)
            }
            
            var identifiableValue2: IdentifiableValue? = nil
            if let value2String = value2String {
                guard let value = Value(fromString: value2String) else {
                    print("Failed to convert value2String: \(value2String)")
                    continue
                }
                identifiableValue2 = IdentifiableValue(value: value, id: defaultUUID)
            }
            
            let nutrientRow = Row(
                identifiableAttribute: IdentifiableAttribute(
                    attribute: attribute,
                    id: defaultUUID
                ),
                identifiableValue1: identifiableValue1,
                identifiableValue2: identifiableValue2)
            
            nutrientRows.append(nutrientRow)
        }

        self.init(
            identifiableColumnHeader1: columnHeader1,
            identifiableColumnHeader2: columnHeader2,
            rows: nutrientRows
        )
    }
}
