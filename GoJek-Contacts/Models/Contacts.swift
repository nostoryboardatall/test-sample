//
//  Contacts.swift
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
// Model class for storing person array
// Conform Decodable protocol to let decode from JSON
//*******************************************
class Contacts: Decodable {
// MARK: -Properties
//  person's array
    public var items: [Person]?
    
    // sorted array with persons and keys - sections heders
    public var itemsAsDictionary = [String: [Person]]()
    
    // clear array for section headers
    public var sortedIndexes: [String] = []
    
// MARK: -Initialization
    // simple init
    init() {
    }

    // decode from JSON and prepare dictionary
    required public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        items = try values.decode([Person].self)
        updateDictionary()
    }
    
// MARK: -Public Methods
    // update self.person founded by <id> with person
    // after completion fire <handler> block for possible tableView update
    public func update(with person: Person, handler: @escaping ( (IndexPath?, IndexPath?) -> Void) ) {
        guard let _ = items else { return }
        
        if let found = items?.enumerated().first(where: {$0.element.id == person.id}) {
            let oldIndexPath = indexPath(for: items?[found.offset])
            self.items?.remove(at: found.offset)
            self.items?.append(person)
            
            updateDictionary { [unowned self] in
                if let newIndexPath = self.indexPath(for: person) {
                    handler( oldIndexPath, newIndexPath )
                }
            }
        }
    }
    
    // append person to items
    // after completion fire <handler> block for possible tableView update
    public func append(_ person: Person, handler: @escaping ( (IndexPath?) -> Void) ) {
        guard let _ = items else { return }
        
        self.items?.append(person)
        updateDictionary { [unowned self] in
            if let newIndexPath = self.indexPath(for: person) {
                handler( newIndexPath )
            }
        }
    }
    
    // get person with indexPath from sorted dictionary (or nil if key does not exists)
    public func person(witn indexPath: IndexPath) -> Person? {
        let isKeyIndexValid = sortedIndexes.indices.contains(indexPath.section)
        if ( isKeyIndexValid ) {
            let itemsArray = itemsAsDictionary[ sortedIndexes[indexPath.section] ]
            let isItemIndexValid = itemsArray?.indices.contains(indexPath.row) ?? false
            if ( isItemIndexValid ) {
                return itemsArray?[ indexPath.row ]
            }
        }
        return nil
    }
    
    // get indexPath from sorted dictionary fo person or nil if no person found
    public func indexPath(for person: Person?) -> IndexPath? {
        guard let person = person else { return nil }
        guard let keyedItems = itemsAsDictionary[ person.firstIndex ] else {
            return nil
        }
        
        let keys = itemsAsDictionary.keys.sorted(by: { (a, b) -> Bool in
            return a.uppercased() < b.uppercased()
        })
        if let section = keys.firstIndex(of: person.firstIndex), let row = keyedItems.firstIndex(where: {$0 === person}) {
            return IndexPath(item: row, section: section)
        }
        
        return nil
    }
    
// MARK: -Private Methods
    // update dictionary from the items array and fire completion block if not nil
    fileprivate func updateDictionary( completion : (() -> Swift.Void)? = nil) {
        guard let items = items else { return }
        
        itemsAsDictionary.removeAll()
        let sorted = items.sorted { (a, b) -> Bool in
            return a.fullName.uppercased() < b.fullName.uppercased()
        }
        
        var prevLetter = ""
        sorted.forEach { ( person ) in
            if ( person.firstIndex != prevLetter ) {
                prevLetter = person.firstIndex
            }
            if ( prevLetter != "" && itemsAsDictionary[ prevLetter ] == nil ) {
                itemsAsDictionary[ prevLetter ] = []
            }
            itemsAsDictionary[ prevLetter ]?.append(person)
        }
        sortedIndexes = itemsAsDictionary.keys.sorted(by: { (a, b) -> Bool in
            return a.uppercased() < b.uppercased()
        })
        completion?()
    }
}
