//
//  AdderNavigationController.swift
//  Diary
//
//  Created by kamikuo on 2020/10/12.
//

import Foundation
import UIKit

class AdderNavigationController : NavigationController, UIViewControllerTransitioningDelegate {
    
    let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        barAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        barAppearance.buttonAppearance = barButtonAppearance

        navigationBar.standardAppearance = barAppearance
        navigationBar.tintColor = .white
        navigationBar.isTranslucent = false
        
        transitioningDelegate = self
        
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        
        closeButton.setImage(UIImage(named: "Add")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = UIColor(named: "MainColor")
        closeButton.transform = CGAffineTransform(rotationAngle: .pi / 4)
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 20
        closeButton.addToView(view)

        closeButton.clickEvent.addAction { [weak self] _ in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        closeButton.center = CGPoint(x: view.frame.width * 0.5, y: view.frame.height - view.safeAreaInsets.bottom - 20)
    }

    private class TransitionAnimator : NSObject, UIViewControllerAnimatedTransitioning {
        let presenting: Bool
        
        init(presenting: Bool) {
            self.presenting = presenting
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return presenting ? 0.35 : 0.01
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromVC = transitionContext.viewController(forKey: .from),
                  let toVC = transitionContext.viewController(forKey: .to),
                  let fromView = fromVC.view,
                  let toView = toVC.view
                else { return }
            
            let containerView = transitionContext.containerView
            
            if toView.superview == nil {
                containerView.addSubview(toView)
                toView.frame = transitionContext.finalFrame(for: toVC)
            }
            containerView.bringSubviewToFront(presenting ? toView : fromView)
            
            let nvc = (presenting ? toVC : fromVC) as! AdderNavigationController
            
            if presenting {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    nvc.view.backgroundColor = UIColor(white: 0, alpha: 0.85)
                }, completion: { _ in
                })
                
                nvc.topViewController?.view.transform = CGAffineTransform(translationX: 0, y: nvc.view.frame.height)
                nvc.setNavigationBarHidden(true, animated: false)
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.78, initialSpringVelocity: 0, options: []) {
                    nvc.setNavigationBarHidden(false, animated: true)
                    nvc.topViewController?.view.transform = .identity
                } completion: { _ in
                    transitionContext.completeTransition(true)
                }
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    nvc.setNavigationBarHidden(true, animated: true)
                    nvc.view.backgroundColor = UIColor(white: 0, alpha: 0)
                    nvc.topViewController?.view.bounds.origin.y = nvc.view.frame.height * 0.7
                    nvc.topViewController?.view.alpha = 0
                    nvc.closeButton.center.y = nvc.view.frame.height + 40
                }, completion: { _ in
                    transitionContext.completeTransition(true)
                })
            }
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimator(presenting: true)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimator(presenting: false)
    }
}
