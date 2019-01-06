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
    }

    enum Endpoints {
        static let sessionBase = "https://onthemap-api.udacity.com/v1/session"
        static let base = "https://parse.udacity.com"
        
        case getSession
        case getStudentLocations
        case getStudentLocation(String)
        case createStudentLocation

        
        var stringValue: String {
            switch self {
            case .getSession: return Endpoints.sessionBase
            case .getStudentLocations: return Endpoints.base + "/parse/classes/StudentLocation?limit=100&&order=-updatedAt"
            case .getStudentLocation(let studentId): return Endpoints.base + "/parse/classes/StudentLocation?where=\(studentId)"
            case .createStudentLocation: return Endpoints.base + "/parse/classes/StudentLocation"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }

    /*
     Get a single student
    */
    class func getStudent(studentId: String, completion: @escaping (Student?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getStudentLocation(studentId).url, response: StudentResponse.self) { (response, error) in
            if let response = response {
                completion(response.results[0], nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    /*
     Create student
     */
    class func createStudentLocation(completion: @escaping (Bool, Error?) -> Void) {
        
    }
    
    /*
     Get 100 student locations per execution.  Use skip variable to control the segment
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
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityLoginResponse.self, from: newData)
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
}
