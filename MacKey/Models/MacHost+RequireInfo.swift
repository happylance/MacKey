//
//  MacHost+RequireInfo.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

extension MacHost {
    func requireLoginInfo(didGetLoginInfo:(Bool)->()) {
        let alert = UIAlertController(title: nil, message: "Please input host information", preferredStyle: UIAlertControllerStyle.Alert)
        var aliasField: UITextField?
        var hostField: UITextField?
        var usernameField: UITextField?
        var passwordField: UITextField?
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action)->() in
            self.alias = aliasField?.text ?? ""
            if self.alias.isEmpty {
                didGetLoginInfo(false)
                return
            }
            
            self.host = hostField?.text ?? ""
            if self.host.isEmpty {
                didGetLoginInfo(false)
                return
            }
            
            self.user = usernameField?.text ?? ""
            if self.user .isEmpty {
                didGetLoginInfo(false)
                return
            }
            
            self.password = passwordField?.text ?? ""
            if self.password.isEmpty {
                didGetLoginInfo(false)
                return
            }
            
            didGetLoginInfo(true)
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter alias:"
            textField.text = self.alias
            aliasField = textField
        })
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter host:"
            textField.text = self.host
            hostField = textField
        })
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter username:"
            textField.text = self.user
            usernameField = textField
        })
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter password:"
            textField.text = self.password
            textField.secureTextEntry = true
            passwordField = textField
        })
        let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController
        if (rootController != nil) {
            rootController!.presentViewController(alert, animated: true, completion: nil)
        }
    }

}