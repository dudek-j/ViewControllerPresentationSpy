// ViewControllerPresentationSpy by Jon Reid, https://qualitycoding.org
// Copyright 2015 Jonathan M. Reid. https://github.com/jonreid/ViewControllerPresentationSpy/blob/main/LICENSE.txt
// SPDX-License-Identifier: MIT

import UIKit

let presentingViewControllerKey = "presentingViewControllerKey"
let animatedKey = "animatedKey"
let completionKey = "completionKey"

extension Notification.Name {
    static let viewControllerPresented = Notification.Name("viewControllerPresented")
    static let viewControllerDismissed = Notification.Name("viewControllerDismissed")
    static let alertControllerPresented = Notification.Name("alertControllerPresented")
}

extension UIViewController {
    static var presentSwizzleCount = 0

    static func swizzleCapturePresent() {
        swizzlePresent()
        presentSwizzleCount += 1
    }

    static func restoreCaptureSwizzle() {
        presentSwizzleCount -= 1
        swizzlePresent()
    }

    private static func swizzlePresent() {
        guard presentSwizzleCount == 0 else { return }

        replaceInstanceMethod(
            original: #selector(present(_:animated:completion:)),
            swizzled: #selector(mock_presentViewControllerCapturingIt(viewControllerToPresent:animated:completion:))
        )
    }

    static func swizzleCaptureDismiss() {
        replaceInstanceMethod(
            original: #selector(dismiss(animated:completion:)),
            swizzled: #selector(mock_dismissViewController(animated:completion:))
        )
    }

    @objc func mock_presentViewControllerCapturingIt(
        viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?
    ) {
        viewControllerToPresent.loadViewIfNeeded()
        let closureContainer = ClosureContainer(closure: completion)


        let notification = viewControllerToPresent.isKind(of: UIAlertController.self) ?
            Notification.Name.alertControllerPresented :
            Notification.Name.viewControllerPresented

        NotificationCenter.default.post(
            name: notification,
            object: viewControllerToPresent,
            userInfo: [
                presentingViewControllerKey: self,
                animatedKey: flag,
                completionKey: closureContainer,
            ]
        )
    }

    @objc func mock_dismissViewController(animated flag: Bool, completion: (() -> Void)?) {
        let closureContainer = ClosureContainer(closure: completion)
        NotificationCenter.default.post(
            name: Notification.Name.viewControllerDismissed,
            object: self,
            userInfo: [
                animatedKey: flag,
                completionKey: closureContainer,
            ]
        )
    }
}
