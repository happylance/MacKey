//
//  MasterViewController+Routes.swift
//  MacKey
//
//  Created by Liu Liang on 21/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit

let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let hostDetailsStoryboard = UIStoryboard(name: "HostDetails", bundle: nil)

let mainViewControllerIdentifier = "MainViewController"
let hostDetailsControllerIdentifier = "HostDetailsViewController"
let hostDetailsNavigationControllerIdentifier = "HostDetailsNavigationController"


extension MasterViewController {
    public func showHostDetailsViewController(animated: Bool,
                                             completionHandler: (()->())? = nil)  {
        let hostDetailsViewController = hostDetailsStoryboard
            .instantiateViewController(withIdentifier: hostDetailsControllerIdentifier)
        
        let navController = UINavigationController(rootViewController: hostDetailsViewController)
        let isForNewHost = (store.observable.value.hostsState.editingHostAlias == nil)
        navController.navigationBar.topItem?.title = isForNewHost ? "New host" : "Edit host"
        
        present(navController, animated: animated,
                completion: completionHandler)
    }
}

