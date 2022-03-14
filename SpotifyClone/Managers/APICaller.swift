//
//  APICaller.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 12/12/21.
//

import Foundation

final class APICaller{
    static let shared = APICaller()
    
    private init(){
    }
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
        
        static let amountValues: [String: Int] = [
            "album_releases": 20,
            "featured_playlists": 20,
            "recommendations": 40
        ]
        static func amounts(_ key: String!) -> String {
            guard let value = amountValues[key] else {
                return ""
            }
            return "\(value)"
        }
    }
    
    enum APIError: Error{
        case failedToGetData
    }
    
    //MARK: - USER
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void){
        requestAndDecodeJSON(with: Constants.baseAPIURL + "/me",
                             method: .GET,
                             model: UserProfile.self,
                             completion: completion)
    }
    
    //MARK: - BROWSE
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse, Error>) -> Void)){
        requestAndDecodeJSON(with: Constants.baseAPIURL + "/browse/new-releases?limit=\(Constants.amounts("album_releases"))",
                             method: .GET,
                             model: NewReleasesResponse.self,
                             completion: completion)
    }
    
    public func getFeaturedPlaylists(completion: @escaping ((Result<FeaturedPlaylistsResponse, Error>) -> Void)){
        requestAndDecodeJSON(with: Constants.baseAPIURL + "/browse/featured-playlists?limit=\(Constants.amounts("featured_playlists"))",
                             method: .GET,
                             model: FeaturedPlaylistsResponse.self,
                             completion: completion)
    }
    
    public func getRecommendedGenres(completion: @escaping ((Result<RecommendedGenresResponse, Error>) -> Void)){
        requestAndDecodeJSON(with: Constants.baseAPIURL + "/recommendations/available-genre-seeds",
                             method: .GET,
                             model: RecommendedGenresResponse.self,
                             completion: completion)
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse, Error>) -> Void)){
        let urlParams = "seed_genres=\(genres.joined(separator: ","))&limit=\(Constants.amounts("recommendations"))"
        requestAndDecodeJSON(with: Constants.baseAPIURL + "/recommendations?\(urlParams)",
                             method: .GET,
                             model: RecommendationsResponse.self,
                             completion: completion)
    }
    
    //MARK: - PRIVATE STUFF
    
    enum HTTPMethod: String{
        case GET
        case POST
    }
    
    private func requestAndDecodeJSON<T: Decodable>(with urlString: String, method: HTTPMethod, model: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        createRequest(with: URL(string: urlString),
                      method: .GET){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                }catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    private func createRequest(with url: URL?, method: HTTPMethod, completion: @escaping (URLRequest) -> Void){
        AuthManager.shared.withValidToken{ token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = method.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
