//
//  UdacityLoginResponse.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/5/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation

/*
 account
    registered    true
    key    "3903878747"
 session
    id    "1457628510Sc18f2ad4cd3fb317fb8e028488694088"
    expiration    "2015-05-10T16:48:30.760460Z"
 */

struct Session: Codable {
    let id:String
    let expiration: String
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct UdacityLoginResponse: Codable {
    let session: Session
    let account: Account
}

extension UdacityLoginResponse: LocalizedError {
    var errorDescription: String? {
        return account.key
    }
}
