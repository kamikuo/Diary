//
//  DispatchExtension.swift
//
//  Created by Jiawei on 2017/12/5.
//  Copyright © 2017年 Jiawei. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    func asyncAfter(seconds: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(seconds * 1000)), execute: execute)
    }
}

public extension DispatchSource {
    static func timer(repeating: TimeInterval, handler: @escaping () -> Bool) {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        var keepTimer: DispatchSourceTimer? = timer
        timer.schedule(deadline: .now(), repeating: repeating)
        timer.setEventHandler {
            DispatchQueue.main.async {
                if !handler() {
                    keepTimer?.cancel()
                    keepTimer = nil
                }
            }
        }
        timer.resume()
    }
}
