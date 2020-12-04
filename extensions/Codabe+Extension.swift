//
//  Encodable&Decodable+Extension.swift
//
//  Created by tomieq on 14/12/2020.
//  Copyright © 2020 tomieq. All rights reserved.
//

import Foundation

extension Encodable {
    func toJSONString() -> String? {
        return try? String(data: JSONEncoder().encode(self), encoding: .utf8)
    }
}

extension Decodable {
    static func from(JSONString: String) -> Self? {
        guard let data = JSONString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}
