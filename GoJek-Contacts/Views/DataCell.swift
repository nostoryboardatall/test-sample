//
//  DataCell.swift
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
// View class for displaying contact details (firstName, lastName, phone, email)
// in detaill/edit/new controllers
//*******************************************
class DataCell: UITableViewCell {
// MARK: -Class types
    // keyboard style
    public enum EditStyle: Int {
        case none, name, phone, email
    }
    
    // validation types for data
    public enum ValidationType: Int {
        case none, noEmpty, phoneNumber, email
    }
    
// MARK: -Public properties
    // title on the left
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    // value entered in textField
    public var value: String? {
        didSet {
            if ( value != oldValue ) {
                valueTextField.text = value
            }
        }
    }

    // keyboard style (by default keyvoard is .default)
    public var editStyle: EditStyle = .none {
        didSet {
            switch editStyle {
            case .name:
                valueTextField.keyboardType = .alphabet
                valueTextField.autocapitalizationType = .words
            case .phone:
                valueTextField.keyboardType = .phonePad
            case .email:
                valueTextField.keyboardType = .emailAddress
            default:
                valueTextField.keyboardType = .default
            }
        }
    }
    
    // validation type - no validation by default
    public var validationType: ValidationType = .none
    
    // path to property
    public var keyPath: ReferenceWritableKeyPath<Person, String?>?

    // if text field is editable
    public var isEditable: Bool = false {
        didSet {
            valueTextField.isEnabled = isEditable
        }
    }
    
    // delegate to recieve UITextField messages
    public weak var delegate: UITextFieldDelegate? {
        didSet {
            valueTextField.delegate = delegate
        }
    }

// MARK: -UI private properties
    // title on the left
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .right
        
        return label
    }()
    
    // text field
    lazy var valueTextField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.textColor = .basicTextColor
        textField.layer.borderWidth = 0.0
        textField.font = UIFont.systemFont(ofSize: 16.0)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.isEnabled = false
        
        return textField
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
    
// MARK: -Public Methods
    // validate value depending on validationType
    public func validate() -> Bool {
        switch validationType {
        case .noEmpty:
            return Person.validateName( valueTextField.text )
        case .email:
            return Person.validateEmail( valueTextField.text )
        case .phoneNumber:
            return Person.validatePhone( valueTextField.text )
        default:
            return true
        }
    }
    
    // add "shacking" error view to cell in case of validate error
    public func addError(andShake: Bool = true) {
        var errorDescription = ""
        switch validationType {
        case .noEmpty:
            errorDescription = "too short"
        case .email:
            errorDescription = "not an email"
        case .phoneNumber:
            errorDescription = "invalid phone"
        default:
            errorDescription = "error"
        }
        let error = UIErrorView(with: .error, and: .top)
        error.present(on: titleLabel, with: errorDescription)
        if ( andShake ) {
            error.shake()
        }
    }
    
    // remove error view from cell
    public func removeError() {
        UIErrorView.dismissAll(from: titleLabel)
    }
    
// MARK: -Private Methods
    // setup the UI
    fileprivate func setupView() {
        backgroundColor = .background
        
        addSubview(titleLabel)
        addSubview(valueTextField)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56.0),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueTextField.heightAnchor.constraint(equalToConstant: 56.0),
            valueTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 32.0),
            valueTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

