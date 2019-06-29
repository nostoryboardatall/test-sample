//
//  LoadingViewIndicator.swift
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

public class LoadingViewIndicator: UIView {
    public var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.sizeToFit()
        }
    }
    
    public weak var anchorView: UIView? {
        didSet {
            guard let anchorView = anchorView else { return }
            connect(to: anchorView)
        }
    }
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8.0
        
        return stack
    }()
    
    private let activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.style = .gray
        
        return activityView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textAlignment = .left
        
        return label
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startLoading(setUserInteractionDisabled: Bool = false) {
        superview?.isUserInteractionEnabled = false
        isHidden = false
        activityView.startAnimating()
    }
    
    public func stopLoading() {
        superview?.isUserInteractionEnabled = true
        isHidden = true
        activityView.stopAnimating()
    }
    
    fileprivate func setupView() {
        backgroundColor = .clear
        
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        
        layer.cornerRadius = 13.0
        layer.masksToBounds = true
        
        stackView.addArrangedSubview(activityView)
        stackView.addArrangedSubview(titleLabel)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.0),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0)
        ])
    }
    
    fileprivate func connect(to view: UIView) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}
