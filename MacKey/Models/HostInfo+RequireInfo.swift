//
//  MacHost+RequireInfo.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

extension HostInfo {
    func requireLoginInfo(_ didGetLoginInfo:@escaping (HostInfo?) -> ()) {
        let alert = UIAlertController(title: nil, message: "Please input host information", preferredStyle: UIAlertControllerStyle.alert)
        var aliasField: UITextField?
        var hostField: UITextField?
        var usernameField: UITextField?
        var passwordField: UITextField?
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action)->() in
            let alias = aliasField?.text ?? ""
            if alias.isEmpty {
                didGetLoginInfo(nil)
                return
            }
            
            let host = hostField?.text ?? ""
            if host.isEmpty {
                didGetLoginInfo(nil)
                return
            }
            
            let user = usernameField?.text ?? ""
            if user.isEmpty {
                didGetLoginInfo(nil)
                return
            }
            
            let password = passwordField?.text ?? ""
            if password.isEmpty {
                didGetLoginInfo(nil)
                return
            }
            let newHost = HostInfo(alias: alias, host: host, user: user, password: password)
            didGetLoginInfo(newHost)
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter alias:"
            textField.text = self.alias
            aliasField = textField
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter host:"
            textField.text = self.host
            hostField = textField
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter username:"
            textField.text = self.user
            usernameField = textField
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter password:"
            textField.text = self.password
            textField.isSecureTextEntry = true
            passwordField = textField
        })
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        if (rootController != nil) {
            rootController!.present(alert, animated: true, completion: nil)
        }
    }

}
