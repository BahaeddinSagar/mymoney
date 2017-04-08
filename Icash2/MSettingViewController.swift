//
//  MainSettingViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 4/8/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//



import UIKit

class MSettingViewController : UITableViewController {
    var card = Card()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            RemoveCard()
            
            
        }
    }



 func RemoveCard (){
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
                
                self.performSegue(withIdentifier: "backToMainPage", sender: self)
            }
        }
    }
    
}

}

