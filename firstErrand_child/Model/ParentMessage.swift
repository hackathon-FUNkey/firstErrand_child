//
//  ParentMessage.swift
//  firstErrand_child
//
//  Created by 河辺雅史 on 2017/07/09.
//  Copyright © 2017年 funkey. All rights reserved.
//

import Himotoki

struct ParentMessage {
    let message: String
}

extension ParentMessage: Decodable {
    static func decode(_ e: Extractor) throws -> ParentMessage {
        return try ParentMessage(message: e <| "msg")
    }
}
