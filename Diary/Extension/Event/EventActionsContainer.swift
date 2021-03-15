//
//  EventActionsContainer.swift
//  SwiftEvents
//
//  Created by kamikuo on 2020/9/29.
//  Copyright © 2020 kamikuo. All rights reserved.
//

import Foundation

internal struct EventActionsContainer {
    var actions = [String: [Event.Action]]()
    var handlers = [Int: ([String: Any]?) -> Void]()
    init() {}
}
