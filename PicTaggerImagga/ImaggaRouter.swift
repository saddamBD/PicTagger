//
//  ImaggaRouter.swift
//  PicTaggerImagga
//
//  Created by General on 4/25/18.
//  Copyright © 2018 General. All rights reserved.
//

import Foundation
import Alamofire
public enum ImaggaRouter: URLRequestConvertible {
    static let baseURLPath = "http://api.imagga.com/v1"
    static let authenticationToken = "Basic YWNjXzRhODQ0MGRmODY0MWNhNjo1NzRiOTE2NTVlMDBmYjU3NTQwOTUzMDAxOTgyZWFkNQ=="
    
    case content
    case tags(String)
    
    var method: HTTPMethod {
        switch self {
        case .content:
            return .post
        case .tags:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .content:
            return "/content"
        case .tags:
            return "/tagging"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self {
            case .tags(let contentID):
                return ["content": contentID]
             
            default:
                return [:]
            }
        }()
        
        let url = try ImaggaRouter.baseURLPath.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue(ImaggaRouter.authenticationToken, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
