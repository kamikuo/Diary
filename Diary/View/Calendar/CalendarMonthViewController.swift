//
//  MonthPageViewController.swift
//  Diary
//
//  Created by kamikuo on 2020/11/8.
//

import Foundation
import UIKit

protocol CalendarMonthViewControllerDelegate : class {
    func monthViewController(_ monthViewController: CalendarMonthViewController, didClickOfDate date: Date)
    func monthViewController(_ monthViewController: CalendarMonthViewController, didScrollFromMatter fromMatter: Matter, previousMatter: Matter, nextMatter: Matter, position: CGFloat)
    func monthViewControllerDidChangeMatter(_ monthViewController: CalendarMonthViewController)
}

class CalendarMonthViewController : UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate, CalendarDaysViewControllerDelegate {
    
    var date: Date {
        didSet {
            (pageViewController.viewControllers?.first as? CalendarDaysViewController)?.date = date
            monthLabel.text = date.formattedDate(style: .long, year: true, month: true)
        }
    }
    
    var matter: Matter {
        didSet {
            if (pageViewController.viewControllers?.first as? CalendarDaysViewController)?.matter != matter {
                pageViewController.setViewControllers([createCalendarDaysViewController(matter: matter)], direction: .forward, animated: false, completion: nil)
            }
            delegate?.monthViewControllerDidChangeMatter(self)
        }
    }
    
    weak var delegate: CalendarMonthViewControllerDelegate?
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
    let monthLabel = UILabel()
    
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
        
        view.clipsToBounds = false
        view.backgroundColor = .clear
        
        monthLabel.textColor = UIColor(named: "DayColor")
        monthLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        monthLabel.addToView(view, autoresizing: [.flexibleTopMargin, .flexibleBottomMargin, .flexibleAlignmentHoritontalCenter])
        monthLabel.frame = CGRect(x: view.frame.width * 0.5 - 100, y: view.frame.height * 0.12, width: 200, height: 32)

        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.backgroundColor = UIColor(named: "DayColor")
        pageViewController.view.layer.cornerRadius = 15
        pageViewController.view.setShadow(color: .black, radius: 45, opacity: 0.1, offset: .zero)
        pageViewController.view.clipsToBounds = false
        pageViewController.scrollView?.delegate = self

        addChild(pageViewController)
        pageViewController.view.frame = CGRect(x: 20, y: view.frame.height * 0.24, width: view.frame.width - 40, height: view.frame.height * 0.8)
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin, .flexibleHeight]
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.setViewControllers([createCalendarDaysViewController(matter: matter)], direction: .forward, animated: false, completion: nil)
        let date = self.date
        self.date = date
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        monthLabel.bounds.size.width = monthLabel.sizeThatFits().width
        if let scrollView = pageViewController.scrollView {
            scrollViewDidScroll(scrollView)
        }
    }

    private func createCalendarDaysViewController(matter: Matter) -> CalendarDaysViewController {
        let vc = CalendarDaysViewController(date: date, matter: matter)
        vc.delegate = self
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let dvc = pendingViewControllers.first as? CalendarDaysViewController {
            dvc.date = date
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let dvc = viewController as? CalendarDaysViewController {
            let previousMatter: Matter
            if let idx = Matter.allMatters.firstIndex(of: dvc.matter), idx > 0 {
                previousMatter = Matter.allMatters[idx - 1]
            } else {
                previousMatter = Matter.allMatters.last!
            }
            return createCalendarDaysViewController(matter: previousMatter)
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let dvc = viewController as? CalendarDaysViewController {
            let nextMatter: Matter
            if let idx = Matter.allMatters.firstIndex(of: dvc.matter), idx < Matter.allMatters.count - 1 {
                nextMatter = Matter.allMatters[idx + 1]
            } else {
                nextMatter = Matter.allMatters.first!
            }
            return createCalendarDaysViewController(matter: nextMatter)
        }
        return nil
    }
    
    func daysViewController(_ daysViewController: CalendarDaysViewController, didClickOfDate date: Date) {
        delegate?.monthViewController(self, didClickOfDate: date)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let dvc = pageViewController.viewControllers?.first as? CalendarDaysViewController, dvc.view.frame.size == pageViewController.view.frame.size else { return }
        matter = dvc.matter
        
        var midMatterIdx = Matter.allMatters.firstIndex(of: matter) ?? 0
        let mvcY = dvc.view.convert(.zero, to: scrollView).y
        if mvcY < 10 {
            midMatterIdx = midMatterIdx < Matter.allMatters.count - 1 ? midMatterIdx + 1 : 0
        } else if mvcY > scrollView.contentSize.height * 0.5 {
            midMatterIdx = midMatterIdx > 0 ? midMatterIdx - 1 : Matter.allMatters.count - 1
        }
        
        delegate?.monthViewController(self,
                                      didScrollFromMatter: Matter.allMatters[midMatterIdx],
                                      previousMatter: midMatterIdx > 0 ? Matter.allMatters[midMatterIdx - 1] : Matter.allMatters.last!,
                                      nextMatter: midMatterIdx < Matter.allMatters.count - 1 ? Matter.allMatters[midMatterIdx + 1] :
                                        Matter.allMatters.first!,
                                      position: scrollView.contentOffset.y / scrollView.contentSize.height)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
