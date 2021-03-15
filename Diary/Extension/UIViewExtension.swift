//
//  UIViewExtension.swift
//  PlurkGit
//
//  Created by Jiawei on 2017/11/8.
//  Copyright © 2017年 BrickGit. All rights reserved.
//

import Foundation
import UIKit

class ViewsManager {
    static let main = ViewsManager()
}

extension UIView.AutoresizingMask {
    public static let flexibleSize: UIView.AutoresizingMask = [.flexibleWidth, .flexibleHeight]
    public static let flexibleAlignmentCenter: UIView.AutoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    public static let flexibleAlignmentHoritontalCenter: UIView.AutoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
    public static let flexibleAlignmentVerticalMiddle: UIView.AutoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
}

//Autoresizing
extension UIView {
    open func addToView(_ view: UIView, autoresizing: UIView.AutoresizingMask = []) {
        if !autoresizing.isEmpty {
            switch autoresizing {
            case .flexibleSize:
                frame = CGRect(origin: .zero, size: view.frame.size)
            case .flexibleAlignmentCenter:
                frame.origin = CGPoint(x: (view.frame.width - frame.width) * 0.5, y: (view.frame.height - frame.height) * 0.5)
            case .flexibleAlignmentHoritontalCenter:
                frame.origin.x = (view.frame.width - frame.width) * 0.5
            case .flexibleAlignmentVerticalMiddle:
                frame.origin.y = (view.frame.height - frame.height) * 0.5
            default:
                break
            }
            autoresizingMask = autoresizing
        }
        view.addSubview(self)
    }

    open func sizeThatFits(width: CGFloat) -> CGSize {
        return sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
    }
    
    open func sizeThatFits() -> CGSize {
        return sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }
}

//Effect
extension UIView {
    open func setShadow(color: UIColor, radius: CGFloat, opacity: CGFloat, offset: CGSize){
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = Float(opacity)
        layer.shadowOffset = offset
    }
    
    open func clearShadow(){
        layer.shadowColor = nil
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
    }
    
    open func setBorder(color: UIColor, width: CGFloat){
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    open var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
    
    open func getParentView<View: UIView>(is viewClass: View.Type) -> View? {
        var superView = self
        var parentView: UIView? = nil
        while let nextSuperView = superView.superview {
            if nextSuperView is View {
                parentView = nextSuperView
                break
            }
            superView = nextSuperView
        }
        return parentView as? View
    }
}

extension CALayer {
    private static let nullActions: [String : CAAction] = ["contents":NSNull(), "onLayout":NSNull(), "bounds":NSNull(), "position":NSNull(), "transform": NSNull(), "hidden": NSNull(), "sublayers":NSNull(), "opacity":NSNull()]
    public func disableActions() {
        actions = CALayer.nullActions
    }
}

public enum UserInterfaceDirection: UInt8 {
    case vertical
    case horizontal
}

public extension Set where Element: UITouch {
    var isTap: Bool {
        return count == 1 && first?.tapCount == 1
    }

    func isTap(on view: UIView) -> Bool {
        if count == 1, let touch = first, touch.tapCount == 1, touch.view === view {
            return true
        }
        return false
    }

    func isDoubleTap(on view: UIView) -> Bool {
        if count == 1, let touch = first, touch.tapCount == 2, touch.view === view {
            return true
        }
        return false
    }

    func isTapLocation(in view: UIView) -> CGPoint? {
        if self.count == 1, let touch = self.first, touch.tapCount == 1 {
            return touch.location(in: view)
        }
        return nil
    }
}
