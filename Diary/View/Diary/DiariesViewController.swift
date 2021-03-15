//
//  DiariesViewController.swift
//  Diary
//
//  Created by kamikuo on 2020/11/6.
//

import Foundation
import UIKit

protocol DiariesViewControllerDelegate : class {
//    func diariesViewController(_ diariesViewController: DiariesViewController, didScrollFromDate fromDate: Date, position: CGFloat)
    func diariesViewControllerDidChangeDate(_ diariesViewController: DiariesViewController)
}

class DiariesViewController : UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {
    
    var date: Date = Date() {
        didSet {
            if let currentDate = (pageViewController.viewControllers?.first as? DiaryViewController)?.date, !Calendar.current.isDate(currentDate, inSameDayAs: date) {
                pageViewController.setViewControllers([DiaryViewController(date: date)], direction: .forward, animated: false, completion: nil)
            }
            delegate?.diariesViewControllerDidChangeDate(self)
        }
    }
    
    weak var delegate: DiariesViewControllerDelegate?
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.scrollView?.delegate = self
        
        addChild(pageViewController)
        pageViewController.view.frame = view.bounds
        pageViewController.view.autoresizingMask = .flexibleSize
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        pageViewController.setViewControllers([DiaryViewController(date: date)], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? DiaryViewController {
            return DiaryViewController(date: Calendar.current.date(byAdding: .day, value: -1, to: vc.date)!)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? DiaryViewController {
            return DiaryViewController(date: Calendar.current.date(byAdding: .day, value: 1, to: vc.date)!)
        }
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let dvc = pageViewController.viewControllers?.first as? DiaryViewController, dvc.view.frame.size == pageViewController.view.frame.size else { return }
        date = dvc.date
        
//        var midDate = date
//
//        let mvcX = dvc.view.convert(.zero, to: scrollView).x
//        if mvcX < 10 {
//            midDate = Calendar.current.date(byAdding: .day, value: 1, to: midDate)!
//        } else if mvcX > scrollView.contentSize.width * 0.5 {
//            midDate = Calendar.current.date(byAdding: .day, value: -1, to: midDate)!
//        }
//        
//        delegate?.diariesViewController(self, didScrollFromDate: midDate, position: scrollView.contentOffset.x / scrollView.contentSize.width)
    }
}
