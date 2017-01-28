//
//  HostDetailsViewController.swift
//  MacKey
//
//  Created by Liu Liang on 20/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactiveReSwift

class HostDetailsViewController: UITableViewController {
    @IBOutlet weak var aliasOutlet: UITextField!
    @IBOutlet weak var validationOutlet: UILabel!
    @IBOutlet weak var hostOutlet: UITextField!
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    @IBOutlet weak var cancelOutlet: UIBarButtonItem!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        passwordOutlet.isSecureTextEntry = true
        populateHostInfo()
        
        validationOutlet.text = "Alias is already taken."
        
        let aliasValid = aliasOutlet.rx.text.orEmpty.asDriver()
            .map { [weak self] in $0.characters.count > 0 && self?.isAliasAvailable($0) ?? false }
        let aliasAvailable = aliasOutlet.rx.text.orEmpty.asDriver()
            .map { [weak self] in self?.isAliasAvailable($0) ?? false }
        
        aliasAvailable.drive(validationOutlet.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        let hostValid = hostOutlet.rx.text.orEmpty.asDriver()
            .map { $0.characters.count > 0 }
        
        let usernameValid = usernameOutlet.rx.text.orEmpty.asDriver()
            .map { $0.characters.count > 0 }
        
        let passwordValid = passwordOutlet.rx.text.orEmpty.asDriver()
            .map { $0.characters.count > 0 }

        let isChanged = isAnyFieldChanged()
        let saveEnabled = Driver.combineLatest(aliasValid,
                                                              hostValid,
                                                              usernameValid,
                                                              passwordValid, isChanged
        ){ $0 && $1 && $2 && $3 && $4}
        
        saveEnabled.drive(saveOutlet.rx.isEnabled).addDisposableTo(disposeBag)
        
        saveOutlet.rx.tap
            .subscribe(onNext: { [unowned self] in
                let action = self.saveHostAction()
                self.dismiss(animated: true) {
                    if let action = action {
                        store.dispatch(action)
                    }
                }
            } )
            .addDisposableTo(disposeBag)
 
        cancelOutlet.rx.tap
            .subscribe(onNext: {[unowned self] in
                self.dismiss(animated: true) {
                    store.dispatch(CancelHostDetails())
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    private var hostsState : HostsState {
        return store.observable.value.hostsState
    }
    
    private func populateHostInfo() {
        guard let alias = hostsState.editingHostAlias else { return }
        guard let hostInfo = hostsState.allHosts[alias] else { return }
        aliasOutlet?.text = alias
        hostOutlet?.text = hostInfo.host
        usernameOutlet?.text = hostInfo.user
        passwordOutlet?.text = hostInfo.password
    }
    
    private func saveHostAction() -> Action? {
        guard let alias = aliasOutlet.text,
            let host = hostOutlet.text,
            let user = usernameOutlet.text,
            let password = passwordOutlet.text else { return nil }
        let newHost = HostInfo(alias: alias, host: host, user: user, password: password)
        
        if let editingHostAlias = hostsState.editingHostAlias {
            guard let oldHost = hostsState.allHosts[editingHostAlias] else {
                print("host is nil for \(editingHostAlias)")
                return nil
            }
            
            store.dispatch(UpdateHost(oldHost: oldHost, newHost: newHost))
            return nil
        } else {
            return AddHost(host: newHost)
        }
    }
    
    private func isAliasAvailable(_ alias: String) -> Bool {
        if alias == hostsState.editingHostAlias { return true }
        return !hostsState.allHosts.keys.contains(alias)
    }
    
    private func isAnyFieldChanged() -> Driver<Bool> {
        let oldAlias = aliasOutlet.text
        let oldHost = hostOutlet.text
        let oldUsername = usernameOutlet.text
        let oldPassword = passwordOutlet.text
        
        let aliasChanged = aliasOutlet.rx.text.orEmpty.asDriver()
            .map { $0 != oldAlias }
        let hostChanged = hostOutlet.rx.text.orEmpty.asDriver()
            .map { $0 != oldHost }
        let usernameChanged = usernameOutlet.rx.text.orEmpty.asDriver()
            .map { $0 != oldUsername }
        let passwordChanged = passwordOutlet.rx.text.orEmpty.asDriver()
            .map { $0 != oldPassword }
        
        return Driver.combineLatest(aliasChanged,
                                               hostChanged,
                                               usernameChanged,
                                               passwordChanged
        ){ $0 || $1 || $2 || $3}

    }
}
