//
//  NegativeWordRequest.swift
//  firstErrand_child
//
//  Created by 河辺雅史 on 2017/07/09.
//  Copyright © 2017年 funkey. All rights reserved.
//

import APIKit
import Himotoki

struct NegativeWordRequest: AppRequest {
    typealias Response = Status
    var negativeWordDic: [String:String] = [String:String]()
    
    init(negativeWordDic: [String:String]) {
        self.negativeWordDic = negativeWordDic
    }
        
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/child.php"
    }
    
    var parameters: Any? {
        return self.negativeWordDic
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
}
