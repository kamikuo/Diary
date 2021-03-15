//
//  DayItem.swift
//  Diary
//
//  Created by kamikuo on 2020/10/2.
//

import Foundation
import UIKit


class CalendarDayItemStatsView : UIView {
    var diary: JSONDictionary = [:]
}

class CalendarDayItem: UICollectionViewCell {
    
    struct DayOption: OptionSet {
        let rawValue: Int

        static let today = DayOption(rawValue: 1 << 0)
        static let weekend = DayOption(rawValue: 1 << 1)
    }
    
    let dayLabel = UILabel(frame: CGRect(x: 4, y: 3, width: 36, height: 19))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        dayLabel.textColor = UIColor(named: "DayTextColor")
        dayLabel.textAlignment = .center
        dayLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
        dayLabel.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        dayLabel.frame = CGRect(x: 0, y: 0, width: 38, height: 19)
        dayLabel.layer.cornerRadius = 5
        dayLabel.addToView(self.contentView, autoresizing: .flexibleAlignmentHoritontalCenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateDayLabel() {
        dayLabel.transform = .identity
        
        if dayOption.contains(.today) {
            dayLabel.layer.backgroundColor = matter?.color.cgColor
            dayLabel.textColor = UIColor(named: "DayColor")
        } else if dayOption.contains(.weekend) {
            dayLabel.textColor = UIColor(named: "DayTextWeekendColor")
        } else {
            dayLabel.textColor = UIColor(named: "DayTextColor")
        }
        
        setNeedsLayout()
    }
    
    var day: Int {
        set {
            dayLabel.text = String(newValue)
            dayLabel.bounds.size.width = dayLabel.sizeThatFits().width + 6
        }
        get { return Int(dayLabel.text ?? "") ?? 0 }
    }
    
    var dayOption: DayOption = [] {
        didSet {
            updateDayLabel()
        }
    }
    
    var matter: Matter? {
        didSet {
            if let matter = matter {
                if matter != oldValue {
                    updateDayLabel()
                    statsView = (matter.calendarDiaryStatsViewClass as! CalendarDayItemStatsView.Type).init()
                    statsView?.diary = diary
                }
            } else {
                statsView = nil
            }
        }
    }
    
    var diary: JSONDictionary = [:] {
        didSet {
            statsView?.diary = diary
        }
    }
    
    var statsView: CalendarDayItemStatsView? {
        didSet {
            if statsView != oldValue {
                oldValue?.removeFromSuperview()
            }
            statsView?.addToView(contentView)
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statsView?.frame = CGRect(x: 0, y: dayLabel.frame.maxY + 2, width: contentView.frame.width, height: contentView.frame.height -  dayLabel.frame.maxY - 6)
    }
}
