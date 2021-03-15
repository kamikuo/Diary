//
//  Event.swift
//  SwiftEvents
//
//  Created by kamikuo on 2020/9/29.
//  Copyright © 2020 kamikuo. All rights reserved.
//

import Foundation

public struct Event {
    public struct Action {
        private static var actionId = 666
        private static func newActionId() -> Int {
            actionId += 1
            return actionId
        }

        fileprivate let actionId = newActionId()
        fileprivate let event: Event

        fileprivate init(event: Event) {
            self.event = event
        }

        public func remove() {
            if let owner = event.eventsOwner {
                owner.eventActionsContainer.actions[event.name]?.removeAll(where: { $0.actionId == actionId })
                owner.eventActionsContainer.handlers.removeValue(forKey: actionId)
                if owner.eventActionsContainer.actions[event.name]?.isEmpty ?? false {
                    owner.eventActionsContainer.actions.removeValue(forKey: event.name)
                }
            }
        }
    }
    
    fileprivate let name: String
    fileprivate weak var eventsOwner: EventsOwner?

    public init(name: String, owner: EventsOwner) {
        self.name = name
        self.eventsOwner = owner
    }

    @discardableResult public func addAction(handler: @escaping ([String: Any]?) -> Void) -> Event.Action {
        let action = Event.Action(event: self)
        if let owner = eventsOwner {
            owner.eventActionsContainer.handlers[action.actionId] = handler
            if owner.eventActionsContainer.actions[name] == nil {
                owner.eventActionsContainer.actions[name] = [Event.Action]()
            }
            owner.eventActionsContainer.actions[name]?.append(action)
        }
        return action
    }

    public func trigger(_ info: [String: Any]? = nil) {
        if let owner = eventsOwner, let actions = owner.eventActionsContainer.actions[name] {
            for action in actions {
                owner.eventActionsContainer.handlers[action.actionId]?(info)
            }
        }
    }

    public func removeAllAction() {
        if let owner = eventsOwner, let actions = owner.eventActionsContainer.actions[name] {
            for action in actions {
                owner.eventActionsContainer.handlers.removeValue(forKey: action.actionId)
            }
            owner.eventActionsContainer.actions.removeValue(forKey: name)
        }
    }
}
