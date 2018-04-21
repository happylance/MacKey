//
//  HelpViewController.swift
//  MacKey
//
//  Created by Liu Liang on 01/03/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HelpViewController: UIViewController {
    @IBOutlet weak var closeOutlet: UIBarButtonItem!
    @IBOutlet weak var textViewOutlet: UITextView!
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        closeOutlet.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        textViewOutlet.attributedText = {
            let remoteLoginStr = " > System Preferences > Sharing > RemoteLogin".localized()
            let helpText = String(format: "HelpText".localized(), remoteLoginStr, remoteLoginStr)
            let attrStr = NSMutableAttributedString(string:helpText,
                                                    attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            attrStr.setAttributes([.foregroundColor:self.view.tintColor ?? UIColor.blue,
                                       .font: UIFont.preferredFont(forTextStyle: .title1)],
                                      range: (helpText as NSString).range(of: "+"))
            
            
            let boldFont = { () -> UIFont in
                guard let boldDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                    .withSymbolicTraits(.traitBold) else {
                        return UIFont.preferredFont(forTextStyle: .body)
                }
                return UIFont(descriptor: boldDescriptor, size: 0)
            }()
            
            helpText.ranges(of: remoteLoginStr)
                .forEach {
                    attrStr.setAttributes([.font: boldFont],range:$0)
            }
            
            ["Alias", "Host name or IP address", "Username", "Password"]
                .map { $0.localized() }
                .forEach {
                    attrStr.setAttributes([.font: boldFont],
                                          range:(helpText as NSString).range(of: $0))
            }
            
            return attrStr
        }()
    }
}

extension String {
    func ranges(of subString: String) -> [NSRange] {
        var ranges = [NSRange]()
        
        var range: NSRange = NSMakeRange(0, self.count)
        while (range.location != NSNotFound) {
            range = (self as NSString).range(of: subString, options: .caseInsensitive, range: range)
            if (range.location != NSNotFound) {
                ranges.append(range)
                range = NSRange(location: range.location + range.length, length: self.count - (range.location + range.length))
            }
        }
        return ranges
    }
}
