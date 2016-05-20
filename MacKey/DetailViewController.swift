//
//  DetailViewController.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var macHost: MacHost? {
        didSet {
            TouchIDUtils.runTouchID { (result) in
                switch(result) {
                case .Success:
                    self.unlockHostAndConfigureView()
                case .Failure:
                    self.setDetailLabel(TouchIDUtils.getErrorMessage(result.error!))
                }
            }
        }
    }

    func unlockHostAndConfigureView() {
        // Update the user interface for the detail item.
        if let macHost = self.macHost {
            let cmd = "unlock"
            setDetailLabel("Unlocking...")
            MacHostsManager.sharedInstance.latestHostAlias = macHost.alias
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let result = macHost.executeCmd(cmd)
                dispatch_async(dispatch_get_main_queue(), {
                    let latestHostAlias = MacHostsManager.sharedInstance.latestHostAlias
                    if macHost.alias != latestHostAlias {
                        print("Ignore the result of '\(cmd)' for '\(macHost.alias)' because the latest host now is '\(latestHostAlias)'")
                        return
                    }
                    
                    switch result {
                    case .Success:
                        self.setDetailLabel("\(result.value!)")
                    case .Failure:
                        self.setDetailLabel("\(result.error?.localizedDescription ?? "")")
                    }
                })
            })
        }
    }
    
    func setDetailLabel(string: String) {
        self.detailDescriptionLabel?.text = string
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let label = self.detailDescriptionLabel {
            let animation: CATransition = CATransition()
            animation.duration = 0.5
            animation.type = kCATransitionFade
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            label.layer.addAnimation(animation, forKey: "changeTextTransition")
            
            label.text = ""
        }
    }
}

