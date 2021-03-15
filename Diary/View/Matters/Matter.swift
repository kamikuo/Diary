//
//  Matter.swift
//  Diary
//
//  Created by kamikuo on 2020/10/20.
//

import Foundation
import UIKit

struct Matter : Equatable {
    let key: String
    let title: String
    let color: UIColor
    let calendarDiaryStatsViewClass: AnyClass
    let adderViewControllerClass: AnyClass
    let statsItemClass: AnyClass
    
    func isExist(in diary: JSONDictionary) -> Bool {
        return diary[key] != nil
    }
    
    static func == (lhs: Matter, rhs: Matter) -> Bool {
        return lhs.key == rhs.key
    }
}


extension Matter {
    static let allMatters: [Matter] = [
        .note,
        .bodyweight,
        .bodyfat,
        .sport,
        .read,
        .water,
        .wine,
        .earning,
        .expenditure
    ]
}
