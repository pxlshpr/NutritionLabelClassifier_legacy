import Foundation
import TabularData

@testable import NutritionLabelClassifier

extension Output {
    init?(fromExpectedDataFrame dataFrame: DataFrame) {
        var primaryColumnIndex = 0
        if let row = dataFrame.rowForExpectedAttribute(.primaryColumnIndex),
           let double = row[.double] as? Double
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

        var amountText: DoubleText? = nil
        var unitText: UnitText? = nil
        var unitNameText: StringText? = nil
        
        var identifiableEquivalentAmount: DoubleText? = nil
        var identifiableEquivalentUnit: UnitText? = nil
        var identifiableEquivalentUnitSizeName: StringText? = nil
        var equivalentSize: EquivalentSize? = nil
        
        var identifiablePerContainerAmount: DoubleText? = nil
        var identifiablePerContainerName: StringText? = nil
//        var identifiablePerContainerName: Output.Serving.PerContainer.IdentifiableContainerName? = nil
        var perContainer: PerContainer? = nil
        
        for row in dataFrame.rows {
            guard let attributeName = row[.attributeString] as? String,
                  let attribute = Attribute(rawValue: attributeName),
                  attribute.isServingAttribute,
                  let double = row[.double] as? Double?,
                  let string = row[.string] as? String?
            else {
                continue
            }
            
            if attribute == .servingAmount, let double = double {
                amountText = DoubleText(double: double, textId: defaultUUID)
            }
            
            if attribute == .servingUnit, let string = string, let unit = NutritionUnit(string: string) {
                unitText = UnitText(unit: unit, textId: defaultUUID)
            }

            if attribute == .servingUnitSize, let string = string {
                unitNameText = StringText(string: string, textId: defaultUUID)
            }
            
            //MARK: Equivalent Amount
            if attribute == .servingEquivalentAmount, let double = double {
                identifiableEquivalentAmount = DoubleText(double: double, textId: defaultUUID)
            }
            if attribute == .servingEquivalentUnit, let string = string, let unit = NutritionUnit(string: string) {
                identifiableEquivalentUnit = UnitText(unit: unit, textId: defaultUUID)
            }
            if attribute == .servingEquivalentUnitSize, let string = string {
                identifiableEquivalentUnitSizeName = StringText(string: string, textId: defaultUUID)
            }
            
            //MARK: Per Container
            if attribute == .servingsPerContainerAmount, let double = double {
                identifiablePerContainerAmount = DoubleText(double: double, textId: defaultUUID)
            }
            if attribute == .servingsPerContainerName, let string = string {
                identifiablePerContainerName = StringText(
                    string: string,
                    textId: defaultUUID)
            }
        }
        
        guard let amountText = amountText else {
            return nil
        }
        
        if let amountText = identifiableEquivalentAmount,
            (identifiableEquivalentUnit != nil || unitNameText != nil) {
            equivalentSize = EquivalentSize(
                amountText: amountText,
                unitText: identifiableEquivalentUnit,
                unitNameText: identifiableEquivalentUnitSizeName)
        }
        
        if let identifiablePerContainerAmount = identifiablePerContainerAmount {
            perContainer = PerContainer(
                amountText: identifiablePerContainerAmount,
                nameText: identifiablePerContainerName)
        }
        
        self.init(
            amountText: amountText,
            unitText: unitText,
            unitNameText: unitNameText,
            equivalentSize: equivalentSize,
            perContainer: perContainer
        )
    }
}

extension DataFrame {
    func rowForExpectedAttribute(_ attribute: Attribute) -> DataFrame.Rows.Element? {
        rows.first(where: {
            guard let attributeName = $0[.attributeString] as? String,
                  let attr = Attribute(rawValue: attributeName) else {
                return false
            }
            return attr == attribute
        })
    }
}
extension Output.Nutrients {
    init(fromExpectedDataFrame dataFrame: DataFrame) {
        
        let columnHeader1: HeaderText?
        if let row = dataFrame.rowForExpectedAttribute(.header1Type),
           let typeDouble = row[.double] as? Double,
           let type = HeaderType(rawValue: Int(typeDouble))
        {
            let unitName: String?
            if let row = dataFrame.rowForExpectedAttribute(.columnHeader1Size),
               let string = row[.string] as? String {
                unitName = string
            } else {
                unitName = nil
            }
            columnHeader1 = HeaderText(type: type, unitName: unitName, id: defaultUUID)
        } else {
            columnHeader1 = nil
        }

        let columnHeader2: HeaderText?
        if let row = dataFrame.rowForExpectedAttribute(.header2Type),
           let typeDouble = row[.double] as? Double,
           let type = HeaderType(rawValue: Int(typeDouble))
        {
            let unitName: String?
            if let row = dataFrame.rowForExpectedAttribute(.columnHeader2Size),
               let string = row[.string] as? String {
                unitName = string
            } else {
                unitName = nil
            }
            columnHeader2 = HeaderText(type: type, unitName: unitName, id: defaultUUID)
        } else {
            columnHeader2 = nil
        }

        /// Rows
        var nutrientRows: [Row] = []
        for row in dataFrame.rows {
            guard let attributeName = row[.attributeString] as? String,
                  let attribute = Attribute(rawValue: attributeName),
                  let value1String = row[.value1String] as? String?,
                  let value2String = row[.value2String] as? String?
            else {
                continue
            }
            
            guard value1String != nil || value2String != nil else {
                continue
            }
            
            var valueText1: ValueText? = nil
            if let value1String = value1String {
                guard let value = Value(fromString: value1String) else {
                    print("Failed to convert value1String: \(value1String)")
                    continue
                }
                valueText1 = ValueText(value: value, textId: defaultUUID)
            }
            
            var valueText2: ValueText? = nil
            if let value2String = value2String {
                guard let value = Value(fromString: value2String) else {
                    print("Failed to convert value2String: \(value2String)")
                    continue
                }
                valueText2 = ValueText(value: value, textId: defaultUUID)
            }
            
            let nutrientRow = Row(
                attributeText: AttributeText(
                    attribute: attribute,
                    textId: defaultUUID
                ),
                valueText1: valueText1,
                valueText2: valueText2)
            
            nutrientRows.append(nutrientRow)
        }

        self.init(
            headerText1: columnHeader1,
            headerText2: columnHeader2,
            rows: nutrientRows
        )
    }
}
