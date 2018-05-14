//
//  HostDetailsViewController.swift
//  MacKey
//
//  Created by Liu Liang on 20/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import Localize_Swift
import RxSwift
import RxCocoa

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
    
    var viewModel: HostDetailsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        passwordOutlet.isSecureTextEntry = true
        
        saveOutlet.accessibilityIdentifier = "Save"
        cancelOutlet.accessibilityIdentifier = "Cancel"
        
        let oldHost = viewModel?.initialState.hostInfo ?? HostInfo()
        aliasOutlet?.text = oldHost.alias
        hostOutlet?.text = oldHost.host
        usernameOutlet?.text = oldHost.user
        passwordOutlet?.text = oldHost.password
        requireTouchIDOutlet.isOn = oldHost.requireTouchID
        
        validationOutlet.text = "Alias is already taken".localized()
        
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.askForUpgrade$
            .flatMapFirst { [unowned self] _ -> Observable<()> in
                if let upgradeViewController = self.showUpgradeViewController(
                    animated: true, forProductType: .skipTouchID) {
                    return upgradeViewController.getPurchaseState$()
                        .filter { $0 == .purchased }
                        .map { _ in }
                }
                return Observable.empty() }
            .map { .didUpgrade }
            .bind(to: viewModel.inputActions)
            .disposed(by: disposeBag)
        
        /*viewModel.dismiss$
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)*/
        
        [aliasOutlet.rx.text.orEmpty.map { .changeAlias($0) },
         hostOutlet.rx.text.orEmpty.map { .changeHost($0) },
         usernameOutlet.rx.text.orEmpty.map { .changeUsername($0) },
         passwordOutlet.rx.text.orEmpty.map { .changePassword($0) },
         requireTouchIDOutlet.rx.isOn.skip(1).map { _ in .requireTouchIDTapped },
         cancelOutlet.rx.tap.map { .cancelTapped },
         saveOutlet.rx.tap.map { .saveTapped }]
            .forEach {
                $0.bind(to: viewModel.inputActions).disposed(by: disposeBag)
        }
        
        [viewModel.aliasAvailable$.bind(to: validationOutlet.rx.isHidden),
         viewModel.requireTouchID$.bind(to: requireTouchIDOutlet.rx.isOn),
         viewModel.saveEnabled$.bind(to: saveOutlet.rx.isEnabled)]
            .forEach {
                $0.disposed(by: disposeBag)
        }
    }
}
