//
//  AuthManager.swift
//  SpotifyClone
//
//  Created by Matheus Quirino on 12/12/21.
//

import Foundation

final class AuthManager{
    static let shared = AuthManager()
    
    var refreshingToken : Bool = false
    
    struct Constants{
        static let clientID = "5de99d3d76104aac9afe5a551ade1f8c"
        static let clientSecret = "debd87367517485d871d5f438ea3887c"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectUri = "https://www.iosacademy.io"
        static let scopeList = [
            "user-read-private",
            "playlist-modify-public",
            "playlist-read-private",
            "playlist-modify-private",
            "user-follow-read",
            "user-library-modify",
            "user-library-read",
            "user-read-email"
        ]
        static let scopes = scopeList.joined(separator: "%20")
    }
    
    private init(){
    }
    
    public var signInURL : URL? {
        let baseURL = "https://accounts.spotify.com/authorize"
        let responseType = "code"
        let clientID = Constants.clientID
        let scopes = Constants.scopes
        let redirectUri = Constants.redirectUri
        let showDialog = "TRUE"
        let string = "\(baseURL)?response_type=\(responseType)&client_id=\(clientID)&scope=\(scopes)&redirect_uri=\(redirectUri)&show_dialog=\(showDialog)"
        
        print(Constants.scopes)
        
        return URL(string: string)
    }
    
    var isSignedIn: Bool{
        return accessToken != nil
    }
    
    private var accessToken: String?{
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String?{
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var expirationDate: Date?{
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool{
        guard let expirationDate = expirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes : TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(
        code: String,
        completion: @escaping ((Bool) -> Void)
    ){
        //Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectUri)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("AuthManager->ExchangeCodeForToken: Failed to get Base64String")
            completion(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            do{
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: authResponse)
                
                
                completion(true)
            }catch{
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    
    private var onRefreshBlocks = [(String) -> Void]()
    
    public func withValidToken(completion: @escaping (String) -> Void){
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken {
            refreshIfNeeded { [weak self] success in
                if success {
                    if let token = self?.accessToken, success {
                        completion(token)
                    }
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool) -> Void)?){
        guard !refreshingToken else{
            return
        }
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        guard let refreshToken = refreshToken else {
            return
        }
        
        //Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("AuthManager->ExchangeCodeForToken: Failed to get Base64String")
            completion?(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] data, _, error in
            self?.refreshingToken = false
            
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            do{
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach{ $0(authResponse.access_token) }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: authResponse)
                
                completion?(true)
            }catch{
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }
    
    public func cacheToken(result : AuthResponse){
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refreshToken = result.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: "expirationDate")
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
    }
}
