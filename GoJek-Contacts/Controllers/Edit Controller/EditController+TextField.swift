//
//  EditController+TextField.swift
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

import UIKit

//*******************************************
// EditPersonController class - extension for UITableViewDelegate, UITableViewDataSource
//*******************************************
extension EditPersonController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 1. remove error view if exists
        if let cell = textField.superview as? DataCell {
            cell.removeError()
        }
        
        // 3. calculate bottom for keyboard view
        let origin = textField.convert(textField.frame.origin, to: view)
        bottomAnchor = origin.y + textField.frame.size.height
        
        // 4. move tableview offset if needed
        if ( isKeyboardPresent && bottomAnchor > keyboardTop ) {
            updateTableViewOffset(to: bottomAnchor - keyboardTop)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 1. clear table view offset
        updateTableViewOffset()
        
        // 2. fill cell with entered value
        if let cell = textField.superview as? DataCell {
            cell.value = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // hide keyboard
        return textField.endEditing(true)
    }
    
    //*************************************************************************
    // Keyboard notifications
    //*************************************************************************
    func subscribeForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didShowKeyboard),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didHideKeyboard),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardDidHideNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardDidShowNotification)
    }
    
    @objc func willShowKeyboard(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            keyboardTop = UIScreen.main.bounds.height - (keyboardHeight + 12.0)
            if bottomAnchor > keyboardTop {
                updateTableViewOffset(to: bottomAnchor - keyboardTop)
            }
        }
    }
    
    @objc func willHideKeyboard(_ notification: Notification) {
        updateTableViewOffset()
    }
    
    @objc func didHideKeyboard(_ notification: Notification) {
        isKeyboardPresent = false
        keyboardTop = 0.0
    }
    
    @objc func didShowKeyboard(_ notification: Notification) {
        isKeyboardPresent = true
    }    
}
