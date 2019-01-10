//
//  UdacityErrorResponse.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/9/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation

struct UdacityErrorResponse: Codable {
    let status: Int
    let error: String
}

extension UdacityErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
