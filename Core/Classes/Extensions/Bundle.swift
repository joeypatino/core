import Foundation

public typealias DecoderConfigurationClosure = (inout JSONDecoder) -> Void

public enum BundleDecodeError: Error {
    case notFound
}

public extension Bundle {
    func decodeModel<Model>(from file: String, fileExtension: String = "json", decoderConfiguration: DecoderConfigurationClosure? = nil) throws -> Model where Model: Decodable {
        guard let url = url(forResource: file, withExtension: fileExtension) else { throw BundleDecodeError.notFound }
        let data = try Data(contentsOf: url)
        var jsonDecoder = JSONDecoder()
        decoderConfiguration?(&jsonDecoder)
        return try jsonDecoder.decode(Model.self, from: data)
    }
}
