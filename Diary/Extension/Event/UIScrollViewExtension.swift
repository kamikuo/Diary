//
//  UIScrollViewExtension.swift
//  SwiftEvents
//
//  Created by kamikuo on 2020/10/2.
//  Copyright © 2020 kamikuo. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView : UIScrollViewDelegate, EventsOwner {
    public var scrollEvent: Event {
        delegate = self
        return Event(name: "scroll", owner: self)
    }
    public var willBeginDragEvent: Event {
        delegate = self
        return Event(name: "willBeginDrag", owner: self)
    }
    public var didEndDragEvent: Event {
        delegate = self
        return Event(name: "didEndDrag", owner: self)
    }
    public var didEndScrollEvent: Event {
        delegate = self
        return Event(name: "didEndScroll", owner: self)
    }

    public var contentOffsetTranslate: CGPoint {
        return CGPoint(x: contentOffset.x - preContentOffset.x, y: contentOffset.y - preContentOffset.y)
    }

    public var isDraggingOrDecelerating: Bool {
        return isDragging || isDecelerating
    }

    private static var preContentOffsetKey = "preContentOffset"
    private var preContentOffset: CGPoint {
        get { return objc_getAssociatedObject(self, &UIScrollView.preContentOffsetKey) as? CGPoint ?? .zero }
        set { objc_setAssociatedObject(self, &UIScrollView.preContentOffsetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollEvent.trigger()
        preContentOffset = scrollView.contentOffset
    }
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        willBeginDragEvent.trigger()
    }
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndDragEvent.trigger()
        if !decelerate {
            didEndScrollEvent.trigger()
        }
    }
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndScrollEvent.trigger()
    }
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didEndScrollEvent.trigger()
    }
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
    }

    //fix the bug that view cover the scrollbar if use addSubview in scrollview's layoutSubviews
    open override func addSubview(_ view: UIView) {
        super.insertSubview(view, at: subviews.count)
    }
}
