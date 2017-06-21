//
//  UIColor+Extension.swift
//  Yogie
//
//  Created by Erica Y Stevens on 4/27/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    struct YogieTheme {
        static var primaryColor: UIColor  { return UIColor(red: 148/255.0, green: 92/255.0, blue: 138/255.0, alpha: 1.0) }
        static var secondaryColor: UIColor { return UIColor(red: 222/255.0, green: 155/255.0, blue: 213/255.0, alpha: 1.0) }
        static var accentColor: UIColor  { return UIColor(red: 214/255.0, green: 172/255.0, blue: 69/255.0, alpha: 1.0) }
        static var primaryComplementColor: UIColor  { return UIColor(red: 100/255.0, green: 115/255.0, blue: 38/255.0, alpha: 1.0) }
        static var darkPrimaryColor: UIColor  { return UIColor(red: 83/255.0, green: 39/255.0, blue: 83/255.0, alpha: 1.0) }
        static var redAccentColor: UIColor  { return UIColor(red: 125/255.0, green: 38/255.0, blue: 47/255.0, alpha: 1.0) }
    }
}
