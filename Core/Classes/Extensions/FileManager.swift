import Foundation

public extension FileManager {
    var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    var cachesDirectory: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    /// Creates directory in NSTemporary directory
    /// - Parameter folderName: if present, creates subdirectory with given name e.g. tmp/uuid/folderName
    /// - Throws: createDirectory
    /// - Returns: url of new directory
    static func createTemporaryDirectory(folderName: String? = nil) throws -> URL {
        var url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        if let containingComponent = folderName {
            url = url.appendingPathComponent(containingComponent)
        }

        try self.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }

    static func sizeOfFile(atPath path: String) -> Int64? {
        return try? (FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.size]! as AnyObject).longLongValue
    }

    static func sizeOfFile(atURL url: URL) -> Int64? {
        if !url.isFileURL {
            return nil
        }
        return self.sizeOfFile(atPath: url.path)
    }

    static func modificationDateOfFile(atPath path: String) -> Date? {
        let fm = FileManager.default

        guard let sourceDetails = try? fm.attributesOfItem(atPath: path) else {
            return nil
        }

        return sourceDetails[FileAttributeKey.modificationDate] as? Date
    }

    static func modificationDateOfFile(atURL url: URL) -> Date? {
        if !url.isFileURL {
            return nil
        }
        return self.modificationDateOfFile(atPath: url.path)
    }

    static func fileIsDirectory(atPath path: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    static func fileIsDirectory(atURL url: URL) -> Bool {
        if !url.isFileURL {
            return false
        }
        return self.fileIsDirectory(atPath: url.path)
    }
}

public extension FileManager {
    var temporaryURL: URL {
        URL(fileURLWithPath: cachesDirectory.path, isDirectory: true).appendingPathComponent(UUID().uuidString)
    }
}
