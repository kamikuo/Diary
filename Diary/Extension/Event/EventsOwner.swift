//
//  EventsOwner.swift
//  SwiftEvents
//
//  Created by kamikuo on 2020/9/29.
//  Copyright © 2020 kamikuo. All rights reserved.
//

import Foundation

public protocol EventsOwner : AnyObject {
}

fileprivate extension EventActionsContainer {
    static var associatedObjectKey = "eventActionsContainer"
}

internal extension EventsOwner {
    var eventActionsContainer: EventActionsContainer {
        set {
            objc_setAssociatedObject(self, &EventActionsContainer.associatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &EventActionsContainer.associatedObjectKey) as? EventActionsContainer ?? EventActionsContainer()
        }
    }
}



