//
//  DetailController.swift
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
import MessageUI

//*******************************************
// Detail ViewController class - show the contact details
//*******************************************
class DetailController: UIViewController {
// MARK: -Public properties
    // viewed person
    public var person: Person?
    
    // table view and cell identificator
    public var tableView: UITableView!
    public let dataCellID = "dataCellID"
    
// MARK: -Private UI properties
    // custom view for display loading progress
    fileprivate var loadingView = LoadingViewIndicator()
    
    // gradient view on the top
    fileprivate lazy var gradientView: GradientView = {
        let view = GradientView(from: .gradientStart, to: .gradientEnd)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.55
        
        return view
    }()
    
    // container view
    fileprivate lazy var uiView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()

    // stack view on the top
    fileprivate lazy var upperStack: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8.0
        
        return stack
    }()
    
    // stack view for buttons
    fileprivate lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = 24.0 // change space to looks better on iPhone5 screen also
        
        return stack
    }()

    // full name label
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .basicTextColor
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textAlignment = .center
        label.text = ""
        
        return label
    }()
    
    // profile picture
    fileprivate lazy var userImageView: RCImageView = {
        let imageView = RCImageView()
        
        imageView.isRoundedCorners = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        imageView.image = UIImage(named: "placeholder_photo")
        
        return imageView
    }()
    
    // outside frame for profile picture - not sure is ot nessesary but it was in design template
    fileprivate lazy var outsideFrame: RCView = {
        let view = RCView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isRoundedCorners = true
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3.0
        view.backgroundColor = .clear
        
        return view
    }()
    
    // *****************************************************************
    // action buttons
    // *****************************************************************
    fileprivate lazy var messageButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "message_button"), for: .normal)
        button.addTarget(self, action: #selector(message), for: .touchUpInside)
        
        return button
    }()

    fileprivate lazy var phoneButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "call_button"), for: .normal)
        button.addTarget(self, action: #selector(call), for: .touchUpInside)
        
        return button
    }()

    fileprivate lazy var emailButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "email_button"), for: .normal)
        button.addTarget(self, action: #selector(email), for: .touchUpInside)
        
        return button
    }()

    fileprivate lazy var isFavouriteButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "favourite_button"), for: .normal)
        
        return button
    }()
    // *****************************************************************
    // action buttons
    // *****************************************************************

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
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = .clear
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self,
                                                            action: #selector(edit))
        navigationItem.title = ""
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .background
        
        loadingView.title = "Fetching details..."
        loadingView.anchorView = view
        
        // fetch contact details from the backend or from the cache
        fetch()
    }
    
    fileprivate func prepareView() {
        // add subviews, fill stack views, activate constraints...
        
        var buttons: [StackButton] = []
        
        buttons.append( StackButton(button: messageButton, title: "message") )
        buttons.append( StackButton(button: phoneButton, title: "call") )
        buttons.append( StackButton(button: emailButton, title: "email") )
        buttons.append( StackButton(button: isFavouriteButton, title: "favourite") )
        
        buttons.forEach { (item) in
            let stack = UIStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .vertical
            stack.alignment = .center
            stack.distribution = .fill
            stack.spacing = 6.0
            
            if let button = item.button, let title = item.title {
                let titleLabel = UILabel()
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.backgroundColor = .clear
                titleLabel.textColor = .basicTextColor
                titleLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
                titleLabel.textAlignment = .center
                titleLabel.text = title
                titleLabel.sizeToFit()

                stack.addArrangedSubview(button)
                stack.addArrangedSubview(titleLabel)
                
                buttonsStack.addArrangedSubview(stack)
            }
        }

        upperStack.addArrangedSubview(userImageView)
        upperStack.addArrangedSubview(nameLabel)

        
        uiView.addSubview(gradientView)
        uiView.addSubview(upperStack)
        uiView.addSubview(buttonsStack)
        uiView.addSubview(tableView)
        uiView.addSubview(outsideFrame)
        
        view.addSubview(loadingView)
        view.addSubview(uiView)
        
        NSLayoutConstraint.activate([
            uiView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uiView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            uiView.widthAnchor.constraint(equalTo: view.widthAnchor),
            uiView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 335.0),
            
            upperStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 84.0),
            upperStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            userImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 127.0),
            userImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -127.0),
            
            buttonsStack.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -12.0),
            buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            outsideFrame.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
            outsideFrame.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            outsideFrame.widthAnchor.constraint(equalTo: userImageView.widthAnchor, constant: 6.0),
            outsideFrame.heightAnchor.constraint(equalTo: userImageView.heightAnchor, constant: 6.0),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: gradientView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    fileprivate func registerTableView() {
        // setting up the appearance of tableView
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.backgroundColor = .background
        
        // register classes for tableView cell
        tableView.register(DataCell.self, forCellReuseIdentifier: dataCellID)
        
        // setting up the delegates
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    fileprivate func fetch() {
        // 1. show loading view - hide container view
        uiView.isHidden = true
        loadingView.isHidden = true
        loadingView.startLoading()

        // 2. check if person is not nil
        guard let person = person else {
            handleError(GJFetchError.contactIsNotSet) { [unowned self] (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        
        // 3. try to get details from cache
        if let detailedPerson = ContactAPIManager.shared.getDetailedPersonFromCache(person) {
            self.person = detailedPerson
            updateFormData()
        // 4. no cache - fetch details
        } else {
            loadingView.isHidden = false
            ContactAPIManager.shared.fetchDetail(for: person) { [unowned self] ( result ) in
                switch result {
                // success - assign details and update UI
                case .success( let detailedPerson ):
                    self.person = detailedPerson
                    self.updateFormData()
                // error - handle it
                case .failure( let error ):
                    self.handleError(error, handler: { [unowned self] (_) in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            }
        }
        
        // 5. try to get profile picture from cache
        if let imageData = ContactAPIManager.shared.getImageDataFromCache(person.profilePic ?? "") {
            DispatchQueue.main.async {
                self.userImageView.image = UIImage(data: imageData)
            }
        // 6. no cache - download it
        } else {
            ContactAPIManager.shared.downloadImage(for: person) { [unowned self] ( result ) in
                switch result {
                // succsess - update UI
                case .success( let data ):
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(data: data)
                    }
                // error - handle it
                case .failure( let error ):
                    self.handleError(error)
                }
            }
        }
    }
    
    fileprivate func updateFormData() {
        // update form data after fetching contact details
        DispatchQueue.main.async {
            let favouriteImageNamed = self.person?.isFavourite ?? false ? "favourite_button_selected" : "favourite_button"
            
            self.nameLabel.text = self.person?.fullName
            self.isFavouriteButton.setImage(UIImage(named: favouriteImageNamed), for: .normal)
            self.tableView.reloadData()
            self.loadingView.isHidden = true
            self.loadingView.stopLoading()
            self.uiView.isHidden = false
        }
    }
}
