//
//  UIWindowExtension.swift
//  PlurkGit
//
//  Created by Jiawei on 2019/3/21.
//  Copyright © 2019 BrickGit. All rights reserved.
//

import Foundation
import UIKit

public extension UIWindow {
    var topViewController: UIViewController? {
        var topController = rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    var topNavigationController: UINavigationController? {
        var navigationController: UINavigationController? = nil
        var topViewController = rootViewController
        repeat {
            if let naviVC = topViewController as? UINavigationController {
                navigationController = naviVC
            }
            topViewController = topViewController?.presentedViewController
        } while topViewController != nil
        return navigationController
    }

    var topView: UIView? {
        return topViewController?.view
    }

    func transition(to viewController: UIViewController, completion: (() -> Void)?) {
        if rootViewController != nil {
            UIView.transition(with: self, duration: 0.5, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
                let oldAnimationEnable = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(true)
                self.rootViewController = viewController
                self.makeKeyAndVisible()
                UIView.setAnimationsEnabled(oldAnimationEnable)
            }, completion: { (_) in
                self.makeKeyAndVisible()
                completion?()
            })
        } else {
            rootViewController = viewController
            makeKeyAndVisible()
            completion?()
        }
    }
}
