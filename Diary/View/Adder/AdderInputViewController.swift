//
//  AdderInputViewController.swift
//  Diary
//
//  Created by kamikuo on 2020/10/12.
//

import Foundation
import UIKit

class AdderFormViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    class TextViewCell: UITableViewCell {
        let textView = UITextView()
        
        init() {
            super.init(style: .default, reuseIdentifier: nil)
            
            backgroundColor = .clear
            
            textView.font = .systemFont(ofSize: 20)
            textView.backgroundColor = .white
            textView.layer.cornerRadius = 20
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            textView.addToView(self.contentView, autoresizing: .flexibleWidth)
            textView.frame = CGRect(x: 20, y: 20, width: frame.width - 40, height: 200)
            
            selectionStyle = .none
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func sizeThatFits(_ size: CGSize) -> CGSize {
            return CGSize(width: size.width, height: 240)
        }
    }
    
    class TextFieldCell : UITableViewCell {
        let textField = UITextField()
        
        let commonView = UIView()
        private(set) var commonButtons = [UIButton]()
        var commons = [String]() {
            didSet {
                self.commonButtons = commons.map({ value -> UIButton in
                    let button = UIButton()
                    button.backgroundColor = .clear
                    button.setTitleColor(.white, for: .normal)
                    button.setBorder(color: .white, width: 0.8)
                    button.layer.cornerRadius = 17
                    button.setTitle(value, for: .normal)
                    button.frame.size = CGSize(width: button.sizeThatFits().width + 24, height: 34)
                    button.addToView(commonView)
                    button.clickEvent.addAction { [weak self, weak button] _ in
                        if let self = self, let text = button?.title(for: .normal) {
                            self.textField.text = text
                        }
                    }
                    return button
                })
            }
        }

        init() {
            super.init(style: .default, reuseIdentifier: nil)
            
            backgroundColor = .clear
            
            textField.font = .systemFont(ofSize: 24)
            textField.backgroundColor = .white
            textField.textColor = .black
            textField.textAlignment = .center
            textField.layer.cornerRadius = 25
            textField.addToView(self.contentView, autoresizing: .flexibleWidth)
            textField.frame = CGRect(x: 20, y: 20, width: frame.width - 40, height: 50)
            
            commonView.frame = CGRect(x: 20, y: textField.frame.maxY + 10, width: frame.width - 40, height: 0)
            commonView.addToView(self.contentView, autoresizing: .flexibleWidth)
            
            selectionStyle = .none
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            var buttonLines = [(buttons: [UIButton], width: CGFloat)]()

            var buttons = [UIButton]()
            var lineWidth: CGFloat = 0
            commonButtons.forEach { (button) in
                if lineWidth + button.frame.width + 6 > commonView.frame.width {
                    buttonLines.append((buttons: buttons, width: lineWidth))
                    buttons.removeAll()
                    lineWidth = 0
                }
                buttons.append(button)
                lineWidth += button.frame.width + 6
            }
            buttonLines.append((buttons: buttons, width: lineWidth))

            var origin = CGPoint.zero
            for (buttons, width) in buttonLines {
                origin.x = (commonView.frame.width - width) * 0.5
                for button in buttons {
                    button.frame.origin = origin
                    origin.x += button.frame.width + 6
                }
                origin.y += 40
            }
            commonView.frame.size.height = origin.y
        }

        override func sizeThatFits(_ size: CGSize) -> CGSize {
            var rect = CGRect(x: 20, y: textField.frame.maxY + 10, width: 0, height: 32)
            commonButtons.forEach { button in
                rect.size.width = button.frame.width
                if rect.maxX > size.width - 40 {
                    rect.origin.x = 20
                    rect.origin.y += 40
                }
                rect.origin.x += rect.width + 6
            }
            return CGSize(width: size.width, height: rect.maxY + 20)
        }
    }
    
    let titleLabel = UILabel()
    let tableView = UITableView()

    var cells = [UITableViewCell]() {
        didSet {
            tableView.reloadData()
        }
    }
        
    let submitButton = UIButton()
    
    var date = Date() {
        didSet {
            let dateString = date.formattedDate(style: .long, year: true, month: true, day: true)
            title = dateString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(tap)
        
        titleLabel.font = .systemFont(ofSize: 30)
        titleLabel.textColor = .white
        titleLabel.frame = CGRect(x: 0, y: 10, width: view.frame.width, height: 40)
        titleLabel.textAlignment = .center
        titleLabel.addToView(view, autoresizing: .flexibleWidth)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addToView(view, autoresizing: .flexibleSize)
        tableView.contentInset.bottom = 44 + 50 + 10
        tableView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 50)
        tableView.alwaysBounceVertical = false
        
        submitButton.titleLabel?.font = .systemFont(ofSize: 24)
        submitButton.setBorder(color: .white, width: 1.0)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 25
        submitButton.setTitle("新增", for: .normal)
        submitButton.addToView(view)
        submitButton.clickEvent.addAction { [weak self] _ in
            self?.submitClick()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cells[indexPath.row].sizeThatFits(width: tableView.frame.width).height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        submitButton.frame = CGRect(x: 20, y: view.frame.height - view.safeAreaInsets.bottom - 44 - 60, width: view.frame.width - 40, height: 50)
    }
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    func submit(completion: ()->Void) {
        completion()
    }
    
    private func submitClick() {
        submit {
            navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
//        var result = JSONDictionary()
//        fieldViews.forEach { fieldView in
//            let stringValue = fieldView.value
//            if fieldView.field.valueType == .number {
//                result[fieldView.field.key] = Double(stringValue) ?? 0.0
//            } else {
//                result[fieldView.field.key] = stringValue
//            }
//        }
//
//        var updateDiary = JSONDictionary()
//
//        if matter.multi {
//            var results = DiaryModel.share.getDiary(at: date)[matter.key] as? [JSONDictionary] ?? []
//            results.append(result)
//            updateDiary[matter.key] = results
//        } else {
//            updateDiary[matter.key] = result
//        }
//        DiaryModel.share.updateDiary(updateDiary, at: date)
        
//        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
