//
//  MonthItem.swift
//  Diary
//
//  Created by kamikuo on 2020/10/3.
//

import Foundation
import UIKit

protocol CalendarDaysViewControllerDelegate : class {
    func daysViewController(_ daysViewController: CalendarDaysViewController, didClickOfDate date: Date)
}

class CalendarDaysViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var date: Date {
        didSet {
            if !Calendar.current.isDate(date, equalTo: oldValue, toGranularity: .year) || !Calendar.current.isDate(date, equalTo: oldValue, toGranularity: .month) {
                reloadMonth()
            }
        }
    }
    
    var matter: Matter {
        didSet {
            if matter.key != oldValue.key {
                updateAllDayItems()
            }
        }
    }
    
    weak var delegate: CalendarDaysViewControllerDelegate? = nil

    private var year = 0
    private var month = 0
    private var startWeekday = 0
    private var numberOfDays = 0
    
    private var diaries: [Date: JSONDictionary] = [:]
    
    private var diaryUpdateNotificationObject: NSObjectProtocol?
    
    let weekdaysView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
    let weekdayLabels = (0..<7).map{ _ in UILabel() }
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
    init(date: Date, matter: Matter) {
        self.date = date
        self.matter = matter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
            layout.sectionInset = UIEdgeInsets(top: 18 + 40, left: 18, bottom: 18, right: 18)
        }
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isScrollEnabled = false
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emptyItem")
        collectionView.register(CalendarDayItem.self, forCellWithReuseIdentifier: "dayItem")
        collectionView.dataSource = self //dataSource
        collectionView.delegate = self
        collectionView.addToView(view, autoresizing: .flexibleSize)
        
        diaryUpdateNotificationObject = NotificationCenter.default.addObserver(forName: DiaryModel.updateNotificationName, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self, let date = notification.userInfo?["date"] as? Date, let diary = notification.userInfo?["diary"] as? JSONDictionary else { return }
            let day = Calendar.current.dateComponents([.year, .month, .day], from: date)
            if day.year == self.year, day.month == self.month {
                self.diaries[Calendar.current.startOfDay(for: date)] = diary
                self.collectionView.reloadItems(at: [IndexPath(item: self.startWeekday + day.day! - 1, section: 0)])
            }
        }

        let weekdayWidth = weekdaysView.frame.width / 7
        for (idx, label) in weekdayLabels.enumerated() {
            label.textColor = UIColor(named: "DayTextColor")?.withAlphaComponent(0.6)
            label.font = UIFont(name: "AvenirNext-Regular", size: 14)
            label.textAlignment = .center
            label.text = Date(timeIntervalSince1970: 86400 * TimeInterval(3 + idx)).formattedDate(localizedTemplate: "EEEEEE")
            
            let size = label.sizeThatFits()
            label.frame = CGRect(x: CGFloat(idx) * weekdayWidth + (weekdayWidth - size.width) * 0.5, y: (weekdaysView.frame.height - size.height) * 0.5, width: size.width, height: size.height)
            label.autoresizingMask = .flexibleAlignmentCenter
            weekdaysView.addSubview(label)
        }
        weekdaysView.frame = CGRect(x: 18, y: 14, width: view.frame.width - 36, height: 30)
        weekdaysView.autoresizingMask = .flexibleWidth
        view.addSubview(weekdaysView)
  
        reloadMonth()
    }
    
    private func reloadMonth() {
        let monthDate = self.date.firstDayInMonth
        let day = Calendar.current.dateComponents([.year, .month], from: monthDate)
        year = day.year!
        month = day.month!
        
        startWeekday = Calendar.current.component(.weekday, from: monthDate) - 1
        numberOfDays = Calendar.current.range(of: .day, in: .month, for: monthDate)?.count ?? 0

        let firstDay = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))!
        let lastDay =  Calendar.current.date(from: DateComponents(year: year, month: month, day: numberOfDays))!

        diaries = DiaryModel.share.getDiaries(from: firstDay, to: lastDay)
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return startWeekday + numberOfDays
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < startWeekday {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "emptyItem", for: indexPath)
        }
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "dayItem", for: indexPath)
        if let cell = cell as? CalendarDayItem {
            updateDayItem(cell, day: indexPath.item - startWeekday + 1)
        }
        return cell
    }
    
    private func updateAllDayItems() {
        for i in 0..<numberOfDays {
            if let cell = collectionView.cellForItem(at: IndexPath(item: startWeekday + i, section: 0)) as? CalendarDayItem {
                updateDayItem(cell, day: cell.day)
            }
        }
    }
    
    private func updateDayItem(_ cell: CalendarDayItem, day: Int) {
        guard let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) else { return }
            
        var dayOption: CalendarDayItem.DayOption = []
        if Calendar.current.isDateInToday(date) {
            dayOption.insert(.today)
        }
        if Calendar.current.isDateInWeekend(date) {
            dayOption.insert(.weekend)
        }
        
        cell.day = day
        cell.dayOption = dayOption
        cell.matter = matter
        cell.diary = self.diaries[date] ?? [:]
    }
     
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = indexPath.item - startWeekday + 1
        if day > 0, let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) {
            delegate?.daysViewController(self, didClickOfDate: date)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: max(view.frame.width - 12 - 36, 0) / 7, height: max(view.frame.height - 10 - 36 - 40, 0) / 6)
    }
}
