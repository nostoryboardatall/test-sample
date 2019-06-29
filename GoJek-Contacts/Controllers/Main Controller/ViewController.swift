//
//  ViewController.swift
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
// Main ViewController class
//*******************************************
class ViewController: UIViewController {

// MARK: -Public properties
    // contacts array
    public var items: Contacts?
    
    // table view and cell identificator
    public var tableView: UITableView!
    public let contactCellID = "contactCellID"
    
// MARK: -Private properties
    // custom view for display loading progress
    fileprivate var loadingView = LoadingViewIndicator()

// MARK: -Overrided methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the appearance
        setupView()
    }
    
    override func loadView() {
        super.loadView()
        
        // register and setup table view
        registerTableView()
        
        // placing subviews and activating auto layout constraints
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // setup the navigation bar
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.basicTextColor!]
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Groups", style: .plain, target: self,
                                                           action: #selector(toggleTableViewStyle))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                            action: #selector(addContact))
        navigationItem.title = "Contact"
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .background
        loadingView.title = "Loading contacts..."
        loadingView.anchorView = view
        
        // fetch contact from the backend
        fetch()
    }
    
    fileprivate func prepareView() {
        // add subviews
        view.addSubview(tableView)
        view.addSubview(loadingView)
        
        // activate constraints
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    fileprivate func registerTableView() {
        // setting up the appearance of tableView
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = true
        tableView.backgroundColor = .background
        tableView.sectionIndexColor = .gray
        
        // register classes for tableView cell
        tableView.register(ContactCell.self, forCellReuseIdentifier: contactCellID)
        
        // setting up the delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // ui tests id
        tableView.accessibilityIdentifier = "MainTable"
    }
    
    fileprivate func fetch() {
        // 1. show loading view
        tableView.isHidden = true
        loadingView.isHidden = false
        loadingView.startLoading()

        // 2. fire fetch
        ContactAPIManager.shared.fetch { [unowned self] ( result ) in
            switch result {
            case .success( let contacts ):
                // success - assign contacts array and hide loading view
                self.items = contacts
                DispatchQueue.main.async {
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            case .failure( let error ):
                // error - handle it
                self.handleError(error, otherButtonTitle: "Retry", handler: { (_) in
                    self.fetch()
                })
            }
        }
    }
}

