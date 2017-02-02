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
        
        let viewModel = HostDetailsViewModel(
            input: (
                alias: aliasOutlet.rx.text.orEmpty.asDriver(),
                host: hostOutlet.rx.text.orEmpty.asDriver(),
                username: usernameOutlet.rx.text.orEmpty.asDriver(),
                password: passwordOutlet.rx.text.orEmpty.asDriver()
            )
        )
        aliasOutlet?.text = viewModel.initialValues.alias
        hostOutlet?.text = viewModel.initialValues.host
        usernameOutlet?.text = viewModel.initialValues.username
        passwordOutlet?.text = viewModel.initialValues.password
        
        validationOutlet.text = "Alias is already taken."
        
        viewModel.aliasAvailable.drive(validationOutlet.rx.isHidden).disposed(by: disposeBag)
        viewModel.saveEnabled.drive(saveOutlet.rx.isEnabled).disposed(by: disposeBag)
        
        saveOutlet.rx.tap
            .subscribe(onNext: { [unowned self] in
                let action = self.saveHostAction()
                self.dismiss(animated: true) {
                    if let action = action {
                        store.dispatch(action)
                    }
                }
            } )
            .disposed(by: disposeBag)
 
        cancelOutlet.rx.tap
            .subscribe(onNext: {[unowned self] in
                self.dismiss(animated: true) {
                    store.dispatch(CancelHostDetails())
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func saveHostAction() -> Action? {
        guard let alias = aliasOutlet.text,
            let host = hostOutlet.text,
            let user = usernameOutlet.text,
            let password = passwordOutlet.text else { return nil }
        let newHost = HostInfo(alias: alias, host: host, user: user, password: password)
        
        if let editingHostAlias = store.hostsState.editingHostAlias {
            guard let oldHost = store.hostsState.allHosts[editingHostAlias] else {
                print("host is nil for \(editingHostAlias)")
                return nil
            }
            
            store.dispatch(UpdateHost(oldHost: oldHost, newHost: newHost))
            return nil
        } else {
            return AddHost(host: newHost)
        }
    }
}
