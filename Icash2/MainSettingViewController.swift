//
//  MainSettingViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 4/8/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit

class MainSettingViewController: UITableViewController {
    
    
    let card = Card()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        nav?.backItem?.title = ""
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            RemoveCard()
            
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Setting".localized()
        
    }
    
    
    func RemoveCard (){
        // show alert box to confirm
        _ = SweetAlert().showAlert("Deactivate".localized(), subTitle: "Are you sure you want to deactivate your card? this cannot be undone".localized(), style: AlertStyle.warning, buttonTitle:"No".localized(), buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Yes, Deactivate".localized(), otherButtonColor: UIColor.colorFromRGB(0xFF0000)) { (isOtherButton) -> Void in
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

    
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
