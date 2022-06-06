import Foundation

public extension String {
    var range: NSRange {
        NSRange(location: 0, length: count)
    }
    
    func range(of searchString: String) -> NSRange {
        (self as NSString).range(of: searchString)
    }
    
    func replacingCharacters(in range: NSRange, with replacement: String) -> String {
        let start = utf16.index(utf16.startIndex, offsetBy: range.location)
        let end = utf16.index(utf16.startIndex, offsetBy: range.location + range.length)
        return replacingCharacters(in: start..<end, with: replacement)
    }
    
    func insertingCharacters(_ string: String, at location: Int) -> String {
        var s = self
        s.insert(contentsOf: string, at: s.index(s.startIndex, offsetBy: location))
        return s
    }
    
    func substring(with range: NSRange) -> String {
        let start = utf16.index(utf16.startIndex, offsetBy: range.location)
        let end = utf16.index(utf16.startIndex, offsetBy: range.location + range.length)
        return String(self[start..<end])
    }
}

public extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

public extension String {
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return self.processCamalCaseRegex(pattern: acronymPattern)?
            .processCamalCaseRegex(pattern: normalPattern)?.lowercased() ?? self.lowercased()
    }
    
    fileprivate func processCamalCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}

public extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

public extension Character {
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}
