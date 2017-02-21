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
    private let editHostState$ = PublishSubject<EditHostState>()
    
    func getEditHostState() -> Observable<EditHostState> {
        return editHostState$.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        passwordOutlet.isSecureTextEntry = true
        
        aliasOutlet?.text = oldHost.alias
        hostOutlet?.text = oldHost.host
        usernameOutlet?.text = oldHost.user
        passwordOutlet?.text = oldHost.password
        requireTouchIDOutlet.isOn = oldHost.requireTouchID
        
        validationOutlet.text = "Alias is already taken."
        
        let requireTouchID$ = Variable(requireTouchIDOutlet.isOn)
        
        requireTouchIDOutlet.rx.isOn
            .skip(1)
            .flatMapFirst { isOn -> Observable<Bool> in
                if (isOn || store.observable.value.supportSkippingTouchID) {
                    return Observable.just(isOn)
                } else if let upgradeViewController = self.showUpgradeViewController(
                    animated: true, forProductType: .skipTouchID) {
                    return upgradeViewController.getPurchaseState$()
                        .do(onNext: {
                            if case .cancelled = $0 {
                                self.requireTouchIDOutlet.isOn = true
                            }
                        })
                        .filter { $0 == .purchased }
                        .map {_ in isOn }
                }
                return Observable.empty()
            }
            .subscribe(onNext:{
                requireTouchID$.value = $0
            })
            .disposed(by: disposeBag)
        
        let viewModel = HostDetailsViewModel(
            alias$: aliasOutlet.rx.text.orEmpty.asDriver(),
            host$: hostOutlet.rx.text.orEmpty.asDriver(),
            username$: usernameOutlet.rx.text.orEmpty.asDriver(),
            password$: passwordOutlet.rx.text.orEmpty.asDriver(),
            requireTouchID$: requireTouchID$.asDriver(),
            cancelOutlet$: cancelOutlet.rx.tap.asDriver(),
            saveOutlet$: saveOutlet.rx.tap.asDriver(),
            initialHost: oldHost
        )
        
        viewModel.aliasAvailable$.drive(validationOutlet.rx.isHidden).disposed(by: disposeBag)
        viewModel.saveEnabled$.drive(saveOutlet.rx.isEnabled).disposed(by: disposeBag)
        viewModel.editHostState$.bindTo(editHostState$).disposed(by: disposeBag)
    }
}
