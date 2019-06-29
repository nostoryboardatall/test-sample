//
//  EditController+TableView.swift
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
extension EditPersonController: UITableViewDelegate, UITableViewDataSource {
// MARK: -Standard tableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: dataCellID, for: indexPath)
        
        // fill rows with titles and values, styles etc...
        if let cell = cell as? DataCell {
            cell.delegate = self
            cell.isEditable = true
            switch indexPath.row {
            case 0:
                cell.title = "first name"
                cell.value = person?.firstName ?? ""
                cell.editStyle = .name
                cell.validationType = .noEmpty
                cell.keyPath = \Person.firstName
            case 1:
                cell.title = "last name"
                cell.value = person?.lastName ?? ""
                cell.editStyle = .name
                cell.validationType = .noEmpty
                cell.keyPath = \Person.lastName
            case 2:
                cell.title = "mobile"
                cell.value = person?.phone ?? ""
                cell.editStyle = .phone
                cell.validationType = .phoneNumber
                cell.keyPath = \Person.phone
            case 3:
                cell.title = "email"
                cell.value = person?.email ?? ""
                cell.editStyle = .email
                cell.validationType = .email
                cell.keyPath = \Person.email
            default:
                cell.title = ""
                cell.value = ""
            }
        }
        
        return cell
    }
    
    // hide other rows
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }

    // update offset depending on keyboard
    public func updateTableViewOffset(to delta: CGFloat = 0.0) {
        tableView.setContentOffset(CGPoint(x: 0.0, y: delta), animated: true)
    }
    
    // hide keyboard
    @objc func onTableViewTouchUpInside() {
        tableView.visibleCells.forEach { (_ cell) in
            if let cell = cell as? DataCell {
                cell.endEditing(true)
            }
        }
    }
}
