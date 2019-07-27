//
//  ViewController.swift
//  InteractiveModal
//
//  Created by Robert Chen on 1/6/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let interactor = CardPresentationInteractor()


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "present", style: .plain, target: self, action: #selector(push))
        view.backgroundColor = .blue
        definesPresentationContext = true
    }

    @objc func push() {
        let destinationViewController = ModalViewController()
        destinationViewController.transitioningDelegate = self
        destinationViewController.interactor = interactor
//        destinationViewController.modalPresentationStyle = .overFullScreen
        present(destinationViewController, animated: true, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardDismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }


    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
}


final class PresentMenuAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        let containerView = transitionContext.containerView
        // overlay the modal on top of the ViewController
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        // stage the modal VC one screen below
        toVC.view.center.y += UIScreen.main.bounds.height
        // the fromVC (ViewController) is going away.
        // give the illusion of it still being on the screen.
        guard let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else { return }
        containerView.insertSubview(snapshot, belowSubview: toVC.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
            animations: {
                // center the modal on the screen
                toVC.view.center.y = UIScreen.main.bounds.height / 2
        }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
