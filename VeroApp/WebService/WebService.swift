//
//  WebService.swift
//  VeroApp
//
//  Created by Omer Keskin on 22.08.2024.
//



import Alamofire
import Foundation

class WebService {
    static let shared = WebService()
    private var accessToken: String?
    
    private let baseAuthURL = "https://api.baubuddy.de/index.php/login"
    private let resourceURL = "https://api.baubuddy.de/dev/index.php/v1/tasks/select"
    
    private init() {}

    // Struct to decode the OAuth response
    private struct OAuthResponse: Decodable {
        let oauth: OAuth
    }

    private struct OAuth: Decodable {
        let access_token: String
    }
    
    private struct TaskResponse: Decodable {
        let tasks: [Task]
    }


    private struct MetaInfo: Decodable {
        let total: Int
        let page: Int
    }
    
    func authenticate(completion: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Basic QVBJX0V4cGxvcmVyOjEyMzQ1NmlzQUxhbWVQYXNz",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "username": "365",
            "password": "1"
        ]
        
        AF.request(baseAuthURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: OAuthResponse.self) { response in
                switch response.result {
                case .success(let oauthResponse):
                    self.accessToken = oauthResponse.oauth.access_token
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
    }
    


   func fetchTasks(completion: @escaping ([Task]?) -> Void) {
        guard let token = accessToken else {
            completion(nil)
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        // Change the HTTP method to GET
        AF.request(resourceURL, method: .get, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    // Print the raw response data for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Raw Response Data: \(responseString)")
                    }
                    
                    // Decode the response data
                    do {
                        // Expect an array of tasks
                        let tasks = try JSONDecoder().decode([Task].self, from: data)
                        print("Fetched Tasks from API: \(tasks)")
                        completion(tasks)
                    } catch {
                        print("Failed to decode response: \(error)")
                        completion(nil)
                    }
                    
                case .failure(let error):
                    print("Failed to fetch tasks: \(error)")
                    completion(nil)
                }
            }
    }



}
