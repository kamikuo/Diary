//
//  UIButtonExtension.swift
//  SwiftEvents
//
//  Created by kamikuo on 2020/10/2.
//  Copyright © 2020 kamikuo. All rights reserved.
//

import Foundation
import UIKit

extension UIButton: Diary.EventsOwner {
    public var clickEvent: Diary.Event {
        removeTarget(self, action: #selector(click), for: .touchUpInside)
        addTarget(self, action: #selector(click), for: .touchUpInside)
        return Diary.Event(name: "click", owner: self)
    }
    @objc private func click() {
        clickEvent.trigger()
    }
}
