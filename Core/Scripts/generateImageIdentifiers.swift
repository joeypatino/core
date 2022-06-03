#!/usr/bin/env xcrun swift

import Foundation

let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

func imagesInDir(dir: URL) throws -> [String] {
    let contents = try FileManager.default.contentsOfDirectory(atPath: dir.path)
    
    func dirs() -> [URL] {
        return contents
            .map {
                dir.appendingPathComponent($0)
            }.filter {
                var isDirectory: ObjCBool = false
                let exists = FileManager.default.fileExists(atPath: $0.path, isDirectory: &isDirectory)
                return exists && isDirectory.boolValue
            }
            .filter {
                return !$0.path.hasSuffix(".appiconset") && !$0.path.hasSuffix(".colorset")
            }
    }
    
    do {
        var images = contents.filter { $0.hasSuffix(".png") || $0.hasSuffix(".pdf") || $0.hasSuffix(".jpeg") || $0.hasSuffix(".jpg") }
        try dirs().forEach { images.append(contentsOf: try imagesInDir(dir: $0)) }
        return images
    } catch {
        print(error)
        return []
    }
}

do {
    let foundImages = try imagesInDir(dir: currentDirectory)
    
    let images = foundImages.map { (url: String) -> String in
        let lastIdx = url.lastIndex(of: ".") ?? url.endIndex
        let idx = url.index(lastIdx, offsetBy: -1)
        return String(url[...idx])
    }
    let identifiers = images.map {
        $0.camelCased
    }
    let longest = identifiers.max(by: {$1.count > $0.count} ) ?? ""
    print("import UIKit")
    print("")
    print("// THIS FILE IS AUTO-GENERATED. DO NOT EDIT IT DIRECTLY!")
    print("public extension UIImage {")
    print("    enum ImageIdentifier: String, CaseIterable {")
    images.forEach {
        print("        case \($0.camelCased.padding(toLength: longest.count, withPad: " ", startingAt: 0)) = \"\($0)\"")
    }
    print("    }")
    print("}")
    print("")
    print("public extension UIImage {")
    print("    convenience init!(imageIdentifier: ImageIdentifier, in bundle: Bundle = .main) {")
    print("        self.init(named: imageIdentifier.rawValue, in: bundle, compatibleWith: nil)")
    print("    }")
    print("}")
} catch {
    print(error)
}

extension String {
    var camelCased: String {
        let source = lowercased().replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "-", with: " ")
        let first = source[..<source.index(after: source.startIndex)]
        if source.contains(" ") {
            let connected = source.capitalized.replacingOccurrences(of: " ", with: "")
            let camel = connected.replacingOccurrences(of: "\n", with: "")
            let rest = String(camel.dropFirst())
            return first + rest
        }
        let rest = String(source.dropFirst())
        return first + rest
    }
}
