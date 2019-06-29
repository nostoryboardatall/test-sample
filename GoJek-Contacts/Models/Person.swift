//
//  Person.swift
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

//*******************************************
// Base model class for storing contact data
// Conform Codable protocol to let decode and encode with JSON
//*******************************************
class Person: Codable {
// MARK: -Properties
    public var id: Int?
    public var url: String?
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var phone: String?
    public var profilePic: String?
    public var isFavourite: Bool?
    public var createdAt: String?
    public var updatedAt: String?
    
    // unique key for each person
    public var key: NSString {
        return (url ?? "") as NSString
    }

    // calculated full name
    public var fullName: String {
        guard let firstName = firstName, let lastName = lastName else { return "" }
        return (firstName + " " + lastName).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // calculated clear phone number to ability making a call from the app
    public var clearPhoneNumber: String {
        guard let phone = phone else { return "" }
        return phone.digits()
    }

    // first character - for sections
    public var firstIndex: String {
        guard let firstName = firstName, let lastName = lastName else { return "" }
        let str = (firstName + " " + lastName).trimmingCharacters(in: .whitespacesAndNewlines)
        return str.prefix(1).uppercased()
    }

    // enum for Codable protocol
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case phone = "phone_number"
        case profilePic = "profile_pic"
        case isFavourite = "favorite"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
// MARK: -Initialization
    // simple init - set isFavourite to false cause there is no
    // possibility in UI to change it according to technical details
    init() {
        self.isFavourite = false
    }
    
    // init from JSONDecoder
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
        isFavourite = try values.decodeIfPresent(Bool.self, forKey: .isFavourite)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
// MARK: -Methods
    // encode to JSONEncoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(phone, forKey: .phone)
        try container.encode(email, forKey: .email)
        try container.encode(isFavourite, forKey: .isFavourite)
        try container.encode(profilePic, forKey: .profilePic)
    }
    
    // copy instanse to another Person
    public func copy(with person: Person) {
        self.id = person.id
        self.url = person.url
        self.firstName = person.firstName
        self.lastName = person.lastName
        self.email = person.email
        self.phone = person.phone
        self.profilePic = person.profilePic
        self.isFavourite = person.isFavourite
        self.createdAt = person.createdAt
        self.updatedAt = person.updatedAt
    }
    
    // set value by KeyPath
    public func set(_ value: String?, forKeyPath path: ReferenceWritableKeyPath<Person, String?>) {
        self[keyPath: path] = value
    }

// MARK: -Class Methods
//  validate if email is correct
    public class func validateEmail(_ value: String?) -> Bool {
        guard let value = value else { return false }
        
        let format = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", format)
        
        return predicate.evaluate(with: value)
    }
    
    // validate phone - it must be 11 digits length cause of backand validation
    public class func validatePhone(_ value: String?) -> Bool {
        guard let value = value else { return false }
        return (!value.isEmpty && value.count == API.minimumPhoneNumberLength)
    }
    
    // validate name - it must be atleast 2 digits length cause of backand validation
    public class func validateName(_ value: String?) -> Bool {
        guard let value = value else { return false }
        return value.count >= API.minimumNameLength
    }
}
