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
