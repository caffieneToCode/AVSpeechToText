//
//  UIViewController+.swift
//  SpeechToText
//
//  Created by Ashish on 29/05/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import UIKit

extension UIViewController {

    func bindKeypad(to constraint: NSLayoutConstraint) {
        let defaultValue = constraint.constant
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self, weak constraint] notification in
            guard let info = notification.userInfo else { return }
            guard let height = (info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size.height else { return }
            guard constraint?.constant != height else { return }
            constraint?.constant = height
            self?.view.layoutIfNeeded()

        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self, weak constraint] _ in
            guard constraint?.constant != 0 else { return }
            constraint?.constant = defaultValue
            self?.view.layoutIfNeeded()
        }
    }
}
