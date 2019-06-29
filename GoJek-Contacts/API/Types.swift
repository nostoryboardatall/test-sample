//
//  Types.swift
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
import UIKit

// Custom Errors
enum GJFetchError: Error {
    case invalidURL,
         dataIsNil,
         responseIsNil,
         invalidJSON,
         incompleteResult,
         unknownID,
         contactIsNotSet,
         unknownError
}

// Custom Error sdescription
extension GJFetchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .dataIsNil:
            return "Data is NULL"
        case .responseIsNil:
            return "Invalid Response"
        case .invalidJSON:
            return "Invalid JSON"
        case .unknownID:
            return "Unknown ID"
        case .contactIsNotSet:
            return "Contact has not been set"
        default:
            return "Unknown Error"
        }
    }
}

// Response error
public enum GJResponseError: LocalizedError {
    case invalidResponse(host: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(host: let host):
            return "Invalid response with code: \(host)"
        }
    }
}

// Custom Photo Error
enum PhotoError: Error {
    case noLibrary, noCamera, noAccessToCamera, noAccessToLibrary
}

// Custom Photo Error description
extension PhotoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noCamera:
            return "Camera is not available on that device"
        case .noLibrary:
            return "Photo library is not available on that device"
        case .noAccessToCamera:
            return "Grant accsess to camera if you want to take an user picture"
        case .noAccessToLibrary:
            return "Grant accsess to photo library if you want to add an user picture"
        }
    }
}

// Constants
enum API {
    static let baseURL: String = "http://gojek-contacts-app.herokuapp.com"
    static let succsessRequestCodes: Set<Int> = [200, 201]
    static let minimumPhoneNumberLength = 11
    static let minimumNameLength = 2
}

// button for detail view
struct StackButton {
    var button: UIButton?
    var title: String?
}
