//
//  MessageView.swift
//
//  Created by Home on 2018.
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

class UIErrorView: UIView {
    enum MessageType: Int {
        case error, warning, message, custom
        
        var color: UIColor? {
            switch self {
            case .error:
                return .red
            case .warning:
                return .orange
            case .message:
                return .blue
            default:
                return nil
            }
        }
    }
    
    enum MessagePosition: Int {
        case top, bottom
    }
    
    private(set) var type: MessageType = .message
    
    private(set) var position: MessagePosition = .bottom
    
    private var isAppear: Bool = false
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    convenience init(with type: MessageType, and position: MessagePosition = .bottom) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.type = type
        self.position = position
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        layer.cornerRadius = frame.size.height * 0.5
    }

    public func shake(for duration: TimeInterval = 0.5, withTranslation translation: CGFloat = 10) {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.3) {
            self.transform = CGAffineTransform(translationX: translation, y: 0)
        }
        
        propertyAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.2)
        
        propertyAnimator.startAnimation()
    }
    
    func present(on view: UIView, with title: String) {
        if !isAppear {
            titleLabel.text = title
            titleLabel.sizeToFit()
            
            if let color = type.color {
                backgroundColor = color
            }
            
            addSubview(titleLabel)
            view.addSubview(self)
            
            var verticalConstraint = NSLayoutConstraint()
            if position == .top {
                verticalConstraint = NSLayoutConstraint(item: self,
                                                        attribute: .bottom,
                                                        relatedBy: .equal,
                                                        toItem: view,
                                                        attribute: .top,
                                                        multiplier: 1.0,
                                                        constant: 1.0)
            } else {
                verticalConstraint = NSLayoutConstraint(item: self,
                                                        attribute: .top,
                                                        relatedBy: .equal,
                                                        toItem: view,
                                                        attribute: .bottom,
                                                        multiplier: 1.0,
                                                        constant: -1.0)
            }
            
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalTo: titleLabel.widthAnchor, constant: 16.0),
                heightAnchor.constraint(equalTo: titleLabel.heightAnchor, constant: 1.0),
                
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                
                centerXAnchor.constraint(equalTo: view.centerXAnchor),
                verticalConstraint
            ])
            
            isAppear = true
        } else {
            titleLabel.text = title
            titleLabel.sizeToFit()
            shake()
        }
    }
    
    func dismiss() {
        if isAppear {
            titleLabel.removeFromSuperview()
            self.removeFromSuperview()
            isAppear = false
        }
    }
    
    class func dismissAll(from superview: UIView) {
        superview.subviews.forEach { (subview) in
            if let subview = subview as? UIErrorView {
                subview.dismiss()
            }
        }
    }
}
