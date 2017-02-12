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

enum EditHostState {
    case saved(HostInfo)
    case cancelled
}

class HostDetailsViewController: UITableViewController {
    @IBOutlet weak var aliasOutlet: UITextField!
    @IBOutlet weak var validationOutlet: UILabel!
    @IBOutlet weak var hostOutlet: UITextField!
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    @IBOutlet weak var cancelOutlet: UIBarButtonItem!
    @IBOutlet weak var requireTouchIDOutlet: UISwitch!
    
    private var disposeBag = DisposeBag()
    
    var oldHost = HostInfo()
    private let editHostState$: PublishSubject<EditHostState> = PublishSubject()
    
    func getEditHostState() -> Observable<EditHostState> {
        return editHostState$.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        passwordOutlet.isSecureTextEntry = true
        
        let viewModel = HostDetailsViewModel(
            input: (
                alias$: aliasOutlet.rx.text.orEmpty.asDriver(),
                host$: hostOutlet.rx.text.orEmpty.asDriver(),
                username$: usernameOutlet.rx.text.orEmpty.asDriver(),
                password$: passwordOutlet.rx.text.orEmpty.asDriver(),
                requireTouchID$: requireTouchIDOutlet.rx.isOn.asDriver(),
                initialHost: oldHost
            )
        )
        aliasOutlet?.text = oldHost.alias
        hostOutlet?.text = oldHost.host
        usernameOutlet?.text = oldHost.user
        passwordOutlet?.text = oldHost.password
        requireTouchIDOutlet?.isOn = oldHost.requireTouchID
        
        validationOutlet.text = "Alias is already taken."
        
        viewModel.aliasAvailable$.drive(validationOutlet.rx.isHidden).disposed(by: disposeBag)
        viewModel.saveEnabled$.drive(saveOutlet.rx.isEnabled).disposed(by: disposeBag)
        
        saveOutlet.rx.tap
            .subscribe(onNext: { [unowned self] in
                guard let alias = self.aliasOutlet.text,
                    let host = self.hostOutlet.text,
                    let user = self.usernameOutlet.text,
                    let password = self.passwordOutlet.text else { return }
                let requireTouchID = self.requireTouchIDOutlet.isOn
                let newHost = HostInfo(alias: alias,
                                       host: host,
                                       user: user,
                                       password: password,
                                       requireTouchID: requireTouchID)
                self.editHostState$.onNext(.saved(newHost))
                self.editHostState$.onCompleted()
            } )
            .disposed(by: disposeBag)
 
        cancelOutlet.rx.tap
            .subscribe(onNext: {[unowned self] in
                self.editHostState$.onNext(.cancelled)
                self.editHostState$.onCompleted()
            })
            .disposed(by: disposeBag)
    }
}
