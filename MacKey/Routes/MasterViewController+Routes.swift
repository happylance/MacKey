//
//  MasterViewController+Routes.swift
//  MacKey
//
//  Created by Liu Liang on 21/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import ReSwiftRouter

let hostDetaisViewRoute: RouteElementIdentifier = "HostDetails"
let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let hostDetailsStoryboard = UIStoryboard(name: "HostDetails", bundle: nil)

let mainViewControllerIdentifier = "MainViewController"
let hostDetailsControllerIdentifier = "HostDetailsViewController"
let hostDetailsNavigationControllerIdentifier = "HostDetailsNavigationController"


extension MasterViewController : Routable {
    public func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
        if routeElementIdentifier == hostDetaisViewRoute {
            // 1.) Perform the transition
            let hostDetaisViewController = hostDetailsStoryboard
                .instantiateViewController(withIdentifier: hostDetailsControllerIdentifier)
            
            let navController = UINavigationController(rootViewController: hostDetaisViewController)
            let isForNewHost = (store.state.hostsState.editingHostAlias == nil)
            navController.navigationBar.topItem?.title = isForNewHost ? "New host" : "Edit host"
            
            // 2.) Call the `completionHandler` once the transition is complete
            present(navController, animated: animated,
                    completion: completionHandler)
            
            // 3.) Return the Routable for the presented segment. For convenience
            // this will often be the UIViewController itself.
            return hostDetaisViewController as! Routable
        }
        fatalError("Router could not proceed.")
    }
    
    public func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {
        if routeElementIdentifier == hostDetaisViewRoute {
            dismiss(animated: animated, completion: completionHandler)
        }
    }
}

extension HostDetailsViewController: Routable {}
