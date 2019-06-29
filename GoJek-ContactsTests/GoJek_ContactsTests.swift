//
//  GoJek_ContactsTests.swift
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

class PersonTests: XCTestCase {

    var personUnderTest: Person!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        personUnderTest = Person()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        personUnderTest = nil
    }

    func testCorrectDecode() {
        // 1. given
        let jsonString = [
            "id": 1,
            "first_name": "Amitabh",
            "last_name": "Bachchan",
            "email": "ab@bachchan.com",
            "phone_number": "+919980123412",
            "profile_pic": "https://contacts-app.s3-ap-southeast-1.png",
            "favorite": false,
            "url": "https://gojek-contacts-app.herokuapp.com/contacts/1.json"
        ] as [String : Any]
        
        // 2. when
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonString) {
                personUnderTest = try JSONDecoder().decode(Person.self, from: jsonData )
                
                // 3. then
                XCTAssertEqual(personUnderTest.id, 1, "Decode <id> is wrong")
                XCTAssertEqual(personUnderTest.firstName, "Amitabh", "Decode <firstName> is wrong")
                XCTAssertEqual(personUnderTest.lastName, "Bachchan", "Decode <lastName> is wrong")
                XCTAssertEqual(personUnderTest.email, "ab@bachchan.com", "Decode <firstName> is wrong")
                XCTAssertEqual(personUnderTest.phone, "+919980123412", "Decode <lastName> is wrong")
                XCTAssertEqual(personUnderTest.profilePic, "https://contacts-app.s3-ap-southeast-1.png",
                               "Decode <picture URL> is wrong")
                XCTAssertEqual(personUnderTest.isFavourite, false, "Decode <isFavorite> is wrong")
                XCTAssertEqual(personUnderTest.url, "https://gojek-contacts-app.herokuapp.com/contacts/1.json",
                               "Decode <url> is wrong")
                XCTAssertEqual(personUnderTest.fullName, "Amitabh Bachchan", "Decode <full name> is wrong")
                XCTAssertEqual(personUnderTest.clearPhoneNumber, "919980123412", "Decode <clear phone> is wrong")
                XCTAssertEqual(personUnderTest.firstIndex, "A", "Decode <firstIndex> is wrong")
            } else {
                // fail
                 XCTFail("Error creating JSON")
            }
        } catch let error {
            // fail
            XCTFail(error.localizedDescription)
        }
    }

    func testCorrectEncode() {
        // 1. given
        personUnderTest.id =  1
        personUnderTest.firstName = "Amitabh"
        personUnderTest.lastName = "Bachchan"
        personUnderTest.email = "ab@bachchan.com"
        personUnderTest.phone = "+919980123412"
        personUnderTest.profilePic = "https://contacts-app.s3-ap-southeast-1.png"
        personUnderTest.isFavourite = false
        personUnderTest.url = "https://gojek-contacts-app.herokuapp.com/contacts/1.json"
        
        var jsonData = Data()
        // 2. when
        do {
            jsonData = try JSONEncoder().encode(personUnderTest)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        let dataAsString = String(data: jsonData, encoding: .utf8)
        
        // 3. then
        XCTAssertEqual(dataAsString!, "{\"email\":\"ab@bachchan.com\",\"profile_pic\":\"https:\\/\\/contacts-app.s3-ap-southeast-1.png\",\"last_name\":\"Bachchan\",\"favorite\":false,\"phone_number\":\"+919980123412\",\"first_name\":\"Amitabh\"}", "Encode error")
    }
    
    func testCorrectCopy() {
        // 1. given
        personUnderTest.id =  1
        personUnderTest.firstName = "Amitabh"
        personUnderTest.lastName = "Bachchan"
        personUnderTest.email = "ab@bachchan.com"
        personUnderTest.phone = "+919980123412"
        personUnderTest.profilePic = "https://contacts-app.s3-ap-southeast-1.png"
        personUnderTest.isFavourite = false
        personUnderTest.url = "https://gojek-contacts-app.herokuapp.com/contacts/1.json"

        // 2. when
        let copyPerson = Person()
        copyPerson.copy(with: personUnderTest)
        
        // 3. then
        XCTAssertEqual(copyPerson.id, 1, "Copy <id> is wrong")
        XCTAssertEqual(copyPerson.firstName, "Amitabh", "Copy <firstName> is wrong")
        XCTAssertEqual(copyPerson.lastName, "Bachchan", "Copy <lastName> is wrong")
        XCTAssertEqual(copyPerson.email, "ab@bachchan.com", "Copy <firstName> is wrong")
        XCTAssertEqual(copyPerson.phone, "+919980123412", "Copy <lastName> is wrong")
        XCTAssertEqual(copyPerson.profilePic, "https://contacts-app.s3-ap-southeast-1.png",
                       "Copy <picture URL> is wrong")
        XCTAssertEqual(copyPerson.isFavourite, false, "Copy <isFavorite> is wrong")
        XCTAssertEqual(copyPerson.url, "https://gojek-contacts-app.herokuapp.com/contacts/1.json",
                       "Copy <url> is wrong")
    }
    
    func testValidate() {
        // 1. given
        let firstName = "Amitabh"
        let email = "ab@bachchan.com"
        let phone = "12345678901"

        // 2. when
        let isFirstName = Person.validateName(firstName)
        let isEmail = Person.validateEmail(email)
        let isPhone = Person.validatePhone(phone)
        
        // 3. then
        XCTAssertEqual(isFirstName, true, "Validate error")
        XCTAssertEqual(isEmail, true, "Validate error")
        XCTAssertEqual(isPhone, true, "Validate error")
    }
}
