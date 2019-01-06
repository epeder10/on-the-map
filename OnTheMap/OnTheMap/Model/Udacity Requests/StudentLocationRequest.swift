//
//  StudentLocationRequest.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/6/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation

/*
 {"uniqueKey": "1234",
 "firstName": "John",
 "lastName": "Doe",
 "mapString": "Mountain View, CA",
 "mediaURL": "https://udacity.com",
 "latitude": 37.386052,
 "longitude": -122.083851}
 */

struct StudentLocationRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
