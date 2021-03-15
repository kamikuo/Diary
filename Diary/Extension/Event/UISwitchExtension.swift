//
//  UISwitchExtension.swift
//  SwiftEvents
//
//  Created by kamikuo on 2020/10/2.
//  Copyright © 2020 kamikuo. All rights reserved.
//

import Foundation
import UIKit

extension UISwitch: EventsOwner {
    public var switchChangeEvent: Diary.Event {
        removeTarget(self, action: #selector(didSwitch), for: .valueChanged)
        addTarget(self, action: #selector(didSwitch), for: .valueChanged)
        return Diary.Event(name: "switchChange", owner: self)
    }
    @objc private func didSwitch() {
        switchChangeEvent.trigger()
    }
}
