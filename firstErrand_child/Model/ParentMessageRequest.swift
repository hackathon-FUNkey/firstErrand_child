//
//  ParentMessageRequest.swift
//  firstErrand_child
//
//  Created by 河辺雅史 on 2017/07/09.
//  Copyright © 2017年 funkey. All rights reserved.
//

import APIKit
import Himotoki

struct ParentMessageRequest: AppRequest {
    typealias Response = [ParentMessage]
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/advices"
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try decodeArray(object)
    }
}
