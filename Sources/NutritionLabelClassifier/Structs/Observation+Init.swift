import Foundation
import VisionSugar

extension Observation {
    init?(headerType: HeaderType, for attribute: Attribute, recognizedText: RecognizedText) {
        guard attribute == .headerType1 || attribute == .headerType2 else {
            return nil
        }
        self.init(
            attributeText: AttributeText(attribute: attribute,
                                         textId: recognizedText.id),
            stringText: StringText(string: headerType.rawValue,
                                   textId: recognizedText.id,
                                   attributeTextId: recognizedText.id)
        )
    }
    
    init?(double: Double, attribute: Attribute, recognizedText: RecognizedText) {
        guard attribute.expectsDouble else { return nil }
        self.init(
            attributeText: AttributeText(attribute: attribute, textId: recognizedText.id),
            doubleText: DoubleText(double: double, textId: recognizedText.id, attributeTextId: recognizedText.id))
    }
    
    init?(unit: NutritionUnit, attribute: Attribute, recognizedText: RecognizedText) {
        guard attribute.expectsNutritionUnit else { return nil }
        self.init(
            attributeText: AttributeText(attribute: attribute, textId: recognizedText.id),
            stringText: StringText(string: unit.description, textId: recognizedText.id, attributeTextId: recognizedText.id))
    }

    init?(string: String, attribute: Attribute, recognizedText: RecognizedText) {
        guard attribute.expectsString else { return nil }
        self.init(
            attributeText: AttributeText(attribute: attribute, textId: recognizedText.id),
            stringText: StringText(string: string, textId: recognizedText.id, attributeTextId: recognizedText.id))
    }
}
