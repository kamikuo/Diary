//
//  UITextFieldExtension.swift
//  SwiftEvents
//
//  Created by kamikuo on 2020/10/2.
//  Copyright © 2020 kamikuo. All rights reserved.
//

import Foundation
import UIKit

extension UITextField : UITextFieldDelegate, EventsOwner {
    
    public var textChangeEvent: Diary.Event {
        removeTarget(self, action: #selector(onEditingChanged), for: .editingChanged)
        addTarget(self, action: #selector(onEditingChanged), for: .editingChanged)
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
    public var keyboardReturnEvent: Diary.Event {
        delegate = self
        return Diary.Event(name: "keyboardReturn", owner: self)
    }

    @objc private func onEditingChanged() {
        textChangeEvent.trigger()
    }

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        beginEditingEvent.trigger()
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingEvent.trigger()
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyboardReturnEvent.trigger()
        return true
    }
    
    private static var maxLengthKey = "maxLength"
    open var maxLength: Int? {
        get { return objc_getAssociatedObject(self, &UITextField.maxLengthKey) as? Int }
        set { objc_setAssociatedObject(self, &UITextField.maxLengthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let maxLength = maxLength {
            if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length >= maxLength {
                return false
            }
        }
        return true
    }
}
