//
//  DetailController+Handlers.swift
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

import MessageUI

//*******************************************
// DetailController class - extension for handlers navigation bar tap
// and bittons stack
//*******************************************
extension DetailController {
    @objc public func edit() {
        guard let topController = navigationController?.viewControllers.first as? ViewController else { return }
        
        let editController = EditPersonController()
        editController.delegate = topController
        editController.person = person
        editController.action = .update
        
        // navigate to edit view controller
        navigationController?.pushViewController(editController, animated: true)
    }
    
    @objc public func message() {
        guard let person = person else { return }
        
        if ( person.clearPhoneNumber.isEmpty ) { return }
        
        if (MFMessageComposeViewController.canSendText()) {
            // open message app
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [person.clearPhoneNumber]
            controller.messageComposeDelegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc public func call() {
        guard let person = person else { return }
        guard let number = URL(string: "tel://\(person.clearPhoneNumber)") else { return }
        
        // dial number
        UIApplication.shared.open(number)
    }
    
    @objc public func email() {
        guard let person = person else { return }
        if ( person.email?.isEmpty ?? true ) { return }
        
        let composeVC = MFMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            // open email app
            let email = person.email ?? ""
            let body = NSMutableString()
            body.append("Hello, \(person.fullName)")
            
            
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([email])
            composeVC.setSubject("Hello from GoJek Contacts App!")
            composeVC.setMessageBody(body as String, isHTML: true)
            
            present(composeVC, animated: true, completion: nil)
        }
    }
}
