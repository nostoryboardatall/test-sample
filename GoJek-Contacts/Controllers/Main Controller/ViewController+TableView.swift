//
//  ViewController+TableView.swift
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
// Main ViewController class - extension for UITableViewDelegate, UITableViewDataSource
//*******************************************
extension ViewController: UITableViewDelegate, UITableViewDataSource {
// MARK: -Standard tableView methods
    // fix breaking constraints scrolling to row
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let items = items else { return 0 }
        return items.sortedIndexes.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard let items = items else { return [] }
        return items.sortedIndexes
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let items = items else { return "" }
        return items.sortedIndexes[ section ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = items else { return 0 }
        let key = items.sortedIndexes[ section ]
        return items.itemsAsDictionary[ key ]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactCellID, for: indexPath)
        
        // fill the contact cell
        if let cell = cell as? ContactCell, let items = items {
            if let person = items.person(witn: indexPath) {
                cell.person = person
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let person = items?.person(witn: indexPath) else { return }
        
        // navigate to detailViewController
        let detailViewController = DetailController()
        detailViewController.person = person
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // update tableView rows and section after main array updating
    func tableViewUpdate(sectionsBefore: [String],
                   sectionBefore: String, sectionAfter: String,
                   indexPathBefore: IndexPath, indexPathAfter: IndexPath) {
        DispatchQueue.main.async {
            let sectionsAfter = self.items?.sortedIndexes ?? []
            
            let indexBefore = sectionsBefore.firstIndex(of: sectionAfter) ?? -1
            let indexAfter = sectionsAfter.firstIndex(of: sectionBefore) ?? -1
            
            if ( indexPathAfter == indexPathBefore ) {
                self.tableView.reloadRows(at: [indexPathAfter], with: .fade)
            } else {
                self.tableView.beginUpdates()
                
                self.tableView.deleteRows(at: [indexPathBefore], with: .automatic)
                if ( sectionBefore != sectionAfter ) {
                    if ( indexAfter == -1 ) {
                        // delete section
                        if let removeSectionIndex = sectionsBefore.firstIndex(of: sectionBefore) {
                            let indexSet = IndexSet(integer: removeSectionIndex)
                            self.tableView.deleteSections(indexSet, with: .automatic)
                        }
                    }
                    if ( indexBefore == -1 ) {
                        // add section
                        if let newSectionIndex = sectionsAfter.firstIndex(of: sectionAfter) {
                            let indexSet = IndexSet(integer: newSectionIndex)
                            self.tableView.insertSections(indexSet, with: .automatic)
                        }
                    }
                }
                self.tableView.insertRows(at: [indexPathAfter], with: .automatic)
                
                self.tableView.endUpdates()
                
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: indexPathAfter, at: .none, animated: true)
            }
        }
    }
    
    // update tableView rows and section after main array appending contact
    func tableViewAppend(_ person: Person, at indexPath: IndexPath, oldSections: [String]) {
        DispatchQueue.main.async {
            let isSectionExists = oldSections.firstIndex(of: person.firstIndex) ?? -1
            
            self.tableView.beginUpdates()
            
            if ( isSectionExists == -1 ) {
                let indexSet = IndexSet(integer: indexPath.section)
                self.tableView.insertSections(indexSet, with: .automatic)
            }
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }
}
