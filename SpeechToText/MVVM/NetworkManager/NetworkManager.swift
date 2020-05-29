//
//  NetworkManager.swift
//  SmartServ
//
//  Created by Ashish Verma on 24/05/20.
//  Copyright © 2020 com.verma.ashish. All rights reserved.
//

import Foundation

class NetworkManager {
    
    
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }
    
    typealias successClosure = (_ data: Data?) -> Void

    func sendRequest(with urlString: String, type: RequestType, parameters: [String: AnyObject]?, success: @escaping successClosure) {
        do {
            let request = try createRequest(with: urlString, type: type, parameters: parameters)
            session.dataTask(with: request) { (data, urlResponse, error) in
                if error == nil && data != nil {
                    success(data!)
                } else {
                    print(error.debugDescription)
                }
                }.resume()
        } catch {
            print("\nUnable to form request with url:\n\(urlString)\nError Description\(error.localizedDescription)")
        }
    }
    
    private func createRequest(with urlString: String, type: RequestType, parameters: [String: AnyObject]?) throws -> (URLRequest) {
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = type.rawValue
        
        return request
    }
    
    enum RequestType: String {
        case get = "GET"
        case post = "POST"
        case update = "UPDATE"
    }
}
