//
//  EditContactController.swift
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
// EditPersonDelegate - delegate to handle updating or appending contact
//*******************************************
protocol EditPersonDelegate: AnyObject {
    func didUpdateContact(_ before: Person?, with after: Person?)
    func didAppendContact(_ person: Person?)
}


//*******************************************
// EditPersonController class - edit contact details/append contact
//*******************************************
class EditPersonController: UIViewController {
// MARK: -Class types
    // action - new or edit
    public enum Action: Int {
        case update, new
    }
    
// MARK: -Public properties
    // edited person
    public var person: Person? {
        didSet {
            guard let _ = tableView else { return }
            
            // update UI
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // action - new or edit
    public var action: Action = .update
    
    // table view and cell identificator
    public var tableView: UITableView!
    public let dataCellID = "dataCellID"

    // edit/append contact delegate
    public weak var delegate: EditPersonDelegate!
    
    // image picker for selecting the profile picture
    public weak var imagePicker: UIImagePickerController!
    
    // common vars for keyboard appearance
    public var bottomAnchor: CGFloat = 0.0
    public var isKeyboardPresent: Bool = false
    public var keyboardTop: CGFloat = 0.0
    
    // custom view for display loading progress
    public var loadingView = LoadingViewIndicator()
    
    // check if profile picture has been edited
    public var isUserImageEdited: Bool = false {
        didSet {
            outsideFrame.isHidden = !isUserImageEdited
        }
    }
    
    // profile picture - public cause using in UIImagePickerControllerDelegate
    public lazy var userImageView: RCImageView = {
        let imageView = RCImageView()
        
        imageView.isRoundedCorners = true
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        imageView.image = UIImage(named: "placeholder_photo")
        
        return imageView
    }()
    
// MARK: -Private UI properties
    // gradient view on the top
    private lazy var gradientView: GradientView = {
        let view = GradientView(from: .gradientStart, to: .gradientEnd)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.55
        
        return view
    }()
    
    // outside frame for profile picture - not sure is ot nessesary but it was in design template
    private lazy var outsideFrame: RCView = {
        let view = RCView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isRoundedCorners = true
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3.0
        view.backgroundColor = .clear
        view.accessibilityIdentifier = "outsideBorder"

        
        return view
    }()
    
    // button to select profile picture
    private lazy var photoButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "camera_button"), for: .normal)
        button.addTarget(self, action: #selector(choosePicture), for: .touchUpInside)
        
        return button
    }()
    
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self,
                                                           action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self,
                                                            action: #selector(done))
        navigationItem.title = ""
        
        // subscribe for keyboard notification events
        subscribeForKeyboardNotification()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        // unsubscribe for keyboard notification events
        unsubscribeFromKeyboardNotification()
        super.viewWillDisappear(animated)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // hide keyboard
        onTableViewTouchUpInside()
        super.touchesBegan(touches, with: event)
    }

    fileprivate func setupView() {
        view.backgroundColor = .background
        loadingView.backgroundColor = .white

        // fetch contact details from the backend or from the cache
        fetch()
    }
    
    fileprivate func prepareView() {
        // add subviews, fill stack views, activate constraints...
        
        view.addSubview(gradientView)
        view.addSubview(userImageView)
        view.addSubview(outsideFrame)
        view.addSubview(photoButton)
        view.addSubview(tableView)
        view.addSubview(loadingView)
        
        loadingView.anchorView = gradientView
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 45.0),

            userImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 127.0),
            userImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -127.0),
            userImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 85.0),
            
            outsideFrame.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
            outsideFrame.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            outsideFrame.widthAnchor.constraint(equalTo: userImageView.widthAnchor, constant: 6.0),
            outsideFrame.heightAnchor.constraint(equalTo: userImageView.heightAnchor, constant: 6.0),
            
            photoButton.rightAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 4.0),
            photoButton.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 4.0),
            photoButton.widthAnchor.constraint(equalTo: userImageView.widthAnchor, multiplier: 0.4),
            photoButton.heightAnchor.constraint(equalTo: photoButton.widthAnchor),
            
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
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTableViewTouchUpInside))
        tableView.addGestureRecognizer(gesture)
        tableView.isUserInteractionEnabled = true
    }
    
    fileprivate func fetch() {
        if ( action == .new ) {
            // 1. create an empty contact
            person = Person()
            outsideFrame.isHidden = true
        } else if let person = person {
            // 2. try to get profile picture from cache or download it
            ContactAPIManager.shared.downloadImage(for: person) { ( result ) in
                switch result {
                case .success( let data ):
                    // success - update the ui
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(data: data)
                    }
                case .failure( let error ):
                    // error - handle it
                    self.handleError(error)
                }
            }
        }
    }
}
