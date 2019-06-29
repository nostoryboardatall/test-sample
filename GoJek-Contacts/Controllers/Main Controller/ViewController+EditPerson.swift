//
//  ViewController+EditPerson.swift
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
// Main ViewController class - extension for EditPersonDelegate
//*******************************************
extension ViewController: EditPersonDelegate {
    // after update contact on backend
    func didUpdateContact(_ before: Person?, with after: Person?) {
        guard let before = before, let after = after  else { return }
        
        // 1. save old sections
        let sectionsBefore = items?.sortedIndexes ?? []
        // 2. update the array
        self.items?.update(with: after, handler: { [unowned self] ( old, new ) in 
            if let old = old, let new = new {
                // 3. update tableView on succesfull completion
                self.tableViewUpdate(sectionsBefore: sectionsBefore,
                               sectionBefore: before.firstIndex, sectionAfter: after.firstIndex,
                               indexPathBefore: old, indexPathAfter: new)
            }
        })
    }
    
    // after append contact on backend
    func didAppendContact(_ person: Person?) {
        guard let person = person else { return }
        
        // 1. save old sections
        let sectionsBefore = items?.sortedIndexes ?? []
        // 2. update the array
        self.items?.append(person, handler: { [unowned self] (indexPath) in
            if let indexPath = indexPath {
                // 3. update tableView on succesfull completion
                self.tableViewAppend(person, at: indexPath, oldSections: sectionsBefore)
            }
        })
    }    
}
