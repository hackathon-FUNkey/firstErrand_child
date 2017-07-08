//
//  AppRequestType.swift
//  firstErrand_child
//
//  Created by 河辺雅史 on 2017/07/09.
//  Copyright © 2017年 funkey. All rights reserved.
//

import APIKit

protocol AppRequest: Request {}

extension AppRequest {
    var baseURL: URL {
        return URL(string: "https://version1.xyz/spajam2017/")!
    }
}
