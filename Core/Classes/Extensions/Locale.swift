import Foundation

public extension Locale {
    /// Returns bool value indicating if locale has 12h format.
    var is12HourTimeFormat: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        dateFormatter.locale = self
        let dateString = dateFormatter.string(from: Date())
        return dateString.contains(dateFormatter.amSymbol) || dateString.contains(dateFormatter.pmSymbol)
    }
}

public extension Locale {
    static var preferredLocale: Locale {
        let localeIdentifier = Locale.preferredLanguages.first ?? Locale.current.identifier
        return Locale(identifier: localeIdentifier)
    }
}
