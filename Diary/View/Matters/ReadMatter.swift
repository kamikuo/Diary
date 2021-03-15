//
//  ReadMatter.swift
//  Diary
//
//  Created by kamikuo on 2020/11/1.
//

import Foundation
import UIKit

extension Matter {
    private class ReadDayItem : CalendarDayItemStatsView {
        let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            label.numberOfLines = 0
            label.textAlignment = .center
            label.addToView(self, autoresizing: .flexibleSize)
            label.frame = CGRect(x: 4, y: 0, width: frame.width - 8, height: frame.height)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                if let times = diary["read"] as? [Int] {
                    let time = times.reduce(0, +)
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: String(time), attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1.0), .font: UIFont.systemFont(ofSize: 14)]))
                    attrString.append(NSAttributedString(string: "\n分", attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 0.5), .font: UIFont.systemFont(ofSize: 9)]))
                    label.attributedText = attrString
                }
            }
        }
    }

    private class ReadAdderFormViewController : AdderFormViewController {
        
        let timeCell = AdderFormViewController.TextFieldCell()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            titleLabel.text = Matter.read.title
            
            cells = [timeCell]
            
            timeCell.commons = ["15", "20", "30", "45", "60"]
            timeCell.textField.placeholder = "分鐘"
            timeCell.textField.keyboardType = .numberPad
        }
        
        override func submit(completion: () -> Void) {
            if let time = Int(timeCell.textField.text ?? ""), time > 0 {
                var times = DiaryModel.share.getDiary(at: date)["read"] as? [Int] ?? []
                times.append(time)
                DiaryModel.share.updateDiary(["read": times], at: date)
                completion()
            }
        }
    }

    private class ReadStatsItem : StatsItem {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textLabel?.text = Matter.read.title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                if let times = diary["read"] as? [Int] {
                    let time = times.reduce(0, +)
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: String(time), attributes: StatsItem.numberAttributes))
                    attrString.append(NSAttributedString(string: " 分鐘", attributes: StatsItem.textAttributes))
                    detailTextLabel?.attributedText = attrString
                }
            }
        }
    }
    
    static let read =
        Matter(key: "read",
               title: "閱讀",
               color: UIColor(red: 0.77, green:0.6, blue:0.45, alpha:1),
               calendarDiaryStatsViewClass: ReadDayItem.self,
               adderViewControllerClass: ReadAdderFormViewController.self,
               statsItemClass: ReadStatsItem.self)
}
