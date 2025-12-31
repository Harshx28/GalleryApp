//
//  UIApplication+Extension.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import Foundation
import UIKit

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
    
    func setLogin() {
        if let loginNavigation = UIStoryboard.auth.instantiateViewController(withIdentifier: "NavLogin") as? UINavigationController {
            self.setRootController(for: loginNavigation)
        }
    }
    
    func setHome() {
        if let HomeNavigation = UIStoryboard.home.instantiateViewController(withIdentifier: "NavHome") as? UINavigationController {
            self.setRootController(for: HomeNavigation)
        }
    }
    
    func manageLogin() {
        if UserDefaultsConfig.isAuthorization {
            self.setHome()
        } else {
            self.setLogin()
        }
    }
    
    private func setRootController(for rootController: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            // Set the new rootViewController of the window.
            
            window.rootViewController = rootController
            window.makeKeyAndVisible()
            
            // A mask of options indicating how you want to perform the animations.
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            
            // The duration of the transition animation, measured in seconds.
            let duration: TimeInterval = 0.3
            
            // Creates a transition animation.
            // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: { completed in
                // Do something on completion here
            })
        }
    }
    
}
