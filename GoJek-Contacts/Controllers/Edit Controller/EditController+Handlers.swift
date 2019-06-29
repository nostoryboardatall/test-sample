//
//  EditController+Handlers.swift
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
import Photos

extension EditPersonController {
    // action
    @objc public func done() {
        guard let person = person else { return }
        
        let newPerson = Person()
        newPerson.copy(with: person)
        
        // validate fields - if field is correct, fill newPerson instance
        var isThereErrors: Bool = false
        tableView.visibleCells.forEach { (_ cell) in
            if let cell = cell as? DataCell {
                cell.endEditing(true)
                cell.removeError()
                if ( cell.validate() == false ) {
                    isThereErrors = true
                    cell.addError()
                } else {
                    if let keyPath = cell.keyPath {
                        newPerson.set(cell.value, forKeyPath: keyPath)
                    }
                }
            }
        }
        
        // if all data is correct - action
        if ( !isThereErrors ) {
            // 1. loading view...
            loadingView.title = ( action == .new ) ? "Creating contact..." : "Updating contact..."
            loadingView.startLoading()
            if ( action == .new ) {
                // 2. append action
                ContactAPIManager.shared.append(newPerson) { [unowned self] ( result ) in
                    // 3. handle result
                    self.handleResult( result )
                }
            } else {
                // 2. update action
                ContactAPIManager.shared.update(with: newPerson) { [unowned self] ( result ) in
                    // 3. handle result
                    self.handleResult( result )
                }
            }
        }
    }
    
    // navigate to root view controller
    @objc public func cancel() {
        navigationController?.popToRootViewController(animated: true)
    }

    // open action sheet and select picture
    @objc public func choosePicture() {
        let alert = UIAlertController(title: "Select photo", message: "", preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.imagePicker = imagePicker
        
        alert.addAction(UIAlertAction(title: "Take a picture", style: .default , handler:{ [unowned self] (_) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.handleError(PhotoError.noCamera)
                return
            }

            AVCaptureDevice.requestAccess(for: .video, completionHandler: {(aithorizationStatus) in
                if aithorizationStatus {
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
                    self.present(imagePicker, animated: true, completion: nil)
                } else {
                    self.handleError(PhotoError.noAccessToCamera)
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from library", style: .default, handler:{ [unowned self] (_) in
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                self.handleError(PhotoError.noLibrary)
                return
            }

            PHPhotoLibrary.requestAuthorization({(authorizationStatus) in
                if authorizationStatus ==  PHAuthorizationStatus.authorized {
                    self.imagePicker.sourceType = .photoLibrary
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
                    self.present(imagePicker, animated: true, completion: nil)
                } else {
                    self.handleError(PhotoError.noAccessToLibrary)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // handling the result
    fileprivate func handleResult(_ result: Result<Person, Error>) {
        // 1. hide loading view
        DispatchQueue.main.async {
            self.loadingView.stopLoading()
        }
        switch result {
        case .success( let updatedPerson ):
            // succsess - 2. call delegate method
            if ( action == .new ) {
                delegate.didAppendContact(updatedPerson)
            } else {
                delegate.didUpdateContact(person, with: updatedPerson)
            }
            // 3. navigate to root view controller
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        case .failure( let error ):
            // 2. error - handle it and navigate to root view controller
            handleError(error) { [unowned self] (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
