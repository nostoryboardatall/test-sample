//
//  GradientView.swift
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

class GradientView: UIView {
    public var startColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    public var endColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var gradient: CAGradientLayer?
    
    init(from start: UIColor?, to end: UIColor?) {
        super.init(frame: CGRect.zero)
        startColor = start
        endColor = end
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let gradient = gradient, let start = startColor, let end = endColor {
            gradient.frame = bounds
            gradient.colors = [start.cgColor, end.cgColor]
            gradient.locations = [0.0, 1.0]
        }
    }
    
    private func setupView() {
        gradient = CAGradientLayer()
        if let gradient = gradient {
            layer.insertSublayer(gradient, at: 0)
        }
    }
}
