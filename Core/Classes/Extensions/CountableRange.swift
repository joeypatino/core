import Foundation

public extension CountableRange where Bound: Strideable {    
    /// Extend each bound away from midpoint by `factor`
    /// - Parameter factor: the factor to extend outwards from the midpoint, in each direction by
    /// - Returns: the extended range
    func extended(byFactor factor: Double) -> CountableRange<Bound> {
        let theCount: Int = numericCast(count)
        let amountToMove: Bound.Stride = numericCast(Int(Double(theCount) * factor))
        return lowerBound.advanced(by: -amountToMove) ..< upperBound.advanced(by: amountToMove)
    }
}
