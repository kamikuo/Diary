//
//  DiaryViewController.swift
//  Diary
//
//  Created by kamikuo on 2020/10/15.
//

import Foundation
import UIKit

class DiaryViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    private class NoteStatsItem : StatsItem {
        
        var editBarView = UIView()
        var editDoneButton = UIButton()
        var editMode = false {
            didSet {
                if editMode {
                    textView.isScrollEnabled = true
                    textView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height - editBarView.frame.height)
                    editBarView.isHidden = false
                } else {
                    textView.isScrollEnabled = false
                    textView.frame = contentView.bounds
                    editBarView.isHidden = true
                }
            }
        }
        
        let textView = UITextView(frame: .zero)
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textView.backgroundColor = .clear
            textView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
            textView.isScrollEnabled = false
            textView.font = .systemFont(ofSize: 17)
            textView.textColor = UIColor(named: "StatsTitleColor")
            textView.addToView(contentView, autoresizing: .flexibleSize)
            
            editBarView.frame = CGRect(x: 0, y: contentView.frame.height - 44, width: contentView.frame.width, height: 44)
            editBarView.isHidden = true
            editBarView.addToView(contentView, autoresizing: [.flexibleTopMargin, .flexibleWidth])
            
            let topLine = UIView(frame: CGRect(x: 12, y: 0, width: editBarView.frame.width - 24, height: 0.5))
            topLine.backgroundColor = UIColor(named: "StatsTextColor")?.withAlphaComponent(0.6)
            topLine.addToView(editBarView, autoresizing: .flexibleWidth)
            
            editDoneButton.setTitle("完成", for: .normal)
            editDoneButton.setTitleColor(UIColor(named: "StatsTitleColor"), for: .normal)
            editDoneButton.titleLabel?.font = .systemFont(ofSize: 17)
            let doneWidth = editDoneButton.sizeThatFits().width + 12
            editDoneButton.frame = CGRect(x: editBarView.frame.width - doneWidth - 8, y: 0, width: doneWidth, height: 40)
            editDoneButton.clickEvent.addAction { [weak self] _ in
                self?.textView.resignFirstResponder()
            }
            editDoneButton.addToView(editBarView, autoresizing: .flexibleLeftMargin)
            
            let bottomLine = UIView(frame: CGRect(x: 12, y: contentView.frame.height - 0.5, width: contentView.frame.width - 24, height: 0.5))
            bottomLine.backgroundColor = UIColor(named: "StatsTextColor")?.withAlphaComponent(0.3)
            bottomLine.addToView(contentView, autoresizing: [.flexibleWidth, .flexibleTopMargin])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var diary: JSONDictionary {
            didSet {
                textView.text = diary["note"] as? String
            }
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            return CGSize(width: size.width, height: max(160, textView.sizeThatFits(width: size.width).height + 36))
        }
    }
    
    private class AddCell : UITableViewCell {
        
        let addButton = UIButton()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            
            addButton.setTitle("新增", for: .normal)
            addButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
            addButton.setTitleColor(UIColor(named: "StatsColor"), for: .normal)
            addButton.backgroundColor = UIColor(named: "StatsTextColor")?.withAlphaComponent(0.5)
            addButton.layer.cornerRadius = 15
            let addWidth = addButton.sizeThatFits().width + 24
            addButton.frame.size = CGSize(width: addWidth, height: 30)
            addButton.addToView(contentView, autoresizing: .flexibleAlignmentCenter)
            
            selectionStyle = .none
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    var date: Date {
        didSet {
            reloadData()
        }
    }
    
    let monthLabel = UILabel()
    let dayLabel = UILabel()
    let weekLabel = UILabel()

    let diaryTableView = UITableView()
    
    
    private var diary: JSONDictionary = [:] {
        didSet {
            var mattersChanged = false
            
            Matter.allMatters.forEach { matter in
                if matter == .note || matter.isExist(in: diary) {
                    if matterCells[matter.key] == nil {
                        mattersChanged = true
                        matterCells[matter.key] = (matter.statsItemClass as! StatsItem.Type).init()
                    }
                    matterCells[matter.key]?.diary = diary
                } else {
                    if matterCells[matter.key] != nil {
                        mattersChanged = true
                        matterCells[matter.key] = nil
                    }
                }
            }
            
            if mattersChanged {
                hasMatters = Matter.allMatters.filter({ matterCells[$0.key] != nil })
            }
        }
    }
    
    private var hasMatters: [Matter] = [.note] {
        didSet {
            diaryTableView.reloadData()
        }
    }
    
    private var matterCells: [String: StatsItem] = [
        Matter.note.key: NoteStatsItem()
    ]
    private var noteCell: NoteStatsItem {
        return matterCells[Matter.note.key] as! NoteStatsItem
    }
    
    private var addCell = AddCell()
    
    private var diaryUpdateNotificationObject: NSObjectProtocol?
    
    init(date: Date) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "StatsColor")
        
        monthLabel.textColor = UIColor(named: "StatsTitleColor")
        monthLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        monthLabel.textAlignment = .center
        monthLabel.addToView(view, autoresizing: .flexibleAlignmentHoritontalCenter)
        monthLabel.frame = CGRect(x: view.frame.width * 0.5 - 100, y: 15, width: 200, height: 32)
        monthLabel.text = date.formattedDate(style: .long, year: true, month: true)
        
        dayLabel.textColor = UIColor(named: "StatsTitleColor")
        dayLabel.font = UIFont(name: "AvenirNext-Regular", size: 30)
        dayLabel.textAlignment = .center
        dayLabel.addToView(view, autoresizing: .flexibleAlignmentHoritontalCenter)
        dayLabel.frame = CGRect(x: view.frame.width * 0.5 - 100, y: 47, width: 200, height: 40)
        dayLabel.text = String(Calendar.current.component(.day, from: date))
        
        weekLabel.textColor = UIColor(named: "StatsTextColor")
        weekLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        weekLabel.textAlignment = .center
        weekLabel.addToView(view, autoresizing: .flexibleAlignmentHoritontalCenter)
        weekLabel.frame = CGRect(x: view.frame.width * 0.5 - 100, y: 87, width: 200, height: 20)
        let weekday = Calendar.current.component(.weekday, from: date) - 1
        weekLabel.text = Date(timeIntervalSince1970: 86400 * TimeInterval(3 + weekday)).formattedDate(localizedTemplate: "EE")
        
        diaryTableView.backgroundColor = UIColor(named: "StatsColor")
        diaryTableView.addToView(view, autoresizing: .flexibleSize)
        diaryTableView.frame = CGRect(x: 0, y: 122, width: view.frame.width, height: view.frame.height - 112)
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        diaryTableView.separatorStyle = .none
        diaryUpdateNotificationObject = NotificationCenter.default.addObserver(forName: DiaryModel.updateNotificationName, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self, let date = notification.userInfo?["date"] as? Date, let diary = notification.userInfo?["diary"] as? JSONDictionary else { return }
            if Calendar.current.isDate(date, inSameDayAs: self.date) {
                self.diary = diary
            }
        }
        
        let topLine = UIView(frame: CGRect(x: 12, y: 122, width: view.frame.width - 24, height: 0.5))
        topLine.backgroundColor = UIColor(named: "StatsTextColor")?.withAlphaComponent(0.6)
        topLine.addToView(view, autoresizing: .flexibleWidth)
        
        noteCell.textView.delegate = self
        
        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangeFrame(noti:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangeFrame(noti:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        addCell.addButton.clickEvent.addAction { [weak self] _ in
            guard let self = self else { return }
            let adder = AdderViewController()
            adder.date = self.date
            let nvc = AdderNavigationController(rootViewController: adder)
            nvc.modalPresentationStyle = .overCurrentContext
            self.view.window?.topViewController?.present(nvc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        noteCell.textView.resignFirstResponder()
    }
    
    private func reloadData() {
        diary = DiaryModel.share.getDiary(at: date)
    }
    
    @objc private func keyboardChangeFrame(noti: NSNotification) {
        if let info = noti.userInfo,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            
            let viewFrame = view.convert(view.bounds, to: view.window)

            let keyboardHeight: CGFloat
            if keyboardFrame.size.height == 0 || keyboardFrame.maxY < viewFrame.height {
                keyboardHeight = 0
            } else {
                keyboardHeight = viewFrame.maxY - keyboardFrame.minY
            }
            
            UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: UIView.KeyframeAnimationOptions.RawValue(curve<<16)), animations: {
                self.diaryTableView.contentInset.bottom = keyboardHeight
                self.diaryTableView.beginUpdates()
                self.diaryTableView.endUpdates()
            }, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 56
        }
        
        if noteCell.editMode {
            return tableView.frame.height - tableView.contentInset.bottom
        }
        return matterCells[hasMatters[indexPath.row].key]!.sizeThatFits(width: tableView.frame.width).height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        return hasMatters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return addCell
        }
        return matterCells[hasMatters[indexPath.row].key]!
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        noteCell.editMode = true
        diaryTableView.isScrollEnabled = false
        diaryTableView.contentOffset.y = 0
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        let content = textView.text ?? ""
        DiaryModel.share.updateDiary(["note": content], at: date)
        noteCell.editMode = false
        diaryTableView.isScrollEnabled = true
        return true
    }
}
