//
//  MasterViewController+touchID.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import SimpleTouch
import Result

extension MasterViewController {
    
    func clearUnlockStatus() {
        setDetailLabel("")
    }
    
    func wakeUpAndRequireTouchID() {
        if let macHost = store.state.latestHost {
            let cmd = "wake"
            setDetailLabel("Connecting...")
            DispatchQueue.global().async(execute: {
                let result = macHost.executeCmd(cmd)
                DispatchQueue.main.async(execute: {
                    let latestHostAlias = store.state.latestHostAlias
                    if macHost.alias != latestHostAlias {
                        print("Ignore the result of '\(cmd)' for '\(macHost.alias)' because the latest host now is '\(latestHostAlias)'")
                        return
                    }
                    
                    switch result {
                    case .success:
                        if result.value == "" {
                            self.setDetailLabel("Connected")
                            self.requireTouchID()
                        } else {
                            self.setDetailLabel(result.value!)
                        }
                    case .failure:
                        self.setDetailLabel(result.error?.localizedDescription ?? "")
                    }
                })
            })
        }
    }
    
    private func handleTouchIDResult(_ result: Result<Bool, TouchIDError>) {
        switch(result) {
        case .success:
            self.unlockHostAndConfigureView()
        case .failure:
            self.setDetailLabel(TouchIDUtils.getErrorMessage(result.error!))
        }
    }
    
    private func requireTouchID() {
        TouchIDUtils.runTouchID { (result) in
            self.handleTouchIDResult(result)
        }
    }
    
    private func unlockHostAndConfigureView() {
        // Update the user interface for the detail item.
        if let macHost = store.state.latestHost {
            let cmd = "unlock"
            setDetailLabel("Unlocking...")
            
            DispatchQueue.global().async(execute: {
                let result = macHost.executeCmd(cmd)
                DispatchQueue.main.async(execute: {
                    let latestHostAlias = store.state.latestHostAlias
                    if macHost.alias != latestHostAlias {
                        print("Ignore the result of '\(cmd)' for '\(macHost.alias)' because the latest host now is '\(latestHostAlias)'")
                        return
                    }
                    
                    switch result {
                    case .success:
                        self.setDetailLabel(result.value!)
                    case .failure:
                        self.setDetailLabel(result.error?.localizedDescription ?? "")
                    }
                })
            })
        }
    }
    
    private func setDetailLabel(_ string: String) {
        latestHostUnlockStatus = string
        if let selectedCell = self.selectedCell {
            if let seletedCellIndex = self.tableView.indexPath(for: selectedCell) {
                self.tableView.reloadRows(at: [seletedCellIndex], with: .none)
            }
        }
    }
}
