//
//  SearchResult.swift
//  MyBlogs
//
//  Created by guhui on 2022/2/14.
//

import Foundation

struct SearchResult<T: Codable> : Codable{
    var total_count : Int
    var incomplete_results : Bool
    var items:[T]
}
