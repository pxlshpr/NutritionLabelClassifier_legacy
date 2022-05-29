import Foundation
import VisionSugar
import TabularData

extension NutritionLabelClassifier {
    public static func classify(_ arrayOfRecognizedTexts: [[RecognizedText]]) -> Output {
        let dataFrame = dataFrameOfNutrients(from: arrayOfRecognizedTexts)
        return dataFrame.classifierOutput
    }
}

extension DataFrame {
    func rowForObservedAttribute(_ attribute: Attribute) -> DataFrame.Rows.Element? {
        rows.first(where: {
            guard let attributeWithId = $0["attribute"] as? AttributeWithId else {
                return false
            }
            return attributeWithId.attribute == attribute
        })
    }

    func value1WithIdForAttribute(_ attribute: Attribute) -> ValueWithId? {
        guard let row = rowForObservedAttribute(attribute) else {
            return nil
        }
        return row["value1"] as? ValueWithId
    }
    
    func value2WithIdForAttribute(_ attribute: Attribute) -> ValueWithId? {
        guard let row = rowForObservedAttribute(attribute) else {
            return nil
        }
        return row["value2"] as? ValueWithId
    }
}

extension DataFrame {
    
    var classifierOutput: Output {
        
        let rows: [Output.Nutrients.Row] = rows.compactMap { row in
            guard let attributeWithIdRow = row["attribute"] as? AttributeWithId,
                  let valueWithId1Row = row["value1"] as? ValueWithId?,
                  let valueWithId2Row = row["value2"] as? ValueWithId? else {
                return nil
            }
            
            guard valueWithId1Row != nil || valueWithId2Row != nil else {
                return nil
            }
            
            let attributeWithId = IdentifiableAttribute(
                attribute: attributeWithIdRow.attribute,
                id: attributeWithIdRow.observationId
            )
            let value1WithId: IdentifiableValue?
            if let valueWithId = valueWithId1Row {
                value1WithId = IdentifiableValue(
                    value: valueWithId.value,
                    id: valueWithId.observationId
                )
            } else {
                value1WithId = nil
            }

            let value2WithId: IdentifiableValue?
            if let valueWithId = valueWithId2Row {
                value2WithId = IdentifiableValue(
                    value: valueWithId.value,
                    id: valueWithId.observationId
                )
            } else {
                value2WithId = nil
            }

            return Output.Nutrients.Row(
                identifiableAttribute: attributeWithId,
                identifiableValue1: value1WithId,
                identifiableValue2: value2WithId
            )
        }

        let nutrients = Output.Nutrients(
            identifiableColumnHeader1: nil,
            identifiableColumnHeader2: nil,
            rows: rows.filter { $0.identifiableAttribute.attribute.isNutrient })

        let perContainer: Output.Serving.PerContainer?
        if let valueWithId = value1WithIdForAttribute(.servingsPerContainerAmount) {
            perContainer = Output.Serving.PerContainer(
                identifiableAmount: Output.IdentifiableDouble(valueWithId),
                identifiableName: nil)
        } else {
            perContainer = nil
        }
        
        let serving: Output.Serving?
        if let value1WithId = value1WithIdForAttribute(.servingAmount) {
            
            let equivalentSize: Output.Serving.EquivalentSize?
            if let value2WithId = value2WithIdForAttribute(.servingAmount) {
                equivalentSize = Output.Serving.EquivalentSize(
                    identifiableAmount: Output.IdentifiableDouble(value2WithId),
                    identifiableUnit: Output.IdentifiableUnit(value2WithId),
                    identifiableUnitSizeName: nil
                )
            } else {
                equivalentSize = nil
            }
            
            serving = Output.Serving(
                identifiableAmount: Output.IdentifiableDouble(value1WithId),
                identifiableUnit: Output.IdentifiableUnit(value1WithId),
                identifiableUnitSizeName: nil,
                equivalentSize: equivalentSize,
                perContainer: perContainer
            )
        } else {
            serving = nil
        }
           
        
        return Output(serving: serving, nutrients: nutrients, primaryColumnIndex: 0)
    }
}

extension Output.IdentifiableDouble {
    init(_ valueWithId: ValueWithId) {
        self.double = valueWithId.value.amount
        self.id = valueWithId.observationId
    }
}

extension Output.IdentifiableUnit {
    init?(_ valueWithId: ValueWithId) {
        guard let unit = valueWithId.value.unit else {
            return nil
        }
        self.nutritionUnit = unit
        self.id = valueWithId.observationId
    }
}
