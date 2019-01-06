//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/5/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation

struct Udacity: Codable {
    let username: String
    let password: String
}

struct UdacityLoginRequest: Codable {
    let udacity: Udacity
}
