//
//  WaterMatter.swift
//  Diary
//
//  Created by kamikuo on 2020/11/1.
//

import Foundation
import UIKit

extension Matter {
    private class WaterDayItem : CalendarDayItemStatsView {
        let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            label.textAlignment = .center
            label.numberOfLines = 0
            label.addToView(self, autoresizing: .flexibleSize)
            label.frame = CGRect(x: 4, y: 0, width: frame.width - 8, height: frame.height)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                if let mls = diary["water"] as? [Int] {
                    let ml = mls.reduce(0, +)
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: String(ml), attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1.0), .font: UIFont.systemFont(ofSize: 14)]))
                    attrString.append(NSAttributedString(string: "\n毫升", attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 0.5), .font: UIFont.systemFont(ofSize: 9)]))
                    label.attributedText = attrString
                }
            }
        }
    }

    private class WaterAdderFormViewController : AdderFormViewController {
        
        let mlCell = AdderFormViewController.TextFieldCell()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            titleLabel.text = Matter.water.title
            
            cells = [mlCell]
            
            mlCell.commons = ["100", "250", "500", "1000"]
            mlCell.textField.placeholder = "毫升"
            mlCell.textField.keyboardType = .numberPad
        }
        
        override func submit(completion: () -> Void) {
            if let ml = Int(mlCell.textField.text ?? ""), ml > 0 {
                var mls = DiaryModel.share.getDiary(at: date)["water"] as? [Int] ?? []
                mls.append(ml)
                DiaryModel.share.updateDiary(["water": mls], at: date)
                completion()
            }
        }
    }

    private class WaterStatsItem : StatsItem {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textLabel?.text = Matter.water.title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                if let mls = diary["water"] as? [Int] {
                    let ml = mls.reduce(0, +)
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: String(ml), attributes: StatsItem.numberAttributes))
                    attrString.append(NSAttributedString(string: " 毫升", attributes: StatsItem.textAttributes))
                    detailTextLabel?.attributedText = attrString
                }
            }
        }
    }
    
    static let water =
        Matter(key: "water",
               title: "水",
               color: UIColor(red: 0.5, green: 0.73, blue: 1.0, alpha:1),
               calendarDiaryStatsViewClass: WaterDayItem.self,
               adderViewControllerClass: WaterAdderFormViewController.self,
               statsItemClass: WaterStatsItem.self)
}
