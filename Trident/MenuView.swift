//
//  MenuView.swift
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
import SnapKit

public enum MenuStyle {
    case normalTextFont(UIFont)
    case selectedTextFont(UIFont)
    case itemSpace(CGFloat)
    case normalTextColor(UIColor)
    case selectedTextColor(UIColor)
    case contentInset(UIEdgeInsets)
    case sliderStyle(SliderViewStyle)
    case bottomLineStyle(BottomLineViewStyle)
    case switchStyle(MenuSwitchStyle)
}

public enum MenuSwitchStyle {
    case line
    case telescopic // 伸缩
}

public protocol TridentMenuViewDelegate: class {
    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int)
}

public class TridentMenuView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = itemSpace
        return stackView
    }()
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.clipsToBounds = false
        return scrollView
    }()
    private lazy var sliderView: UIView = {
        let view = UIView()
        view.backgroundColor = selectedTextColor
        view.snp.makeConstraints({$0.height.equalTo(2.0);$0.width.equalTo(0)})
        return view
    }()
    private let bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.snp.makeConstraints({$0.height.equalTo(0.5)})
        return view
    }()
    private var menuItemViews = [MenuItemView]()
    public weak var delegate: TridentMenuViewDelegate?
    
    private var normalTextFont = UIFont.systemFont(ofSize: 15.0)
    private var selectedTextFont = UIFont.systemFont(ofSize: 15, weight: .medium)
    public var itemSpace:CGFloat = 30.0 {
        didSet {
            stackView.spacing = itemSpace
            layoutIfNeeded()
            layoutSlider()
        }
    }
    private var normalTextColor = UIColor.darkGray
    private var selectedTextColor = UIColor.red
    public var contentInset = UIEdgeInsets.zero {
        didSet {
            guard let _ = scrollView.superview else {
                return
            }
            
            scrollView.snp.updateConstraints { (make) in
                make.leading.equalToSuperview().offset(contentInset.left)
                make.trailing.equalToSuperview().offset(-contentInset.right)
                make.top.equalToSuperview().offset(contentInset.top)
                make.bottom.equalToSuperview().offset(-contentInset.bottom)
            }
        }
    }
    public private(set) lazy var sliderViewStyle = SliderViewStyle(view: sliderView)
    public private(set) lazy var bottomLineViewStyle = BottomLineViewStyle(view: bottomLineView)
    private var switchStyle = MenuSwitchStyle.line
    
    public init(parts: MenuStyle...) {
        super.init(frame: .zero)
        for part in parts {
            switch part {
            case .normalTextFont(let font):
                normalTextFont = font
            case .selectedTextFont(let font):
                selectedTextFont = font
            case .itemSpace(let space):
                itemSpace = space
            case .normalTextColor(let color):
                normalTextColor = color
            case .selectedTextColor(let color):
                selectedTextColor = color
            case .contentInset(let inset):
                contentInset = inset
            case .sliderStyle(let style):
                sliderViewStyle = style
                sliderViewStyle.targetView = sliderView
            case .switchStyle(let style):
                switchStyle = style
            case .bottomLineStyle(let style):
                bottomLineViewStyle = style
                bottomLineViewStyle.targetView = bottomLineView
            }
        }
        initialize()
    }
    
    
    private var scrollRate: CGFloat = 0.0 {
        didSet {
            currentLabel?.rate = 1.0 - scrollRate
            nextLabel?.rate = scrollRate
        }
    }
    
    public var titles = [String]() {
        didSet {
            stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
            menuItemViews.removeAll()
            guard titles.isEmpty == false else {
                return
            }
            titles.forEach { (item) in
                let label = MenuItemView(item,
                                         normalTextFont,
                                         selectedTextFont,
                                         normalTextColor,
                                         selectedTextColor)
                label.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(titleTapAction(_:)))
                label.addGestureRecognizer(tap)
                stackView.addArrangedSubview(label)
                label.snp.makeConstraints({ (make) in
                    make.height.equalToSuperview()
                })
                menuItemViews.append(label)
            }

            currentIndex = 0
            
            stackView.layoutIfNeeded()
            let labelWidth = stackView.arrangedSubviews.first?.bounds.width ?? 0.0
            var progressWidth: CGFloat = 0
            switch switchStyle {
            case .telescopic:
                progressWidth = sliderViewStyle.originWidth
            default:
                switch sliderViewStyle.shape {
                case .line:
                    progressWidth = labelWidth + sliderViewStyle.extraWidth
                case .round:
                    progressWidth = sliderViewStyle.height
                case .triangle:
                    progressWidth = sliderViewStyle.height + sliderViewStyle.extraWidth
                }
            }
            
            let offset = stackView.arrangedSubviews.first?.frame.midX ?? 0.0
            sliderView.snp.updateConstraints { (make) in
                make.width.equalTo(progressWidth)
                make.centerX.equalTo(scrollView.snp.leading).offset(offset)
            }
            checkState(animation: false)
        }
    }
    
    private var itemMidSpace: CGFloat {
        guard let currentLabel = currentLabel
            , let nextLabel = nextLabel else {
                return 0.0
        }
        
        let value = nextLabel.frame.minX - currentLabel.frame.midX + nextLabel.bounds.width * 0.5
        return value
    }
    
    private var widthDifference: CGFloat {
        guard let currentLabel = currentLabel
            , let nextLabel = nextLabel else {
                return 0.0
        }
        
        let value = nextLabel.bounds.width - currentLabel.bounds.width
        return value
    }
    
    private var centerXDifference: CGFloat {
        guard let currentLabel = currentLabel
            , let nextLabel = nextLabel else {
                return 0.0
        }
        let value = nextLabel.frame.midX - currentLabel.frame.midX
        return value
    }
    
    private var nextIndex = 0 {
        didSet {
            guard nextIndex < titles.count
                , nextIndex >= 0 else {
                return
            }
            nextLabel = menuItemViews[nextIndex]
        }
    }
    
    private var currentIndex = 0 {
        didSet {
            guard currentIndex < titles.count
                , currentIndex >= 0 else {
                return
            }
            nextIndex = currentIndex == titles.count - 1 ? currentIndex - 1 : currentIndex + 1
//            nextIndex = min(currentIndex + 1, titles.count - 1)
            currentLabel = menuItemViews[currentIndex]
        }
    }
    private var currentLabel: MenuItemView?
    private var nextLabel: MenuItemView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialize() {
        backgroundColor = .white
        clipsToBounds = true
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(contentInset.left)
            make.trailing.equalToSuperview().offset(-contentInset.right)
            make.top.equalToSuperview().offset(contentInset.top)
            make.bottom.equalToSuperview().offset(-contentInset.bottom)
        }
        
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        scrollView.addSubview(sliderView)
        scrollView.sendSubviewToBack(sliderView)
        sliderView.snp.makeConstraints { (make) in
            make.centerX.equalTo(scrollView.snp.leading).offset(0)
            switch sliderViewStyle.position {
            case .bottom:
                make.bottom.equalToSuperview()
            case .center:
                make.centerY.equalToSuperview()
            case .top:
                make.top.equalToSuperview()
            }
        }
        
        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    private func clear() {
        stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        menuItemViews.removeAll()
    }
    
    @objc private func titleTapAction(_ sender: UIGestureRecognizer) {
        guard let targetView = sender.view
            , let index = stackView.arrangedSubviews.firstIndex(of: targetView) else {
            return
        }
        delegate?.menuView(self, didSelectedItemAt: index)
    }
    
    
    public func updateLayout(_ externalScrollView: UIScrollView) {
        guard currentIndex >= 0, currentIndex < titles.count else {
            return
        }
        let scrollViewWidth = externalScrollView.bounds.width
        let offsetX = externalScrollView.contentOffset.x
        let index = Int(offsetX / scrollViewWidth)
        guard index >= 0, index < titles.count else {
            return
        }
        
        currentIndex = index
        let value:CGFloat = offsetX > CGFloat(titles.count - 1) * externalScrollView.bounds.width ? -1 : 1
        scrollRate = value * (offsetX - CGFloat(currentIndex) * scrollViewWidth) / scrollViewWidth
        layoutSlider(scrollRate)
    }
    
    public func checkState(animation: Bool) {
        guard currentIndex >= 0
            , currentIndex < titles.count else {
            return
        }
        menuItemViews.forEach({$0.showNormalStyle()})
        menuItemViews[currentIndex].showSelectedStyle()
        
        currentLabel = menuItemViews[currentIndex]
        nextLabel = menuItemViews[nextIndex]
        guard let currentLabel = currentLabel else {
            return
        }
        scrollView.scrollToSuitablePosition(currentLabel, animation)
    }
    
    func layoutSlider(_ scrollRate: CGFloat = 0.0) {

        let currentWidth = stackView.arrangedSubviews[currentIndex].bounds.width
        let leadingMargin = stackView.arrangedSubviews[currentIndex].frame.midX

        switch switchStyle {
        case .line:
            sliderView.snp.updateConstraints { (make) in
                switch sliderViewStyle.shape {
                case .line:
                    make.width.equalTo(widthDifference * scrollRate + currentWidth + sliderViewStyle.extraWidth)
                case .triangle:
                    make.width.equalTo(sliderViewStyle.height + sliderViewStyle.extraWidth)
                case .round:
                    make.width.equalTo(sliderViewStyle.height)
                }
                make.centerX.equalTo(scrollView.snp.leading).offset(leadingMargin + itemMidSpace * scrollRate)
            }
        case .telescopic:
            sliderView.snp.updateConstraints { (make) in
                let rate = (scrollRate <= 0.5 ? scrollRate : (1.0 - scrollRate)) * sliderViewStyle.elasticValue
                make.width.equalTo(max(centerXDifference * rate + sliderViewStyle.originWidth, 0))
                make.centerX.equalTo(scrollView.snp.leading).offset(leadingMargin + itemMidSpace * scrollRate)
            }
        }
    }
}

