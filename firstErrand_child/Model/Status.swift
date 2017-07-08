//
//  Status.swift
//  firstErrand_child
//
//  Created by 河辺雅史 on 2017/07/09.
//  Copyright © 2017年 funkey. All rights reserved.
//

import Himotoki

struct Status {
    let status: Bool
}

extension Status: Decodable {
    static let URLTransformer = Transformer<String, URL> { URLString throws -> URL in
        if let URL = URL(string: URLString) {
            return URL
        }
        throw customError("Invalid URL string: \(URLString)")
    }
    
    static func decode(_ e: Extractor) throws -> Status {
        return try Status(status: e <| "status")
    }
}
