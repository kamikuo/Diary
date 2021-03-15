//
//  WineMatter.swift
//  Diary
//
//  Created by kamikuo on 2020/11/2.
//

import Foundation
import UIKit

extension Matter {
    private class WineDayItem : CalendarDayItemStatsView {
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
                if let wine = diary["wine"] as? [JSONDictionary] {
                    let sum = wine.reduce(0) { (r, item) -> Double in
                        if let alcPercent = item["alc"] as? Double {
                            return r + (alcPercent * 0.01 * Double(item["amount"] as? Int ?? 0))
                        }
                        return r
                    }
                    let attrString = NSMutableAttributedString()
                    attrString.append(NSAttributedString(string: "酒精\n", attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 0.5), .font: UIFont.systemFont(ofSize: 9)]))
                    attrString.append(NSAttributedString(string: String(Int(sum * 0.785)), attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1.0), .font: UIFont.systemFont(ofSize: 14)]))
                    attrString.append(NSAttributedString(string: "\n公克", attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 0.5), .font: UIFont.systemFont(ofSize: 9)]))
                    label.attributedText = attrString
                }
            }
        }
    }

    private class WineAdderFormViewController : AdderFormViewController {
        
        let alcCell = AdderFormViewController.TextFieldCell()
        let mlCell = AdderFormViewController.TextFieldCell()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            titleLabel.text = Matter.wine.title
            
            alcCell.commons = ["4.8", "5.0", "5.6", "8.0", "12.0", "13.0", "40.0"]
            alcCell.textField.placeholder = "ALC.%"
            alcCell.textField.keyboardType = .decimalPad
            
            mlCell.commons = ["100", "250", "500"]
            mlCell.textField.placeholder = "毫升"
            mlCell.textField.keyboardType = .numberPad
            
            cells = [alcCell, mlCell]
        }
        
        override func submit(completion: () -> Void) {
            if let alc = Double(alcCell.textField.text ?? ""), alc > 0, let ml = Int(mlCell.textField.text ?? ""), ml > 0 {
                var wine = DiaryModel.share.getDiary(at: date)["wine"] as? [JSONDictionary] ?? []
                wine.append(["alc": alc, "amount": ml])
                DiaryModel.share.updateDiary(["wine": wine], at: date)
                completion()
            }
        }
    }
    private class WineStatsItem : StatsItem {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textLabel?.text = Matter.wine.title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                if let wine = diary["wine"] as? [JSONDictionary] {
                    var sum = 0.0
                    var sums = [Double: Int]()
                    wine.forEach { item in
                        if let alcPercent = item["alc"] as? Double {
                            let amount = item["amount"] as? Int ?? 0
                            sums[alcPercent, default: 0] += amount
                            let alc = alcPercent * 0.01 * Double(amount)
                            sum += alc
                        }
                    }
                    
                    let attrString = NSMutableAttributedString()
                    sums.keys.sorted().forEach { alcPercent in
                        attrString.append(NSAttributedString(string: String(alcPercent), attributes: [.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(named: "StatsNumberColor")!]))
                        attrString.append(NSAttributedString(string: "% ", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor(named: "StatsTextColor")!]))
                        attrString.append(NSAttributedString(string: String(sums[alcPercent]!), attributes: [.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(named: "StatsNumberColor")!]))
                        attrString.append(NSAttributedString(string: "毫升\n", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor(named: "StatsTextColor")!]))
                    }
                    
                    attrString.append(NSAttributedString(string: "\n", attributes:[.font: UIFont.systemFont(ofSize: 10)]))
                    
                    attrString.append(NSAttributedString(string: "酒精共 ", attributes: StatsItem.textAttributes))
                    attrString.append(NSAttributedString(string: String(sum * 0.785), attributes: StatsItem.numberAttributes))
                    attrString.append(NSAttributedString(string: " 公克", attributes: StatsItem.textAttributes))
                    
                    detailTextLabel?.attributedText = attrString
                }
            }
        }
    }
    
    static let wine =
        Matter(key: "wine",
               title: "酒",
               color: UIColor(red: 0.835, green:0.604, blue:0.396, alpha:1),
               calendarDiaryStatsViewClass: WineDayItem.self,
               adderViewControllerClass: WineAdderFormViewController.self,
               statsItemClass: WineStatsItem.self)
}
