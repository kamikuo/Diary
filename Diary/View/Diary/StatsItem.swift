//
//  MatterStatsItem.swift
//  Diary
//
//  Created by kamikuo on 2020/10/17.
//

import Foundation
import UIKit

class StatsItem : UITableViewCell {

    static let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor(named: "StatsTextColor")!]
    static let numberAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor(named: "StatsNumberColor")!]

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        textLabel?.font = .boldSystemFont(ofSize: 15)
        textLabel?.textColor = UIColor(named: "StatsTitleColor")
        textLabel?.clipsToBounds = false
        
        let lineLabel = UILabel()
        lineLabel.font = .boldSystemFont(ofSize: 14)
        lineLabel.textColor = UIColor(named: "StatsTitleColor")
        lineLabel.text = "／"
        lineLabel.textAlignment = .center
        lineLabel.frame = CGRect(x: textLabel!.frame.width, y: 0, width: 14, height: textLabel!.frame.height)
        lineLabel.addToView(textLabel!, autoresizing: [.flexibleLeftMargin, .flexibleHeight])
        
        detailTextLabel?.numberOfLines = 0

        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var diary: JSONDictionary = [:]

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = CGRect(x: 0, y: 6, width: frame.width, height: frame.height - 12)

        let titleSize = textLabel?.text?.isEmpty ?? true ? .zero : textLabel!.sizeThatFits(width: contentView.frame.width - 34)
        textLabel?.frame = CGRect(x: 26, y: 14, width: titleSize.width, height: titleSize.height)
        
        let contentSize = detailTextLabel!.sizeThatFits(width: contentView.frame.width - 28 - 6 - titleSize.width)
        detailTextLabel?.frame = CGRect(x: textLabel!.frame.maxX + 16, y: 12, width: contentSize.width, height: contentSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let titleSize = textLabel?.text?.isEmpty ?? true ? .zero : textLabel!.sizeThatFits(width: contentView.frame.width - 24)
        let contentSize = detailTextLabel!.sizeThatFits(width: contentView.frame.width - 28 - 6 - titleSize.width)
        
        return CGSize(width: size.width, height: max(titleSize.height, contentSize.height) + 20)
    }
}
