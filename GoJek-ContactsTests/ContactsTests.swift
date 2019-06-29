//
//  ContactsTests.swift
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

import XCTest
@testable import GoJek_Contacts

class ContactsTests: XCTestCase {

    var contactsUnderTest: Contacts!
    var jsonString: [[String : Any]]!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        jsonString = [[
            "id": 1,
            "first_name": "Amitabh",
            "last_name": "Bachchan",
            "profile_pic": "https://contacts-app.s3-ap-southeast-1.amazonaws.com/contacts/profile_pics/000/000/007/original/ab.jpg?1464516610",
            "favorite": false,
            "url": "https://gojek-contacts-app.herokuapp.com/contacts/1.json"
        ],
        [
            "id": 2,
            "first_name": "Shahrukh",
            "last_name": "Khan",
            "profile_pic": "https://contacts-app.s3-ap-southeast-1.amazonaws.com/contacts/profile_pics/000/000/008/original/srk.jpg?1464516694",
            "favorite": false,
            "url": "https://gojek-contacts-app.herokuapp.com/contacts/1.json"
        ]]

        contactsUnderTest = Contacts()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        contactsUnderTest = nil
    }

    func testDecode() {
        // 1. given
        
        // 2. when
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonString!) {
                contactsUnderTest = try JSONDecoder().decode(Contacts.self, from: jsonData )

            // 3. then
                XCTAssertEqual(contactsUnderTest.items?.count, 2, "Decode is wrong")
                XCTAssertEqual(contactsUnderTest.sortedIndexes, ["A", "S"], "Decode is wrong")
            } else {
                // fail
                XCTFail("Error creating JSON")
            }
        } catch let error {
            // fail
            XCTFail(error.localizedDescription)
        }
    }
    
    func testUpdate() {
        // 1. given
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonString!) {
                contactsUnderTest = try JSONDecoder().decode(Contacts.self, from: jsonData )
            } else { XCTFail("Error creating JSON") }
        } catch let error { XCTFail(error.localizedDescription) }
        
        let _jsonString = [
            "id": 2,
            "first_name": "Amitabh",
            "last_name": "Bachchan",
        ] as [String : Any]
        
        var person = Person()
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: _jsonString) {
                person = try JSONDecoder().decode(Person.self, from: jsonData )
            } else { XCTFail("Error creating JSON") }
        } catch let error { XCTFail(error.localizedDescription) }

        // 2. when
        contactsUnderTest.update(with: person) { (_, _) in
        }
        
        // 3. then
        XCTAssertEqual(contactsUnderTest.items?.count, 2, "Update is wrong")
        XCTAssertEqual(contactsUnderTest.sortedIndexes, ["A"], "Update is wrong")
    }

    func testAppend() {
        // 1. given
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonString!) {
                contactsUnderTest = try JSONDecoder().decode(Contacts.self, from: jsonData )
            } else { XCTFail("Error creating JSON") }
        } catch let error { XCTFail(error.localizedDescription) }
        
        let _jsonString = [
            "id": 3,
            "first_name": "John",
            "last_name": "Applessed",
        ] as [String : Any]
        
        var person = Person()
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: _jsonString) {
                person = try JSONDecoder().decode(Person.self, from: jsonData )
            } else { XCTFail("Error creating JSON") }
        } catch let error { XCTFail(error.localizedDescription) }
        
        // 2. when
        contactsUnderTest.append(person) { (_) in
        }
        
        // 3. then
        XCTAssertEqual(contactsUnderTest.items?.count, 3, "Append is wrong")
        XCTAssertEqual(contactsUnderTest.sortedIndexes, ["A", "J", "S"], "Append is wrong")
    }
    func testPerson() {
        // 1. given
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonString!) {
                contactsUnderTest = try JSONDecoder().decode(Contacts.self, from: jsonData )
            } else { XCTFail("Error creating JSON") }
        } catch let error { XCTFail(error.localizedDescription) }

        var person = Person()
        
        // 2. when
        person = contactsUnderTest.person(witn: IndexPath(item: 0, section: 0))!
        
        // 3. then
        XCTAssertEqual(person.id, 1, "person searching is wrong")
    }
    
    func testIndexPath() {
        // 1. given
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonString!) {
                contactsUnderTest = try JSONDecoder().decode(Contacts.self, from: jsonData )
            } else { XCTFail("Error creating JSON") }
        } catch let error { XCTFail(error.localizedDescription) }
        
        let person = contactsUnderTest.person(witn: IndexPath(item: 0, section: 0))!
        
        // 2. when
        var indexPath = contactsUnderTest.indexPath(for: person)
        
        // 3. then
        XCTAssertEqual(indexPath?.row, 0, "indexPath is wrong")
        XCTAssertEqual(indexPath?.section, 0, "indexPath is wrong")
    }
}
