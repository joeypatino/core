import Foundation

public extension JSONEncoder {
    // Allows let encoder = JSONEncoder().pretty()
    func pretty() -> JSONEncoder {
        self.outputFormatting.insert(.prettyPrinted)
        return self
    }
}
