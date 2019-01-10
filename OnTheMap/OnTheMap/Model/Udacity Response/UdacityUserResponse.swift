//
//  UdacityUserRequest.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/8/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation

struct Email: Codable {
    let address: String
}

struct UdacityUserResponse: Codable {
    let lastName: String
    let firstName: String
    let email: Email
    
    
    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
        case email
    }
}
