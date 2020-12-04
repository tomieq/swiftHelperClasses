//
//  UINavigationController+Extension.swift
//
//  Created by tomieq on 21.09.2017.
//  Copyright © 2017 tomieq. All rights reserved.
//

import UIKit

extension UINavigationController {

    func popToClassType<T: UIViewController>(_ stackClassType: T.Type) {
        for vc in viewControllers.reversed() {
            if vc is T {
                popToViewController(vc, animated: true)
                return
            }
        }
    }
}
