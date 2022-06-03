import UIKit

public extension UIFont {
    var traits: [UIFontDescriptor.TraitKey: Any] {
        fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any] ?? [:]
    }
    
    var weight: UIFont.Weight {
        guard let weightNumber = traits[.weight] as? NSNumber else { return .regular }
        let weightRawValue = CGFloat(weightNumber.doubleValue)
        let weight = UIFont.Weight(rawValue: weightRawValue)
        return weight
    }
    
    func usingWeight(_ weight: UIFont.Weight, size: CGFloat) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
        traits[.weight] = weight
        
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return UIFont(descriptor: descriptor, size: size)
    }
    
    func usingFontFamily(_ font: UIFont) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
        traits[.weight] = weight
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = font.familyName
        let descriptor = UIFontDescriptor(fontAttributes: attributes).withSymbolicTraits(fontDescriptor.symbolicTraits) ?? fontDescriptor
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    func usingSize(_ size: CGFloat) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
        traits[.weight] = weight
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return UIFont(descriptor: descriptor, size: size)
    }
    
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

public extension UIFont {
    /// Font as bold font.
    var bold: UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
    }
    
    /// Font as italic font.
    var italic: UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitItalic)!, size: 0)
    }
    
    /// Font as monospaced font.
    ///
    ///     UIFont.preferredFont(forTextStyle: .body).monospaced
    ///
    var monospaced: UIFont {
        let settings = [[
            UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
            UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
        ]]
        
        let attributes = [UIFontDescriptor.AttributeName.featureSettings: settings]
        let newDescriptor = fontDescriptor.addingAttributes(attributes)
        return UIFont(descriptor: newDescriptor, size: 0)
    }
}
