import Foundation

public extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

public extension Sequence {
    /// Check if all elements in collection match a condition.
    ///
    ///     [2, 2, 4].all(matching: {$0 % 2 == 0}) -> true
    ///     [1,2, 2, 4].all(matching: {$0 % 2 == 0}) -> false
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: true when all elements in the array match the specified condition.
    func all(matching condition: (Element) throws -> Bool) rethrows -> Bool {
        return try !contains { try !condition($0) }
    }
    
    /// Check if no elements in collection match a condition.
    ///
    ///     [2, 2, 4].none(matching: {$0 % 2 == 0}) -> false
    ///     [1, 3, 5, 7].none(matching: {$0 % 2 == 0}) -> true
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: true when no elements in the array match the specified condition.
    func none(matching condition: (Element) throws -> Bool) rethrows -> Bool {
        return try !contains { try condition($0) }
    }
    
    /// Check if any element in collection match a condition.
    ///
    ///     [2, 2, 4].any(matching: {$0 % 2 == 0}) -> false
    ///     [1, 3, 5, 7].any(matching: {$0 % 2 == 0}) -> true
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: true when no elements in the array match the specified condition.
    func any(matching condition: (Element) throws -> Bool) rethrows -> Bool {
        return try contains { try condition($0) }
    }
    
    /// Filter elements based on a rejection condition.
    ///
    ///     [2, 2, 4, 7].reject(where: {$0 % 2 == 0}) -> [7]
    ///     
    /// - Parameter condition: to evaluate the exclusion of an element from the array.
    /// - Returns: the array with rejected values filtered from it.
    func reject(where condition: (Element) throws -> Bool) rethrows -> [Element] {
        return try filter { return try !condition($0) }
    }
    
    /// Get element count based on condition.
    ///
    ///     [2, 2, 4, 7].count(where: {$0 % 2 == 0}) -> 3
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: number of times the condition evaluated to true.
    func count(where condition: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self where try condition(element) {
            count += 1
        }
        return count
    }
    
    /// Return a sorted array based on a key path and a compare function.
    /// - Parameter keyPath: Key path to sort by.
    /// - Parameter compare: Comparation function that will determine the ordering.
    /// - Returns: The sorted array.
    func sorted<T>(by keyPath: KeyPath<Element, T>, with compare: (T, T) -> Bool) -> [Element] {
        return sorted { compare($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    }
    
    /// Return a sorted array based on a key path.
    /// - Parameter keyPath: Key path to sort by. The key path type must be Comparable.
    /// - Returns: The sorted array.
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
    
    /// Remove duplicate elements based on condition.
    ///
    ///     [1, 2, 1, 3, 2].withoutDuplicates { $0 } -> [1, 2, 3]
    ///     [(1, 4), (2, 2), (1, 3), (3, 2), (2, 1)].withoutDuplicates { $0.0 } -> [(1, 4), (2, 2), (3, 2)]
    ///
    /// - Parameter transform: A closure that should return the value to be evaluated for repeating elements.
    /// - Returns: Sequence without repeating elements
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    func withoutDuplicates<T: Hashable>(transform: (Element) throws -> T) rethrows -> [Element] {
        var set = Set<T>()
        return try filter { set.insert(try transform($0)).inserted }
    }
}

public extension Sequence where Element: Hashable {
    /// Check whether a sequence contains duplicates.
    /// - Returns: true if the receiver contains duplicates.
    func containsDuplicates() -> Bool {
        var set = Set<Element>()
        for element in self {
            if !set.insert(element).inserted {
                return true
            }
        }
        return false
    }
    
    /// Getting the duplicated elements in a sequence.
    ///
    ///     [1, 1, 2, 2, 3, 3, 3, 4, 5].duplicates().sorted() -> [1, 2, 3])
    ///     ["h", "e", "l", "l", "o"].duplicates().sorted() -> ["l"])
    ///
    /// - Returns: An array of duplicated elements.
    func duplicates() -> [Element] {
        var set = Set<Element>()
        var duplicates = Set<Element>()
        forEach {
            if !set.insert($0).inserted {
                duplicates.insert($0)
            }
        }
        return Array(duplicates)
    }
}
