//
//  ViewController.swift
//  Trident
//
//  Created by bawn on 02/18/2020.
//  Copyright (c) 2020 bawn. All rights reserved.
//

import UIKit
import SnapKit
import Trident

class DetailViewController: UIViewController {
    var indexPath = IndexPath(row: 0, section: 0)
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    lazy var menuView: TridentMenuView = {
        
        var switchStyle = MenuSwitchStyle.line
        var shape = SliderShape.line
        var position = SliderPosition.bottom
        var height: CGFloat = 3.0
        var cornerRadius: CGFloat = 1.5
        var backgroundColor = UIColor.blue
        var extraWidth: CGFloat = 4.0
        
        switch indexPath.row {
        case 0:
            switchStyle = .telescopic
        case 1:
            position = .center
            height = 36.0
            cornerRadius = 18.0
            backgroundColor = UIColor.lightGray
            extraWidth = 20.0
        case 2:
            shape = .triangle
        case 3:
            position = .top
            shape = .round
        default:
            shape = .line
            position = .bottom
            extraWidth = 0.0
            height = 3.0
        }
        
        
        let view = TridentMenuView(parts:
            .itemSpace(15.0),
            .normalTextColor(UIColor.gray),
            .selectedTextColor(UIColor.blue),
            .textFont(UIFont.systemFont(ofSize: 15.0)),
            .switchStyle(switchStyle),
            .sliderStyle(
                SliderViewStyle(parts:
                    .backgroundColor(backgroundColor),
                    .height(height),
                    .cornerRadius(cornerRadius),
                    .position(position),
                    .extraWidth(extraWidth),
                    .originWidth(30.0),
                    .shape(shape),
                    .elasticValue(1.2)
                )
            ),
            .bottomLineStyle(
                BottomLineViewStyle(parts:
                    .backgroundColor(UIColor.black.withAlphaComponent(0.15)),
                    .height(0.5)
                )
            )
        )
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addSubview(menuView)
        menuView.titles = ["Trident", "Gungnir", "MjolnirMjolnir", "Brionac", "Harpe", "Tyrfing"]
        menuView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        menuView.contentInset = UIEdgeInsets(top: 0, left: 24.0, bottom: 0, right: 24.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuView.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = UIColor(red: CGFloat((0...255).randomElement() ?? 0)/255.0,
                                       green: CGFloat((0...255).randomElement() ?? 0)/255.0,
                                       blue: CGFloat((0...255).randomElement() ?? 0)/255.0,
                                       alpha: 1.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.inset(by: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)).size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        menuView.sliderViewStyle.backgroundColor = .brown
//        menuView.sliderViewStyle.height = 6
//        menuView.sliderViewStyle.cornerRadius = 3
        menuView.itemSpace = 30
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuView.updateLayout(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        menuView.checkState(animation: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            menuView.checkState(animation: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        menuView.checkState(animation: true)
    }
}

extension DetailViewController: TridentMenuViewDelegate {
    
    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }
}

