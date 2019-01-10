//
//  UdacityLocalionResponse.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/8/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation

struct UdacityLocationResponse: Codable {
    let createdAt: String
    let objectId: String
}

extension UdacityLocationResponse: LocalizedError {
    var errorDescription: String? {
        return objectId
    }
}
