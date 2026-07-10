import Foundation

struct GiphyGIF: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let tinyPreviewURL: URL
    let gifURL: URL

    private enum CodingKeys: String, CodingKey { case id, title, images }
    private enum ImagesKeys: String, CodingKey { case fixedWidthSmall = "fixed_width_small", fixedHeight = "fixed_height" }
    private enum RenditionKeys: String, CodingKey { case url }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "GIPHY GIF"
        let images = try container.nestedContainer(keyedBy: ImagesKeys.self, forKey: .images)
        let preview = try images.nestedContainer(keyedBy: RenditionKeys.self, forKey: .fixedWidthSmall)
        let full = try images.nestedContainer(keyedBy: RenditionKeys.self, forKey: .fixedHeight)
        tinyPreviewURL = try preview.decode(URL.self, forKey: .url)
        gifURL = try full.decode(URL.self, forKey: .url)
    }
}

enum GiphyServiceError: LocalizedError {
    case missingKey
    case invalidResponse
    case unavailable

    var errorDescription: String? {
        switch self {
        case .missingKey: return "Add GIPHY_API_KEY to activate the full library."
        case .invalidResponse: return "GIPHY returned an unreadable result."
        case .unavailable: return "The GIPHY library is unavailable right now."
        }
    }
}

enum GiphyService {
    private static var apiKey: String? {
        let key = Bundle.main.object(forInfoDictionaryKey: "GIPHY_API_KEY") as? String
        return key?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? key : nil
    }

    static var isConfigured: Bool { apiKey != nil }

    static func trending(limit: Int = 24) async throws -> [GiphyGIF] {
        try await load(endpoint: "trending", query: nil, limit: limit)
    }

    static func search(_ query: String, limit: Int = 24) async throws -> [GiphyGIF] {
        try await load(endpoint: "search", query: query, limit: limit)
    }

    static func localGIFURL(for gif: GiphyGIF) async throws -> URL {
        let directory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("GiphyMedia", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let destination = directory.appendingPathComponent("\(gif.id).gif")
        if FileManager.default.fileExists(atPath: destination.path) { return destination }
        let (data, response) = try await URLSession.shared.data(from: gif.gifURL)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw GiphyServiceError.unavailable }
        try data.write(to: destination, options: .atomic)
        return destination
    }

    private static func load(endpoint: String, query: String?, limit: Int) async throws -> [GiphyGIF] {
        guard let apiKey else { throw GiphyServiceError.missingKey }
        var components = URLComponents(string: "https://api.giphy.com/v1/gifs/\(endpoint)")!
        var items = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "limit", value: String(min(max(limit, 1), 50))),
            URLQueryItem(name: "rating", value: "g"),
            URLQueryItem(name: "bundle", value: "messaging_non_clips")
        ]
        if let query, !query.isEmpty { items.append(URLQueryItem(name: "q", value: query)) }
        components.queryItems = items
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw GiphyServiceError.unavailable }
        struct Response: Decodable { let data: [GiphyGIF] }
        guard let decoded = try? JSONDecoder().decode(Response.self, from: data) else { throw GiphyServiceError.invalidResponse }
        return decoded.data
    }
}
