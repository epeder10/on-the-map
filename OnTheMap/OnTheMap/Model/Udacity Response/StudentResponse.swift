//
//  StudentResponse.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/6/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation
/*
 "results":[
 {
 "createdAt": "2015-02-25T01:10:38.103Z",
 "firstName": "Jarrod",
 "lastName": "Parkes",
 "latitude": 34.7303688,
 "longitude": -86.5861037,
 "mapString": "Huntsville, Alabama ",
 "mediaURL": "https://www.linkedin.com/in/jarrodparkes",
 "objectId": "JhOtcRkxsh",
 "uniqueKey": "996618664",
 "updatedAt": "2015-03-09T22:04:50.315Z"
 }
 */
/*
 {
 "objectId":"RRZ2C7akdV",
 "uniqueKey":"89039766",
 "firstName":"Mohammed",
 "lastName":"Ahmed",
 "mapString":"buraidah",
 "mediaURL":"wwww",
 "latitude":26.3317931,
 "longitude":43.9704602,
 "createdAt":"2019-01-06T09:58:12.863Z",
 "updatedAt":"2019-01-06T09:58:12.863Z"}
 */
struct Student: Codable {
    let createdAt: String?
    let firstName: String?
    let lastName: String?
    let latitude: Double?
    let longitude: Double?
    let mapString: String?
    let mediaURL: String?
    let objectId: String?
    let uniqueKey: String?
    let updatedAt: String?
}

struct StudentResponse: Codable {
    let results: [Student]
}
