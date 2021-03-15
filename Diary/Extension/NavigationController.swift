//
//  NavigationController.swift
//  Diary
//
//  Created by kamikuo on 2020/10/18.
//

import Foundation
import UIKit


class NavigationController : UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    private class PopInteractor : UIPercentDrivenInteractiveTransition {
    }

    private class PushAnimator : NSObject, UIViewControllerAnimatedTransitioning {
        var push: Bool = false
        var animating: Bool = false

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.24
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromVC = transitionContext.viewController(forKey: .from),
                let fromView = fromVC.view,
                let toVC = transitionContext.viewController(forKey: .to),
                let toView = toVC.view else { return }
            animating = true

            //=== get container view ===
            let containerView = transitionContext.containerView
            let screenSize = containerView.bounds.size

            //=== add to/from view ===
            let toViewFrame = transitionContext.finalFrame(for: toVC)
            var toViewStartFrame = toViewFrame
            let toViewEndFrame = toViewFrame

            let fromViewFrame = transitionContext.initialFrame(for: fromVC)
            let fromViewStartFrame = fromViewFrame
            var fromViewEndFrame = fromViewFrame

            if push {
                containerView.addSubview(toView)

                toViewStartFrame.origin.x = screenSize.width
                fromViewEndFrame.origin.x = -screenSize.width * 0.5
            } else {
                containerView.insertSubview(toView, belowSubview: fromView)

                fromViewEndFrame.origin.x = screenSize.width
                toViewStartFrame.origin.x = -screenSize.width * 0.5
            }

            fromView.alpha = 1
            fromView.frame = fromViewStartFrame
            
            toView.alpha = 0
            toView.frame = toViewStartFrame
            
            UIView.animate(withDuration: 0.24, delay: 0, options: [.overrideInheritedDuration, .overrideInheritedCurve, (transitionContext.isInteractive ? .curveLinear : .curveEaseOut)]) {
                fromView.frame = fromViewEndFrame
                toView.frame = toViewEndFrame
                fromView.alpha = 0
                toView.alpha = 1
            } completion: { (_) in
                fromView.frame = fromViewFrame
                toView.frame = toViewFrame
                fromView.alpha = 1
                toView.alpha = 1

                if transitionContext.transitionWasCancelled {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
                self.animating = false
            }
        }
    }
    
    private var popInteractor: PopInteractor?
    private var interactorPanGestureRecognizer = UIPanGestureRecognizer()
    private var interactorPanPopFail = false
    private var pushPopAnimator = PushAnimator()
    open var isInteractivePopEnable = true

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "MainColor")
        
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor(named: "MainColor")
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = .white
        
        delegate = self

        interactorPanGestureRecognizer.addTarget(self, action: #selector(interactorPan(pan:)))
        interactorPanGestureRecognizer.delegate = self
        view.addGestureRecognizer(interactorPanGestureRecognizer)
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UISlider {
            return false
        }
        return true
    }
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scrollView = otherGestureRecognizer.view as? UIScrollView {
            if scrollView.bounces == false && scrollView.contentSize.width > scrollView.frame.width && scrollView.contentOffset.x <= scrollView.contentInset.left {
                return true
            }
        }
        return false
    }
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactorPanGestureRecognizer {
            guard isInteractivePopEnable else { return false }
            let trans = interactorPanGestureRecognizer.translation(in: interactorPanGestureRecognizer.view)
            return !(value(forKey: "_isTransitioning") as? Bool ?? false) &&
                ((trans.x > 0 && trans.x > abs(trans.y)) || (trans.x < abs(trans.y)))
        }
        return true
    }

    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        pushPopAnimator.push = operation == .push
        return pushPopAnimator
    }

    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return popInteractor
    }

    @objc private func interactorPan(pan: UIPanGestureRecognizer) {
        if let popInteractor = popInteractor {
            let trans = pan.translation(in: view)
            let progress = min(max(trans.x / view.frame.width, 0), 1)
            if pan.state == .changed {
                popInteractor.update(progress)
            } else {
                if pan.state == .ended {
                    let velocity = pan.velocity(in: view)
                    if progress > 0.1 && (progress > 0 && velocity.x >= 0) {
                        popInteractor.completionSpeed = 0.05 + 0.4 * (1 - progress) * 1.5
                        popInteractor.finish()
                        self.popInteractor = nil
                        return
                    }
                }
                //cancel progress
                popInteractor.completionSpeed = 0.05 + 0.25 * (progress * 1.5)
                popInteractor.cancel()
                self.popInteractor = nil
            }
            return
        }

        if pan.state == .began || pan.state == .changed {
            if !interactorPanPopFail && isInteractivePopEnable {
                let trans = pan.translation(in: view)
                if trans.x == 0 && trans.y == 0 {
                    return
                }
                let velocity = pan.velocity(in: view)
                if velocity.x < 87 || abs(velocity.x) <= abs(velocity.y) || pushPopAnimator.animating || viewControllers.count == 0 || viewControllers[0] == topViewController {
                    interactorPanPopFail = true
                } else {
                    popInteractor = PopInteractor()
                    pan.setTranslation(.zero, in: view)
                    popViewController(animated: true)
                    popInteractor?.update(0.01)
                }
            }
        } else {
            interactorPanPopFail = false
        }
    }
}
