//

//  TestPostFetching
//
//  Created by user167484 on 5/2/20.
//  Copyright © 2020 Allen Savio. All rights reserved.
//

import Foundation
import CoreData


struct Preferences: Codable {
    var host:String
    var paths:[String: String]
}

//MARK: - Networking Utility
enum Request {
    case fetchPosts
    case fetchComments(postId: Int)
    
    var url: URL? {
        guard let urlPath = getURLPath() else { return nil }
        return URL(string: urlPath)
    }
    
    func getURLPath() -> String? {
        guard let path = Bundle.main.path(forResource: "server", ofType: "plist"), let xml = FileManager.default.contents(atPath: path),
            let preferences = try? PropertyListDecoder().decode(Preferences.self, from: xml) else {
            return nil
        }
        
        print(preferences.host)
        print(preferences.paths.count)
        switch self {
        case .fetchPosts:
            return preferences.host + (preferences.paths["posts"] ?? "")
        case .fetchComments(let postId):
            let path = (preferences.paths["postComments"] ?? "")
            return preferences.host + replaceTokens(token: "post_number", replaceWith: "\(postId)", path: path)
        }
    }
    
    func replaceTokens(token:String ,replaceWith: String, path: String) -> String {
        let newPath = path.replacingOccurrences(of: "{\(token)}", with: replaceWith)
        return newPath
    }
    
    enum ImageError: Error {
        case wrongURL
    }
    
    typealias RequestCompletion<T> = (_ response: URLResponse?, _ data: T) -> Void
    typealias FailureCompletion = (_ error: Error) -> Void
    func execute<T: Decodable>(success: @escaping RequestCompletion<T>, failure: @escaping FailureCompletion) {
        guard DataManager.shared.isNetworkAvailable else { failure(ImageError.wrongURL); return }
        guard let url = url else { failure(ImageError.wrongURL); return }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    failure(error)
                }
            } else {
                guard let data = data else { return }
                guard let string = String(data: data, encoding: String.Encoding.isoLatin1) else { return }
                guard let properData = string.data(using: .utf8, allowLossyConversion: true) else { return }
       
                switch self {
                case .fetchPosts,.fetchComments:
                    do {
                        let decoder = JSONDecoder()
                        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = DataManager.shared.context!
                        let newData = try decoder.decode(T.self, from: properData)
                        DispatchQueue.main.async {
                            success(response, newData)
                        }
                    } catch let error {
                        print("Caught Error - > \(error)")
                        DispatchQueue.main.async {
                            failure(error)
                        }
                        
                    }
                }
            }
        }.resume()
    }
}

