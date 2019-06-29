//
//  ContactCell.swift
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
// View class for displaying contact in main table view
//*******************************************
class ContactCell: UITableViewCell {
// MARK: -Public properties
    // person - by setting this value we update the cell view
    public var person: Person? {
        didSet {
            guard let person = person else { return }
            
            // set the text fields and favourite icon
            titleLabel.text = person.fullName
            favouriteIcon.isHidden = !(person.isFavourite ?? false)
            
            // download image (or catching it from cache)
            ContactAPIManager.shared.downloadImage(for: person) { ( result ) in
                switch result {
                case .success( let data ):
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(data: data)
                    }
                case .failure( let error ):
                    print("error: \(error.localizedDescription) for downloading image at: \(person.profilePic ?? "")")
                }
            }
        }
    }
    
// MARK: -UI private properties
    // title
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .basicTextColor
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .left
        
        return label
    }()
    
    // profile picture
    private let userImageView: RCImageView = {
        let imageView = RCImageView()
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.isRoundedCorners = true
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return imageView
    }()

    // favourite icon
    private let favouriteIcon: RCImageView = {
        let imageView = RCImageView()
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.isRoundedCorners = false
        imageView.image = UIImage(named: "home_favourite")
        imageView.isHidden = true
        
        return imageView
    }()

// MARK: -Initialization
    // override super init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    // required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: -Private Methods
    // setup the UI
    fileprivate func setupView() {
        addSubview(userImageView)
        addSubview(favouriteIcon)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12.0),
            userImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.0),

            favouriteIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.0),
            favouriteIcon.topAnchor.constraint(equalTo: topAnchor, constant: 24.0),
            favouriteIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24.0),
            
            titleLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 16.0),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(equalToConstant: 64.0)
        ])
    }
}
