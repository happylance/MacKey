//
//  MasterViewController+Routes.swift
//  MacKey
//
//  Created by Liu Liang on 21/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import Localize_Swift

let helpStoryboard = UIStoryboard(name: "Help", bundle: nil)
let hostDetailsStoryboard = UIStoryboard(name: "HostDetails", bundle: nil)
let upgradeStoryboard = UIStoryboard(name: "Upgrade", bundle: nil)

let helpControllerIdentifier = "HelpViewController"
let hostDetailsControllerIdentifier = "HostDetailsViewController"
let upgradeControllerIdentifier = "UpgradeViewController"

extension MasterViewController {
    public func showHostDetailsViewController(animated: Bool, forNewHost:Bool) -> HostDetailsViewController?  {
        let hostDetailsViewController = hostDetailsStoryboard
            .instantiateViewController(withIdentifier: hostDetailsControllerIdentifier)
        
        let navController = UINavigationController(rootViewController: hostDetailsViewController)
        navController.navigationBar.topItem?.title = (forNewHost ? "New host" : "Edit host").localized()
        navController.navigationBar.accessibilityIdentifier = "Host Editor"
        
        present(navController, animated: animated, completion: nil)
        
        return hostDetailsViewController as? HostDetailsViewController
    }
    
    @discardableResult
    public func showHelpViewController(animated: Bool) -> UIViewController?  {
        let helpViewController = helpStoryboard
            .instantiateViewController(withIdentifier: helpControllerIdentifier)
        
        let navController = UINavigationController(rootViewController: helpViewController)
        navController.view.backgroundColor = UIColor.white
        
        present(navController, animated: animated, completion: nil)
        
        return helpViewController
    }
}

extension UIViewController {
    @discardableResult
    func showUpgradeViewController(animated: Bool, forProductType:ProductType) -> UpgradeViewController?  {
        guard let upgradeViewController = upgradeStoryboard
            .instantiateViewController(withIdentifier: upgradeControllerIdentifier) as? UpgradeViewController else {
                return nil
        }
        
        upgradeViewController.setProductType(forProductType)
        let navController = UINavigationController(rootViewController: upgradeViewController)
        present(navController, animated: animated, completion: nil)
        
        return upgradeViewController
    }
}

