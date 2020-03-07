//
//  BottomLineViewStyle.swift
//  Trident
//
//  Created by bawn on 2020/3/4.
//

import Foundation
import UIKit

public enum BottomLineStyle {
    case backgroundColor(UIColor)
    case height(CGFloat)
    case hidden(Bool)
}


public class BottomLineViewStyle {
    
    public var backgroundColor = UIColor.black.withAlphaComponent(0.15) {
        didSet {
            targetView?.backgroundColor = backgroundColor
        }
    }
    
    public var height: CGFloat = 0.5 {
        didSet {
            targetView?.snp.updateConstraints({$0.height.equalTo(height)})
        }
    }
    
    public var hidden = false {
        didSet {
            targetView?.isHidden = hidden
        }
    }
    
    weak var targetView: UIView? {
        didSet {
            targetView?.backgroundColor = backgroundColor
            targetView?.snp.updateConstraints({$0.height.equalTo(height)})
            targetView?.isHidden = hidden
        }
    }
    
    public init(view: UIView) {
        targetView = view
    }
    
    public init(parts: BottomLineStyle...) {
        for part in parts {
            switch part {
            case .backgroundColor(let color):
                backgroundColor = color
            case .height(let value):
                height = value
            case .hidden(let value):
                hidden = value
            }
        }
    }

}
