//
//  WeekdayItem.swift
//  Diary
//
//  Created by kamikuo on 2020/11/4.
//

import Foundation
import UIKit

class CalendarWeekdayItem: UICollectionViewCell {
    let weekdayLabel = UILabel(frame: CGRect(x: 4, y: 12, width: 36, height: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        weekdayLabel.textColor = UIColor(named: "DayTextColor")?.withAlphaComponent(0.6)
        weekdayLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        weekdayLabel.textAlignment = .center
        weekdayLabel.addToView(self.contentView, autoresizing: .flexibleAlignmentCenter)

        weekdayLabel.frame.origin.y = frame.height * 0.4 - 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var weekday: Int = 0 {
        didSet {
            weekdayLabel.text = Date(timeIntervalSince1970: 86400 * TimeInterval(3 + weekday)).formattedDate(localizedTemplate: "EEEEEE")
            weekdayLabel.bounds.size.width = weekdayLabel.sizeThatFits().width
        }
    }
}
