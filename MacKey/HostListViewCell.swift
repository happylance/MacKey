//
//  HostListViewCell.swift
//  MacKey
//
//  Created by Liu Liang on 04/02/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import RxSwift

class HostListViewCell: UITableViewCell {
    @IBOutlet weak var hostAliasOutlet: UILabel!
    @IBOutlet weak var hostStatusOutlet: UILabel!
    @IBOutlet weak var sleepButtonOutlet: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
