//
//  UIFont.swift
//  Trident
//
//  Created by bawn on 2020/3/17.
//  Copyright © 2020 bawn. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    var weightValue: Float {
        guard let weightNumber = traits[.weight] as? NSNumber else {
            return 0
        }
        return weightNumber.floatValue
    }

    private var traits: [UIFontDescriptor.TraitKey: Any] {
        return fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any] ?? [:]
    }
}
