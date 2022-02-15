//
//  GithubAPI.swift
//  MyBlogs
//
//  Created by guhui on 2022/2/14.
//

import Foundation
import Moya
import RxSwift

class GithubAPI {
    private let provider: MoyaProvider<BlogService>
    
    init(){
        let authPlugin = AccessTokenPlugin {  _ in "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" }
        provider = MoyaProvider<BlogService>(plugins: [authPlugin] )
        //[NetworkLoggerPlugin()]
    }
    
    func loadBlogs(pageSize:Int = 10, pageNumber:Int = 1, repoAddress:String = "soapgu/PlayPen") -> Single<SearchResult<Issue>>{
        provider.rx.request(.list(repoAddress: repoAddress,pageSize: pageSize,pageNumber: pageNumber))
            .filterSuccessfulStatusCodes()
            .map(SearchResult.self)
    }
}
