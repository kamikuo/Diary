//
//  CalendarView.swift
//  Diary
//
//  Created by kamikuo on 2020/10/7.
//

import Foundation
import UIKit

class CalendarViewController : UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate, CalendarMonthViewControllerDelegate, DiariesViewControllerDelegate {
    
    private class MatterCell : UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            selectionStyle = .none
            textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            textLabel?.textAlignment = .center
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            textLabel?.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        }
        
        var matter: Matter? {
            didSet {
                textLabel?.text = matter?.title
                textLabel?.textColor = matter?.color
                setNeedsLayout()
            }
        }
    }
    
    private(set) var matter = Matter.note

    let monthPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    let mattersScrollView = UIScrollView()
    let mattersLabel = [UILabel(), UILabel(), UILabel()]
    
    private let nextBgView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextBgView.alpha = 0
        nextBgView.addToView(view, autoresizing: .flexibleSize)
        
        addChild(monthPageViewController)
        monthPageViewController.view.frame = view.frame
        view.addSubview(monthPageViewController.view)
        monthPageViewController.didMove(toParent: self)
        monthPageViewController.view.clipsToBounds = false
        monthPageViewController.scrollView?.clipsToBounds = false
        
        monthPageViewController.delegate = self
        monthPageViewController.dataSource = self
        monthPageViewController.setViewControllers([createCalendarMonthViewController(date: Date(), matter: matter)], direction: .forward, animated: false, completion: nil)
        
        var matterWidth: CGFloat = 0
        Matter.allMatters.forEach { matter in
            matterWidth = max(matterWidth, NSAttributedString(string: matter.title, attributes: [.font: UIFont(name: "AvenirNext-DemiBold", size: 18)!]).boundingRect(with: .zero, options: [], context: nil).width)
        }
        
        mattersScrollView.frame.size = CGSize(width: matterWidth + 24, height: 32)
        mattersScrollView.isUserInteractionEnabled = false
        mattersScrollView.backgroundColor = UIColor(named: "DayColor")
        mattersScrollView.layer.cornerRadius = 16
        mattersScrollView.contentSize.height = 96
        mattersScrollView.addToView(view)
        
        for (idx, label) in mattersLabel.enumerated() {
            label.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            label.textAlignment = .center
            label.frame = CGRect(x: 0, y: CGFloat(idx) * 32, width: mattersScrollView.frame.width, height: 32)
            mattersScrollView.addSubview(label)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let viewHeight = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 60
        monthPageViewController.view.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: viewHeight * 0.78)

        mattersScrollView.frame = CGRect(x: (view.frame.width - mattersScrollView.frame.width) * 0.5, y: view.safeAreaInsets.top + viewHeight * 0.9 - 16, width: mattersScrollView.frame.width, height: 32)
    }
    
    private func createCalendarMonthViewController(date: Date, matter: Matter) -> CalendarMonthViewController {
        let vc = CalendarMonthViewController(date: date, matter: matter)
        vc.delegate = self
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let nextMVC = pendingViewControllers.first as? CalendarMonthViewController {
            nextMVC.matter = matter
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let mvc = viewController as? CalendarMonthViewController {
            return createCalendarMonthViewController(date: Calendar.current.date(byAdding: .month, value: -1, to: mvc.date)!, matter: matter)
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let mvc = viewController as? CalendarMonthViewController {
            return createCalendarMonthViewController(date: Calendar.current.date(byAdding: .month, value: 1, to: mvc.date)!, matter: matter)
        }
        return nil
    }

    func monthViewController(_ monthViewController: CalendarMonthViewController, didClickOfDate date: Date) {
        let vc = DiariesViewController()
        vc.date = date
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func monthViewControllerDidChangeMatter(_ monthViewController: CalendarMonthViewController) {
        matter = monthViewController.matter
    }
    
    func monthViewController(_ monthViewController: CalendarMonthViewController, didScrollFromMatter fromMatter: Matter, previousMatter: Matter, nextMatter: Matter, position: CGFloat) {

        let matters: [Matter] = [
            previousMatter,
            fromMatter,
            nextMatter
        ]

        for (matter, label) in zip(matters, mattersLabel) {
            label.text = matter.title
            label.textColor = matter.color
        }
        mattersScrollView.contentOffset = CGPoint(x: 0, y: position * mattersScrollView.contentSize.height)
        
        view.backgroundColor = matters[1].color
        
        let pageHeight: CGFloat = 1.0 / 3.0
        if position <= pageHeight {
            nextBgView.backgroundColor = matters[0].color
            nextBgView.alpha = 1.0 - position / pageHeight
        } else {
            nextBgView.backgroundColor = matters[2].color
            nextBgView.alpha = (position - pageHeight) / pageHeight
        }        
    }
    
    func diariesViewControllerDidChangeDate(_ diariesViewController: DiariesViewController) {
        let date = diariesViewController.date
        if let nowDate = (monthPageViewController.viewControllers?.first as? CalendarMonthViewController)?.date, !Calendar.current.isDate(date, inSameDayAs: nowDate) {
            monthPageViewController.setViewControllers([createCalendarMonthViewController(date: date, matter: matter)], direction: .forward, animated: false, completion: nil)
        }
    }
}
