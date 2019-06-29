//
//  ContactLoader.swift
//
//  Created by Home on 2019.
//  Copyright 2017-2018 NoStoryboardsAtAll Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

// class for NSCache key-value
//
// Use for storing UIImage as Data
fileprivate class CacheValue {
    var value: Data = Data()
    
    init(_ value: Data) {
        self.value = value
    }
}

// Singletone pattern
class ContactAPIManager {
    
// Singletone's instance
    static let shared = ContactAPIManager(baseURL: API.baseURL)
    
// MARK: -Properties
    var baseURL: String
    
    // Caches for application
    // Two separate caches for images and data - image cache is filled
    // during the main table loading and person cache is filled when user tap on
    // contact and get the detailed information
    
    // Image Cache
    fileprivate let imageCache = NSCache<NSString, CacheValue>()
    
    // Person Cache
    fileprivate let personCache = NSCache<NSString, Person>()
    
// MARK: -Initialization
    private init(baseURL: String) {
        self.baseURL = baseURL
    }
    
// MARK: -Public Methods
    // Try to get profile picture from cache otherwise return nil
    public func getImageDataFromCache(_ path: String) -> Data? {
        return imageCache.object(forKey: path as NSString)?.value
    }

    // Try to get profile data from cache otherwise return nil
    public func getDetailedPersonFromCache(_ person: Person) -> Person? {
        return personCache.object(forKey: person.key)
    }
    
