//
//  AdderViewController.swift
//  Diary
//
//  Created by kamikuo on 2020/10/9.
//

import Foundation
import UIKit

class AdderViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    class MatterCell : UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            selectionStyle = .none
            
            textLabel?.textColor = .white
            textLabel?.font = .boldSystemFont(ofSize: 20)
            textLabel?.textAlignment = .center
            textLabel?.layer.cornerRadius = 20
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let textSize = textLabel!.sizeThatFits() + CGSize(width: 30, height: 0)
            textLabel?.frame = CGRect(x: frame.width * 0.5 - textSize.width * 0.5, y: 5, width: textSize.width, height: 40)
        }
        
        var matter: Matter? {
            didSet {
                guard let matter = matter else {
                    textLabel?.text = nil
                    return
                }
                
                textLabel?.text = matter.title
                textLabel?.layer.backgroundColor = matter.color.cgColor
                
                setNeedsLayout()
            }
        }
    }
    
    var date = Date() {
        didSet {
            title = date.formattedDate(style: .long, year: true, month: true, day: true)
        }
    }
    
    let titleLabel = UILabel()
    
    let matters = Array(Matter.allMatters[1...])
    
    let mattersTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 30)
        titleLabel.textColor = .white
        titleLabel.text = "新增記事"
        titleLabel.frame = CGRect(x: 0, y: 10, width: titleLabel.sizeThatFits().width, height: 40)
        titleLabel.addToView(view, autoresizing: .flexibleAlignmentHoritontalCenter)
        
        mattersTableView.backgroundColor = .clear
        mattersTableView.register(MatterCell.self, forCellReuseIdentifier: "menu")
        mattersTableView.delegate = self
        mattersTableView.dataSource = self
        mattersTableView.separatorStyle = .none
        mattersTableView.addToView(view, autoresizing: .flexibleSize)
        mattersTableView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 50)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menu", for: indexPath)
        (cell as? MatterCell)?.matter = matters[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let matter = matters[indexPath.row]
        if matter.adderViewControllerClass is AdderFormViewController.Type {
            let vc = (matter.adderViewControllerClass as! AdderFormViewController.Type).init()
            vc.date = date
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mattersTableView.contentInset = UIEdgeInsets(top: max(mattersTableView.frame.height - CGFloat(50 * matters.count) - 54 - view.safeAreaInsets.bottom, 10), left: 0, bottom: 54, right: 0)
    }
}
