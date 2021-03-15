//
//  BodyfatMatter.swift
//  Diary
//
//  Created by kamikuo on 2020/10/28.
//

import Foundation
import UIKit

extension Matter {
    
    private class BodyfatDayItem : CalendarDayItemStatsView {
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
                if let weight = diary["bodyfat"] as? Double {
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: String(weight), attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1.0), .font: UIFont.systemFont(ofSize: 14)]))
                    attrString.append(NSAttributedString(string: "\n%", attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 0.5), .font: UIFont.systemFont(ofSize: 9)]))
                    label.attributedText = attrString
                }
            }
        }
    }

    private class BodyfatAdderFormViewController : AdderFormViewController {
        
        let weightCell = AdderFormViewController.TextFieldCell()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            titleLabel.text = Matter.bodyfat.title
            
            cells = [weightCell]
            
            weightCell.textField.placeholder = "%"
            weightCell.textField.keyboardType = .decimalPad

            if let value = DiaryModel.share.getDiary(at: date)["bodyfat"] as? Double {
                weightCell.textField.text = String(value)
            }
        }
        
        override func submit(completion: () -> Void) {
            let weight = Double(weightCell.textField.text ?? "")
            DiaryModel.share.updateDiary(["bodyfat": weight], at: date)
            completion()
        }
    }

    private class BodyfatStatsItem : StatsItem {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textLabel?.text = Matter.bodyfat.title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                if let weight = diary["bodyfat"] as? Double {
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: String(weight), attributes: StatsItem.numberAttributes))
                    attrString.append(NSAttributedString(string: " %", attributes: StatsItem.textAttributes))
                    detailTextLabel?.attributedText = attrString
                }
            }
        }
    }
    
    static let bodyfat =
        Matter(key: "bodyfat",
               title: "體脂肪",
               color: UIColor(red: 1, green:0.57, blue:0.52, alpha:1),
               calendarDiaryStatsViewClass: BodyfatDayItem.self,
               adderViewControllerClass: BodyfatAdderFormViewController.self,
               statsItemClass: BodyfatStatsItem.self)
}
