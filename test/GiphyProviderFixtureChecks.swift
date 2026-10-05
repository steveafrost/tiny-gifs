import Foundation
@main struct Checks {
    static func main() throws {
        func decode(_ extra: String) throws -> GiphyGIF {
            try JSONDecoder().decode(GiphyGIF.self, from: Data(("{\"id\":\"x\",\"title\":\"Example\",\"images\":{\"fixed_width_small\":{\"url\":\"https://media.giphy.com/x.gif\"}}" + extra + "}").utf8))
        }
        let result6 = try decode(",\"user\":{\"display_name\":\"Creator\",\"username\":\"maker\"}").attribution == "Creator"
        precondition(result6)
        let result7 = try decode(",\"username\":\"maker\"").attribution == "maker"
        precondition(result7)
        let result8 = try decode(",\"source\":\"https://example.com/post\"").attribution == "example.com"
        precondition(result8)
        let result9 = try decode("").attribution == nil
        precondition(result9)
        precondition(GiphyService.session.configuration.urlCache == nil)
        precondition(GiphyService.session.configuration.requestCachePolicy == .reloadIgnoringLocalCacheData)
        print("6 attribution/cache configuration checks passed")
    }
}
