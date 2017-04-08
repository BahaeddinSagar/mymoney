//
//  RemoveCardViewCell.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 4/8/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit

class RemoveCardViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        // show alert box to confirm
        _ = SweetAlert().showAlert("Are you sure?", subTitle: "You card will be permanently deleted!", style: AlertStyle.warning, buttonTitle:"Cancel", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Yes, delete it!", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
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
