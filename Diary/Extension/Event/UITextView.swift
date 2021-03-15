//
//  UITextView.swift
//  SwiftEvents
//
//  Created by kamikuo on 2020/10/2.
//  Copyright © 2020 kamikuo. All rights reserved.
//

import Foundation
import UIKit

extension UITextView : UITextViewDelegate {
    public var textChangeEvent: Diary.Event {
        delegate = self
        return Diary.Event(name: "textChange", owner: self)
    }
    public var beginEditingEvent: Diary.Event {
        delegate = self
        return Diary.Event(name: "beginEditing", owner: self)
    }
    public var endEditingEvent: Diary.Event {
        delegate = self
        return Diary.Event(name: "endEditing", owner: self)
    }
    public var selectionChangeEvent: Diary.Event {
        delegate = self
        return Diary.Event(name: "selectionChange", owner: self)
    }

    open func textViewDidChange(_ textView: UITextView) {
        textChangeEvent.trigger()
    }

    open func textViewDidBeginEditing(_ textView: UITextView) {
        beginEditingEvent.trigger()
    }

    open func textViewDidEndEditing(_ textView: UITextView) {
        endEditingEvent.trigger()
    }

    open func textViewDidChangeSelection(_ textView: UITextView) {
        selectionChangeEvent.trigger()
    }
}

public protocol ViewTextAttachment : class {
    func attachmentView(for textView: UITextView, characterIndex charIndex: Int) -> UIView
    func attachmentView(_ attachmentView: UIView, didLayoutFor textView: UITextView, characterIndex charIndex: Int)
}

extension ViewTextAttachment {
    public func attachmentView(_ attachmentView: UIView, didLayoutFor textView: UITextView, characterIndex charIndex: Int) {}
}
