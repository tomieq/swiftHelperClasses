//
//  UIColor+Extension.swift
//
//  Created by tomieq on 15.05.2017.
//  Copyright © 2017 tomieq. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: Float = 1.0) {
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.scanLocation = 1
        } else {
            scanner.scanLocation = 0
        }

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: CGFloat(alpha)
        )
    }

    class func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: alpha)
    }

    class func random() -> UIColor {
        return UIColor.rgb(CGFloat(200 + arc4random_uniform(55)), CGFloat(200 + arc4random_uniform(55)), CGFloat(200 + arc4random_uniform(55)))
    }
}
