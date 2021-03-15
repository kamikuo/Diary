//
//  DayItem.swift
//  Diary
//
//  Created by kamikuo on 2020/10/2.
//

import Foundation
import UIKit


class CalendarDiaryStatsView : UIView {
    var diary: JSONDictionary = [:]
}


class CalendarDayItem: UICollectionViewCell {
    
    struct DayOption: OptionSet {
        let rawValue: Int

        static let today    = DayOption(rawValue: 1 << 0)
        static let weekend  = DayOption(rawValue: 1 << 1)
    }
    
    let dayLabel = UILabel(frame: CGRect(x: 4, y: 3, width: 36, height: 16))
    
    var calendarMode: CalendarMode = .month {
        didSet {
            updateDayLabel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        dayLabel.textAlignment = .center
        dayLabel.textColor = UIColor(named: "DayTextColor")
        dayLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        dayLabel.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        dayLabel.addToView(self.contentView, autoresizing: .flexibleAlignmentHoritontalCenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateDayLabel() {
        if calendarMode == .month {
            dayLabel.transform = .identity
            
            if dayOption.contains(.today) {
                dayLabel.textColor = UIColor(named: "DayTextTodayColor")
            } else if dayOption.contains(.weekend) {
                dayLabel.textColor = UIColor(named: "DayTextWeekendColor")
            } else {
                dayLabel.textColor = UIColor(named: "DayTextColor")
            }
            diaryView?.alpha = 1
        } else {
            dayLabel.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            dayLabel.textColor = UIColor(named: "DayTextColor")
            diaryView?.alpha = 0
        }
    }
    
    var day: Int {
        set { dayLabel.text = String(newValue) }
        get { return Int(dayLabel.text ?? "") ?? 0 }
    }
    
    var dayOption: DayOption = [] {
        didSet {
            updateDayLabel()
        }
    }
    
    var diaryView: DiaryView? {
        didSet {
            if diaryView != oldValue {
                oldValue?.removeFromSuperview()
            }
            if let diaryView = diaryView {
                diaryView.frame = CGRect(x: 0, y: 20, width: contentView.frame.width, height: contentView.frame.height - 20)
                diaryView.autoresizingMask = .flexibleSize
                contentView.addSubview(diaryView)
            }
        }
    }
}

class DayModeDiaryView : CalendarDayItem.DiaryView {
    let weekdayLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 36, height: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        weekdayLabel.textColor = UIColor(named: "DayTextColor")?.withAlphaComponent(0.6)
        weekdayLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        weekdayLabel.textAlignment = .center
        weekdayLabel.addToView(contentView, autoresizing: .flexibleSize)
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