    // Download image as data
    public func downloadImage(for person: Person, completionHandler: @escaping ( (Result<Data, Error>) -> Void)) {
        // creating download path and checking if it is a "missing" image
        var path = person.profilePic ?? ""
        if ( !path.contains("http") ) { path =  "\(baseURL)\(path)" }
        
        // final check that url is correct
        guard let url = URL(string: path) else {
            completionHandler(.failure(GJFetchError.invalidURL))
            return
        }
        
        // try to get image from cache
        if let imageData = getImageDataFromCache(path) {
            completionHandler(.success(imageData))
        // not found in cache - download
        } else {
            URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
                if let error = error {
                    // handle download error
                    completionHandler(.failure(error))
                    return
                }
                
                if let data = data {
                    // success
                    // 1. set cache
                    self.imageCache.setObject(CacheValue(data), forKey: path as NSString)
                    
                    // 2. handle succsess
                    completionHandler(.success(data))
                    return
                }
                // data is nil - handle error
                completionHandler(.failure(GJFetchError.dataIsNil))
            }.resume()
        }
    }
    
    // Fetch all contacts from the backend with escaping completion handler
    public func fetch(completionHandler: @escaping ( (Result<Contacts, Error>) -> Void)) {
        let urlString = "\(baseURL)/contacts.json"

        get(urlString) { ( result ) in
            // handle the result
            switch result {
            case .success( let data ):
                do {
                    // if success - try to decode JSON data to model class,
                    // otherwise handle decode error
                    let fetchedResult = try JSONDecoder().decode(Contacts.self, from: data)
                    completionHandler(.success( fetchedResult ))
                } catch let decodeError {
                    completionHandler(.failure( decodeError ))
                }
            case .failure( let error ):
                /// handle dataTask error
                completionHandler(.failure(error))
            }
        }
    }

    // Fetch contact's  detail from the backend with escaping completion handler
    public func fetchDetail(for person: Person, completionHandler: @escaping ( (Result<Person, Error>) -> Void)) {
        // try to get detail info from cache
        if let cachedPerson = getDetailedPersonFromCache(person) {
            completionHandler(.success( cachedPerson ))
            
        // not found in cache - fetching from backend
        } else {
            get(person.url ?? "") { [unowned self] ( result ) in
                // handle the result
                switch result {
                case .success( let data ):
                    do {
                        // if success - try to decode JSON data to model class,
                        // otherwise handle decode error
                        let fetchedPerson = try JSONDecoder().decode(Person.self, from: data)
                        fetchedPerson.url = person.url
                        
                        // caching details
                        self.personCache.setObject(fetchedPerson, forKey: person.key)
                        
                        // completion handler
                        completionHandler(.success( fetchedPerson ))
                    } catch let decodeError {
                         // handle decode error
                        completionHandler(.failure( decodeError ))
                    }
                case .failure( let error ):
                    // handle dataTask error
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    // Update contact's details to backend
    public func update(with person: Person, completionHandler: @escaping ( (Result<Person, Error>) -> Void)) {
        // first check that the url (person id) is set
        guard let path = person.url else {
            completionHandler(.failure(GJFetchError.unknownID))
            return
        }
        
        do {
            // try to encode model class to JSON
            let jsonData = try JSONEncoder().encode(person)
            
            // encode success, send data to backend
            post(path, method: "PUT", raw: jsonData) { ( result ) in
                // handle the result
                switch result {
                case .success( let data ):
                    do {
                        // if success - try to decode JSON data to model class,
                        // otherwise handle decode error
                        let fetchedPerson = try JSONDecoder().decode(Person.self, from: data)
                        fetchedPerson.url = person.url
                        
                        // updating cache
                        self.personCache.setObject(fetchedPerson, forKey: person.key)
                        
                        // completion handler
                        completionHandler(.success( fetchedPerson ))
                    } catch let decodeError {
                        // handle decode error
                        completionHandler(.failure( decodeError ))
                    }
                case .failure( let error ):
                    // handle dataTask error
                    completionHandler(.failure(error))
                }
            }
        } catch let encodeError {
            // handle encode error
            completionHandler(.failure( encodeError ))
        }
    }
    
    // Append contact to backend
    public func append(_ person: Person, completionHandler: @escaping ( (Result<Person, Error>) -> Void)) {
        do {
            let path = "\(baseURL)/contacts.json"
            
            // try to encode model class to JSON
            let jsonData = try JSONEncoder().encode(person)
            
            // encode success, send data to backend
            post(path, method: "POST", raw: jsonData) { ( result ) in
                // handle the result
                switch result {
                case .success( let data ):
                    do {
                        // if success - try to decode JSON data to model class,
                        // otherwise handle decode error
                        let fetchedPerson = try JSONDecoder().decode(Person.self, from: data)
                        fetchedPerson.url = "\(self.baseURL)/contacts/\(fetchedPerson.id ?? 0).json"
                        
                        // updating cache
                        self.personCache.setObject(fetchedPerson, forKey: person.key)
                        
                        // completion handler
                        completionHandler(.success( fetchedPerson ))
                    } catch let decodeError {
                        // handle decode error
                        completionHandler(.failure( decodeError ))
                    }
                case .failure( let error ):
                    // handle dataTask error
                    completionHandler(.failure(error))
                }
            }
        } catch let encodeError {
            // handle encode error
            completionHandler(.failure( encodeError ))
        }
    }

// MARK: -Private Methods
    // Get data from backend
    fileprivate func get(_ path: String, completionHandler: @escaping ( (Result<Data, Error>) -> Void) ) {
        // 1. creating query URL
        guard let url = URL(string: path) else {
            completionHandler(.failure(GJFetchError.invalidURL))
            return
        }

        // 2. creating the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 3. fire dataTask
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // 4. check for standart errors
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            // 5. check for data is not nil
            guard let data = data else {
                completionHandler(.failure(GJFetchError.dataIsNil))
                return
            }

            // 6. check that response exists and return succsess code
            if let httpResponse = response as? HTTPURLResponse {
                if ( !API.succsessRequestCodes.contains(httpResponse.statusCode) ) {
                    let responseError = GJResponseError.invalidResponse(host: "[\(httpResponse.statusCode)]")
                    completionHandler(.failure( responseError ))
                    return
                }
            } else {
                completionHandler(.failure(GJFetchError.responseIsNil))
                return
            }
            
            // 7. success
            completionHandler(.success(data))
        }.resume()
    }
    
    // Post data to backend
    fileprivate func post(_ path: String, method: String, raw: Data,
                          completionHandler: @escaping ( (Result<Data, Error>) -> Void) ) {
        // 1. creating query URL and creating the request
        guard let url = URL(string: path) else {
            completionHandler(.failure(GJFetchError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        
        // 2. specify this request method
        request.httpMethod = method
        
        // 3. make sure that we include headers specifying that our request's HTTP body will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        // 4. setting up the body with raw data
        request.httpBody = raw
        
        // 5. fire dataTask
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // 6. check for standart errors
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            // 7. check for data is not nil
            guard let data = data else {
                completionHandler(.failure(GJFetchError.dataIsNil))
                return
            }
            
            // 8. check if the response exists and equal 200 (or 201.....)
            if let httpResponse = response as? HTTPURLResponse {
                if ( !API.succsessRequestCodes.contains(httpResponse.statusCode) ) {
                    let responseError = GJResponseError.invalidResponse(host: "[\(httpResponse.statusCode)]")
                    completionHandler(.failure( responseError ))
                    return
                }
            } else {
                completionHandler(.failure(GJFetchError.responseIsNil))
                return
            }
            // 9. success
            completionHandler(.success(data))
        }.resume()
    }
}
