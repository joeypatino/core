import Foundation

public extension Data {
    func writeWithIntermediaryDirectories(to url: URL, options: Data.WritingOptions = []) throws {
        if !url.isFileURL {
            fatalError("writeWithIntermediaryDirectories is for FileURLs")
        }
        
        let dir = url.directory
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        try self.write(to: url)
    }
}

public extension Data {
    
    /// returns Data, converted into hex string format, then encoded back into Data
    var hexdata: Data {
        Data(self.hexlify.utf8)
    }

    /// returns a hex rep string of this data
    var hexlify: String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)
        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }
        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }
}
