//
//  Diary.swift
//  Diary
//
//  Created by kamikuo on 2020/10/22.
//

import Foundation
import UIKit

extension Matter {
    private class NoteDayItem : CalendarDayItemStatsView {
        let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            label.font = .systemFont(ofSize: 8)
            label.numberOfLines = 4
            label.lineBreakMode = .byTruncatingTail
            label.textAlignment = .center
            label.textColor = UIColor(named: "DayTextColor")
            label.addToView(self, autoresizing: .flexibleSize)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                label.text = diary["note"] as? String
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            label.frame = CGRect(x: 0, y: 0, width: frame.width, height: min(frame.height, label.sizeThatFits(width: frame.width).height))
        }
    }

    private class NoteAdderFormViewController : AdderFormViewController {
        
        let contentCell = AdderFormViewController.TextViewCell()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            titleLabel.text = Matter.note.title
            
            cells = [contentCell]
            
            contentCell.textView.text = DiaryModel.share.getDiary(at: date)["note"] as? String
        }
        
        override func submit(completion: () -> Void) {
            let content = contentCell.textView.text ?? ""
            DiaryModel.share.updateDiary(["note": content], at: date)
            completion()
        }
    }

    private class NoteStatsItem : StatsItem {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            textLabel?.numberOfLines = 0
            textLabel?.textColor = UIColor(white: 0.4, alpha: 1.0)
            textLabel?.font = .systemFont(ofSize: 17)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                textLabel?.text = diary["note"] as? String
            }
        }
    }
    
    static let note =
        Matter(key: "note",
              title: "日記",
              color: UIColor(red: 1, green:0.75, blue:0.79, alpha:1),
              calendarDiaryStatsViewClass: NoteDayItem.self,
              adderViewControllerClass: NoteAdderFormViewController.self,
              statsItemClass: NoteStatsItem.self)
}
