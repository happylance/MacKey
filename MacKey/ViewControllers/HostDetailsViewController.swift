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
import ReSwift
import ReSwiftRouter

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
        
        
        let aliasValid = aliasOutlet.rx.text.orEmpty
            .map { [weak self] in $0.characters.count > 0 && self?.isAliasAvailable($0) ?? false }
            .shareReplay(1)
        let aliasAvailable = aliasOutlet.rx.text.orEmpty
            .map { [weak self] in self?.isAliasAvailable($0) ?? false }
            .shareReplay(1)
        
        aliasAvailable.bindTo(validationOutlet.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        let hostValid = hostOutlet.rx.text.orEmpty
            .map { $0.characters.count > 0 }
            .shareReplay(1)
        
        let usernameValid = usernameOutlet.rx.text.orEmpty
            .map { $0.characters.count > 0 }
            .shareReplay(1)
        
        let passwordValid = passwordOutlet.rx.text.orEmpty
            .map { $0.characters.count > 0 }
            .shareReplay(1)
        
        let isChanged = isAnyFieldChanged()
        let saveEnabled = Observable.combineLatest(aliasValid,
                                                              hostValid,
                                                              usernameValid,
                                                              passwordValid, isChanged
        ){ $0 && $1 && $2 && $3 && $4}
        .shareReplay(1)
        
        saveEnabled.bindTo(saveOutlet.rx.isEnabled).addDisposableTo(disposeBag)
        
        saveOutlet.rx.tap
            .subscribe(onNext: { [weak self] in
                store.dispatch(SetRouteAction([], animated: true, completionAction: self?.saveHostAction()))
            } )
            .addDisposableTo(disposeBag)
 
        cancelOutlet.rx.tap
            .subscribe(onNext: {
                store.dispatch(SetRouteAction([], animated: true, completionAction: CancelHostDetails()))
            })
            .addDisposableTo(disposeBag)
    }
    
    private var hostsState : HostsState {
        return store.state.hostsState
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
    
    private func isAnyFieldChanged() -> Observable<Bool> {
        let oldAlias = aliasOutlet.text
        let oldHost = hostOutlet.text
        let oldUsername = usernameOutlet.text
        let oldPassword = passwordOutlet.text
        
        let aliasChanged = aliasOutlet.rx.text.orEmpty
            .map { $0 != oldAlias }
            .shareReplay(1)
        let hostChanged = hostOutlet.rx.text.orEmpty
            .map { $0 != oldHost }
            .shareReplay(1)
        let usernameChanged = usernameOutlet.rx.text.orEmpty
            .map { $0 != oldUsername }
            .shareReplay(1)
        let passwordChanged = passwordOutlet.rx.text.orEmpty
            .map { $0 != oldPassword }
            .shareReplay(1)
        
        return Observable.combineLatest(aliasChanged,
                                               hostChanged,
                                               usernameChanged,
                                               passwordChanged
        ){ $0 || $1 || $2 || $3}
            .shareReplay(1)

    }
}
