import Foundation

public extension Collection {
    /// Returns an array of slices of length "size" from the array.
    ///
    /// If array can't be split evenly, the final slice will be the remaining elements.
    ///
    ///     [0, 2, 4, 7].group(by: 2) -> [[0, 2], [4, 7]]
    ///     [0, 2, 4, 7, 6].group(by: 2) -> [[0, 2], [4, 7], [6]]
    ///
    /// - Parameter size: The size of the slices to be returned.
    /// - Returns: grouped self.
    func chunk(by size: Int) -> [[Element]]? {
        // Inspired by: https://lodash.com/docs/4.17.4#chunk
        guard size > 0, !isEmpty else { return nil }
        var start = startIndex
        var slices = [[Element]]()
        while start != endIndex {
            let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
            slices.append(Array(self[start..<end]))
            start = end
        }
        return slices
    }
    
    /// Get all indices where condition is met.
    ///
    ///     [1, 7, 1, 2, 4, 1, 8].indices(where: { $0 == 1 }) -> [0, 2, 5]
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: all indices where the specified condition evaluates to true (optional).
    func indices(where condition: (Element) throws -> Bool) rethrows -> [Index]? {
        let indices = try self.indices.filter { try condition(self[$0]) }
        return indices.isEmpty ? nil : indices
    }
}

public extension Collection where Element: Equatable {
    /// All indices of specified item.
    ///
    ///     [1, 2, 2, 3, 4, 2, 5].indices(of 2) -> [1, 2, 5]
    ///     [1.2, 2.3, 4.5, 3.4, 4.5].indices(of 2.3) -> [1]
    ///     ["h", "e", "l", "l", "o"].indices(of "l") -> [2, 3]
    ///
    /// - Parameter item: item to check.
    /// - Returns: an array with all indices of the given item.
    func indices(of item: Element) -> [Index] {
        return indices.filter { self[$0] == item }
    }
}
