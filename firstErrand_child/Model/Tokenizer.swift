//
//  Tokenizer.swift
//  firstErrand_child
//
//  Created by 河辺雅史 on 2017/07/09.
//  Copyright © 2017年 funkey. All rights reserved.
//

struct Tokenizer {
    static func tokenize(text: String) -> [String] {
        let range = text.startIndex ..< text.endIndex
        var tokens: [String] = []
        
        text.enumerateSubstrings(in: range, options: .byWords) { (substring, _, _, _) -> () in
            if let substring = substring {
                tokens.append(substring)
            }
        }
        
        return tokens
    }
}
