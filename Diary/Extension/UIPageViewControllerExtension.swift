//
//  UIPageViewControllerExtension.swift
//  Diary
//
//  Created by kamikuo on 2020/11/8.
//

import Foundation
import UIKit

extension UIPageViewController {
    
    var scrollView: UIScrollView? {
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }
    
    var visibleViewControllers: [UIViewController] {
        return children.filter { vc -> Bool in
            return vc.view.superview != nil && self.view.bounds.intersects(vc.view.convert(vc.view.bounds, to: self.view))
        }
    }
    
//    var middleViewController: UIViewController? {
//        
//    }
}

//        pvc.pageViewController.children.sorted(by: <#T##(UIViewController, UIViewController) throws -> Bool#>)

//pvc.pageViewController.children.forEach { vc in
//    print(vc.view.convert(vc.view.bounds, to: pvc.pageViewController.view), vc.view.convert(vc.view.bounds, to: monthPageScrollView), vc.view.isHidden, vc.view.superview)
//}
//        print(pvc.pageViewController.children.filter { vc -> Bool in
////            pvc.pageViewController.view.bounds.intersects(<#T##rect2: CGRect##CGRect#>)
//            return vc.view.superview != nil && pvc.pageViewController.view.bounds.intersects(vc.view.convert(vc.view.bounds, to: pvc.pageViewController.view))
//        })
//        print(pvc.pageViewController.children.filter { vc -> Bool in
//            return vc.view.superview != nil && pvc.pageViewController.view.bounds.contains(vc.view.convert(vc.view.bounds, from: pvc.pageViewController.view))
//        })

//        print(pvc.pageViewController.children.map({ vc -> CGRect in
//            return vc.view.convert(vc.view.bounds, to: pvc.pageViewController.view)
//        }))
//
