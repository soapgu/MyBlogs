//
//  BlogService.swift
//  MyBlogs
//
//  Created by guhui on 2022/2/14.
//

import Foundation
import Moya

enum BlogService {
    case list( repoAddress : String , pageSize : Int , pageNumber : Int)
}


extension BlogService : TargetType {
    var authorizationType: AuthorizationType? {
        switch self {
        case .list(_,_,_):
            return .custom("token")
        }
    }
    
    var baseURL: URL {
        URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .list(_,_,_):
            return "/search/issues"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .list(_,_,_):
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .list(let repoAddress,let pageSize,let pageNumber):
            return .requestParameters(parameters: ["q" : "repo:\(repoAddress)",
                                                   "per_page":pageSize,
                                                   "page":pageNumber], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
}

private extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        Data(self.utf8)
    }
}
