import Foundation

final class PhotoService {
    static let shared = PhotoService()
    private let session: URLSession
    private let apiKey: String
    private let baseURL = "https://api.pexels.com/v1/"
    private let searchEndpoint = "search"
    
    private init() {
        self.session = URLSession(configuration: .default)
        self.apiKey = Secrets.pexelsAPIKey
    }
    
    func fetchSearchPhotos(query: String, page: Int = 1, perPage: Int = 15) async throws -> PexelsAPIResponse {
        let urlString = "\(baseURL)search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)&per_page=\(perPage)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(PexelsAPIResponse.self, from: data)
    }
}
