import UIKit

public extension UIColor {
    convenience init(hex: String) {
        let r, g, b, a: CGFloat
        guard hex.hasPrefix("#") else { self.init(red: 0, green: 0, blue: 0, alpha: 1.0); return }
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { self.init(red: 0, green: 0, blue: 0, alpha: 1.0); return }
        
        switch hexColor.count {
        case 2:
            r = CGFloat((hexNumber & 0xff) >> 24) / 255.0
            self.init(red: r, green: r, blue: r, alpha: 1.0)
        case 8:
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255.0
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255.0
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255.0
            a = CGFloat(hexNumber & 0x000000ff) / 255.0
            self.init(red: r, green: g, blue: b, alpha: a)
        default:
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255.0
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255.0
            b = CGFloat((hexNumber & 0x0000ff)) / 255.0
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        }
    }
}

public extension UIColor {
    static var random: UIColor {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return UIColor(red: red, green: green, blue: blue)!
    }
    
    var rgbComponents: (red: Int, green: Int, blue: Int) {
        let components: [CGFloat] = {
            let comps: [CGFloat] = cgColor.components!
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        return (red: Int(red * 255.0), green: Int(green * 255.0), blue: Int(blue * 255.0))
    }
}

public extension UIColor {
    /// Create Color from RGB values with optional transparency.
    /// - Parameters:
    ///   - red: red value
    ///   - green: green value
    ///   - blue: blue value
    ///   - transparency: transparency value, default is 1
    convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0, red <= 255 else { return nil }
        guard green >= 0, green <= 255 else { return nil }
        guard blue >= 0, blue <= 255 else { return nil }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
}
