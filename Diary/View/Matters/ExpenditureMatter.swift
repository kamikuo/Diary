//
//  ExpenditureMatter.swift
//  Diary
//
//  Created by kamikuo on 2020/11/1.
//

import Foundation
import UIKit

extension Matter {
    private class ExpenditureDayItem : CalendarDayItemStatsView {
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
                if let expenditure = diary["expenditure"] as? [JSONDictionary] {
                    let sum = expenditure.reduce(0, { $0 + ($1["amount"] as? Int ?? 0) })
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: "$", attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 0.5), .font: UIFont.systemFont(ofSize: 9)]))
                    attrString.append(NSAttributedString(string: String(sum), attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1.0), .font: UIFont.systemFont(ofSize: 14)]))
                    label.attributedText = attrString
                }
            }
        }
    }

    private class ExpenditureAdderFormViewController : AdderFormViewController {
        
        let sourceCell = AdderFormViewController.TextFieldCell()
        let amountCell = AdderFormViewController.TextFieldCell()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            titleLabel.text = Matter.expenditure.title
            
            sourceCell.commons = ["食", "衣", "住", "行", "樂"]
            sourceCell.textField.placeholder = "類別"
            
            amountCell.textField.placeholder = "金額"
            amountCell.textField.keyboardType = .numberPad

            cells = [sourceCell, amountCell]
        }
        
        override func submit(completion: () -> Void) {
            if let source = sourceCell.textField.text, !source.isEmpty, let amount = Int(amountCell.textField.text ?? ""), amount > 0 {
                var expenditure = DiaryModel.share.getDiary(at: date)["expenditure"] as? [JSONDictionary] ?? []
                expenditure.append(["source": source, "amount": amount])
                DiaryModel.share.updateDiary(["expenditure": expenditure], at: date)
                completion()
            }
        }
    }

    private class ExpenditureStatsItem : StatsItem {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textLabel?.text = Matter.expenditure.title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                if let expenditure = diary["expenditure"] as? [JSONDictionary] {
                    
                    var sum = 0
                    var sums = [String: Int]()
                    expenditure.forEach { item in
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
    
    static let expenditure =
        Matter(key: "expenditure",
               title: "花費",
               color: UIColor(red: 0.91, green:0.76, blue:0.44, alpha:1),
               calendarDiaryStatsViewClass: ExpenditureDayItem.self,
               adderViewControllerClass: ExpenditureAdderFormViewController.self,
               statsItemClass: ExpenditureStatsItem.self)
}
