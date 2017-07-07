//
//  RemoveCardViewCell.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 4/8/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import Localize_Swift


class RemoveCardViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        // show alert box to confirm
        _ = SweetAlert().showAlert("Are you sure?".localized(), subTitle: "You card will be permanently deleted!".localized(), style: AlertStyle.warning, buttonTitle:"No".localized(), buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Yes, delete it!".localized(), otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                // cancel - DO NOTING
                
            }
            else {
                // remove refrence from keychain and go back to main page
                KeychainWrapper.defaultKeychainWrapper.remove(key: "installID")
                KeychainWrapper.defaultKeychainWrapper.remove(key: "CardNo")
                KeychainWrapper.defaultKeychainWrapper.remove(key: "installHashKey")
                KeychainWrapper.defaultKeychainWrapper.remove(key: "voucherCounter")
                OperationQueue.main.addOperation {
                    
                  //  self.performSegue(withIdentifier: "backToMainPage", sender: self)
                }
            }
        }

    
    
    }

    
    
    
        
}
