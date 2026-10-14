import Foundation

struct KlipyGIF: Decodable, Identifiable, Hashable {
    let id: String
    let slug: String
    let title: String
    let tinyPreviewURL: URL
    let tinyGIFURL: URL

    private enum CodingKeys: String, CodingKey { case id, slug, title, file, type }
    private struct Media: Decodable { let url: URL }
    private struct Formats: Decodable { let gif: Media? }
    private struct Files: Decodable { let hd: Formats?; let md: Formats?; let sm: Formats?; let xs: Formats? }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let type = try container.decodeIfPresent(String.self, forKey: .type), type != "gif" {
            throw KlipyServiceError.invalidResponse
        }
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = String(try container.decode(Int64.self, forKey: .id))
        }
        slug = try container.decode(String.self, forKey: .slug)
        let decodedTitle = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        title = decodedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "KLIPY GIF" : decodedTitle
        let files = try container.decode(Files.self, forKey: .file)
        guard let preview = files.sm?.gif?.url ?? files.xs?.gif?.url ?? files.md?.gif?.url ?? files.hd?.gif?.url,
              let full = files.hd?.gif?.url ?? files.md?.gif?.url ?? files.sm?.gif?.url ?? files.xs?.gif?.url,
              preview.scheme == "https", full.scheme == "https" else { throw KlipyServiceError.invalidResponse }
        tinyPreviewURL = preview
        tinyGIFURL = full
    }
}

struct KlipyPage: Decodable {
    let items: [KlipyGIF]
    let hasNext: Bool
    private enum CodingKeys: String, CodingKey { case result, data }
    private struct PageData: Decodable {
        let data: [KlipyGIF]
        let hasNext: Bool
        private enum CodingKeys: String, CodingKey { case data; case hasNext = "has_next" }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard try container.decode(Bool.self, forKey: .result) else { throw KlipyServiceError.invalidResponse }
        let page = try container.decode(PageData.self, forKey: .data)
        items = page.data
        hasNext = page.hasNext
    }
}

enum KlipyServiceError: LocalizedError {
    case missingKey, invalidResponse, unavailable, sharingUnavailable
    var errorDescription: String? {
        switch self {
        case .sharingUnavailable: return "GIF sharing is not available yet."
        case .missingKey: return "The GIF library is not configured yet."
        case .invalidResponse: return "KLIPY returned an unreadable result."
        case .unavailable: return "The KLIPY library is unavailable right now."
        }
    }
}

enum KlipyService {
    private static var apiKey: String? {
        let key = (Bundle.main.object(forInfoDictionaryKey: "KLIPY_API_KEY") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let key, !key.isEmpty, key != "$(KLIPY_API_KEY)" else { return nil }
        return key
    }
    static var isMediaProcessingApproved: Bool {
        Bundle.main.object(forInfoDictionaryKey: "KLIPY_MEDIA_PROCESSING_APPROVED") as? String == "YES"
    }

    static var isConfigured: Bool { apiKey != nil }

    static func requestURL(apiKey: String, query: String?, limit: Int, page: Int) -> URL {
        let endpoint = query?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? "search" : "trending"
        let base = URL(string: "https://api.klipy.com/api/v1/")!
        var components = URLComponents(url: base.appendingPathComponent(apiKey).appendingPathComponent("gifs").appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        var items = [
            URLQueryItem(name: "page", value: String(max(1, page))),
            URLQueryItem(name: "per_page", value: String(min(max(limit, 8), 50))),
            URLQueryItem(name: "locale", value: "us"),
            URLQueryItem(name: "content_filter", value: "high"),
            URLQueryItem(name: "format_filter", value: "gif")
        ]
        if endpoint == "search" { items.append(URLQueryItem(name: "q", value: query)) }
        components.queryItems = items
        return components.url!
    }

    static func trending(limit: Int = 24, page: Int = 1) async throws -> KlipyPage {
        try await load(query: nil, limit: limit, page: page)
    }
    static func search(_ query: String, limit: Int = 24, page: Int = 1) async throws -> KlipyPage {
        try await load(query: query, limit: limit, page: page)
    }

    // Only the selected GIF is downloaded. Previews use provider URLs directly.
    static func localGIFURL(for gif: KlipyGIF) async throws -> URL {
        guard isMediaProcessingApproved else { throw KlipyServiceError.sharingUnavailable }
        let (data, response) = try await URLSession.shared.data(from: gif.tinyGIFURL)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw KlipyServiceError.unavailable }
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("klipy-\(UUID().uuidString).gif")
        try data.write(to: destination, options: .atomic)
        return destination
    }

    private static func load(query: String?, limit: Int, page: Int) async throws -> KlipyPage {
        guard let apiKey else { throw KlipyServiceError.missingKey }
        do {
            let (data, response) = try await URLSession.shared.data(from: requestURL(apiKey: apiKey, query: query, limit: limit, page: page))
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw KlipyServiceError.unavailable }
            guard let decoded = try? JSONDecoder().decode(KlipyPage.self, from: data) else { throw KlipyServiceError.invalidResponse }
            return decoded
        } catch is CancellationError { throw CancellationError() }
        catch let error as KlipyServiceError { throw error }
        catch { throw KlipyServiceError.unavailable }
    }
}
