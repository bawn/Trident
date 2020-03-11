//
//  MenuItemView.swift
//  Trident
//
//  Created by bawn on 2020/02/11.
//  Copyright © 2020 bawn. All rights reserved.( http://bawn.github.io )
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

internal class MenuItemView: UILabel {
    private var normalColors = UIColor.white.rgb
    private var selectedColors = UIColor.white.rgb
    
    internal var rate: CGFloat = 0.0 {
        didSet {
            guard rate > 0.0, rate < 1.0 else {
                return
            }
            let r = normalColors.red + (selectedColors.red - normalColors.red) * rate
            let g = normalColors.green + (selectedColors.green - normalColors.green) * rate
            let b = normalColors.blue + (selectedColors.blue - normalColors.blue) * rate
            let a = normalColors.alpha + (selectedColors.alpha - normalColors.alpha) * rate
            
            textColor = UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }
    
    internal init(_ textFont: UIFont, _ normalTextColor: UIColor, _ selectedTextColor: UIColor) {
        super.init(frame: .zero)
        self.font = textFont
        normalColors = normalTextColor.rgb
        selectedColors = selectedTextColor.rgb
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

