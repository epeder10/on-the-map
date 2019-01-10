//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/5/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation

class UdacityClient {
    struct Auth {
        static var sessionId = ""
        static var userId = ""
        static var udacityUser: UdacityUserResponse? = nil
    }

    enum Endpoints {
        static let sessionBase = "https://onthemap-api.udacity.com/v1/session"
        static let onthemapBase = "https://onthemap-api.udacity.com/v1"
        static let base = "https://parse.udacity.com"
        
        case getSession
        case getStudent(String)
        case getStudentLocations
        case getStudentLocation(String)
        case deleteSession
        case createStudentLocation

        
        var stringValue: String {
            switch self {
            case .getSession: return Endpoints.onthemapBase + "/session"
            case .getStudent(let userId): return Endpoints.onthemapBase + "/users/\(userId)"
            case .getStudentLocations: return Endpoints.base + "/parse/classes/StudentLocation?limit=100&order=-updatedAt"
            case .getStudentLocation(let studentId): return Endpoints.base + "/parse/classes/StudentLocation?where=\(studentId)"
            case .createStudentLocation: return Endpoints.base + "/parse/classes/StudentLocation"
            case .deleteSession: return Endpoints.onthemapBase + "/session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    /*
     Delete the current session and logout
     */
    class func deleteSession(completion: @escaping (Bool, Error?) -> Void) {
        specialTaskForDELETEequest(url: Endpoints.deleteSession.url, response: UdacityDeleteResponse.self) { (response, error) in
            if let error = error {
                completion(false, error)
            } else {
                Auth.sessionId = ""
                Auth.userId = ""
                Auth.udacityUser = nil
                completion(true, nil)
            }
        }
    }
    
    class func getStudent(completion: @escaping (Bool, Error?) -> Void) {
        specialTaskForGETRequest(url: Endpoints.getStudent(Auth.userId).url, response: UdacityUserResponse.self) { (response, error) in
            if let response = response {
                Auth.udacityUser = response
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

    /*
     Create student location
     */
    class func createStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?) -> Void) {
        if let udacityUser = Auth.udacityUser {
            let uuid = NSUUID().uuidString
            
            let studentLocation = StudentLocationRequest(uniqueKey: uuid, firstName: udacityUser.firstName, lastName: udacityUser.lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
            
            taskForPOSTRequest(url: Endpoints.createStudentLocation.url, responseType: UdacityLocationResponse.self, body: studentLocation) { (response, error) in
                if let response = response {
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        }
    }
    
    /*
     Get 100 of the most recent student locations.
    */
    class func getStudentLocations(completion: @escaping ([Student], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getStudentLocations.url, response: StudentResponse.self) { (response, error) in
            if let response = response {
                completion(response.results , nil)
            } else {
                completion([], error)
            }
        }
    }
    
    /*
     getSessionID uses its own POST request since the first 5 bytes need to be ignored
     */
    class func getSessionID(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.getSession.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let udacityLogin = UdacityLoginRequest(udacity: Udacity(username: username, password: password))
        request.httpBody = try! JSONEncoder().encode(udacityLogin)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(false, error)
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                let udacityLoginResponse = try decoder.decode(UdacityLoginResponse.self, from: newData)
                Auth.sessionId = udacityLoginResponse.session.id
                Auth.userId = udacityLoginResponse.account.key
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityErrorResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(false, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    /*
     Special GET request ignores the first 5 bytes of the response
    */
    class func specialTaskForGETRequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject.self, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForGETRequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject.self, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")

        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /*
     Special DELETE request ignores the first 5 bytes of the response
     */
    class func specialTaskForDELETEequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject.self, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
