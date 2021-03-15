//
//  EarningMatter.swift
//  Diary
//
//  Created by kamikuo on 2020/11/1.
//

import Foundation
import UIKit

extension Matter {
    private class EarningDayItem : CalendarDayItemStatsView {
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
                if let earning = diary["earning"] as? [JSONDictionary] {
                    let sum = earning.reduce(0, { $0 + ($1["amount"] as? Int ?? 0) })
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: "$", attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 0.5), .font: UIFont.systemFont(ofSize: 9)]))
                    attrString.append(NSAttributedString(string: String(sum), attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1.0), .font: UIFont.systemFont(ofSize: 14)]))
                    label.attributedText = attrString
                }
            }
        }
    }

    private class EarningAdderFormViewController : AdderFormViewController {
        
        let sourceCell = AdderFormViewController.TextFieldCell()
        let amountCell = AdderFormViewController.TextFieldCell()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            titleLabel.text = Matter.earning.title
            
            sourceCell.commons = ["薪資", "利息", "回饋", "攝影", "老婆"]
            sourceCell.textField.placeholder = "來源"
            
            amountCell.textField.placeholder = "金額"
            amountCell.textField.keyboardType = .numberPad

            cells = [sourceCell, amountCell]
        }
        
        override func submit(completion: () -> Void) {
            if let source = sourceCell.textField.text, !source.isEmpty, let amount = Int(amountCell.textField.text ?? ""), amount > 0 {
                var earning = DiaryModel.share.getDiary(at: date)["earning"] as? [JSONDictionary] ?? []
                earning.append(["source": source, "amount": amount])
                DiaryModel.share.updateDiary(["earning": earning], at: date)
                completion()
            }
        }
    }

    private class EarningStatsItem : StatsItem {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textLabel?.text = Matter.earning.title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                if let earning = diary["earning"] as? [JSONDictionary] {
                    var sum = 0
                    var sums = [String: Int]()
                    earning.forEach { item in
                        if let source = item["source"] as? String , let amount = item["amount"] as? Int {
                            sums[source, default: 0] += amount
                            sum += amount
                        }
                    }
                    
                    let attrString = NSMutableAttributedString()
                    sums.keys.sorted().forEach { source in
                        attrString.append(NSAttributedString(string: source, attributes: StatsItem.textAttributes))
                        attrString.append(NSAttributedString(string: " $", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor(named: "StatsTextColor")!]))
                        attrString.append(NSAttributedString(string: String(sums[source]!) + "\n", attributes: StatsItem.textAttributes))
                    }
                    
                    attrString.append(NSAttributedString(string: "總計 $", attributes: StatsItem.textAttributes))
                    attrString.append(NSAttributedString(string: String(sum), attributes: StatsItem.numberAttributes))
                    detailTextLabel?.attributedText = attrString
                }
            }
        }
    }
    
    static let earning =
        Matter(key: "earning",
               title: "收入",
               color: UIColor(red: 0.91, green:0.76, blue:0.44, alpha:1),
               calendarDiaryStatsViewClass: EarningDayItem.self,
               adderViewControllerClass: EarningAdderFormViewController.self,
               statsItemClass: EarningStatsItem.self)
}
