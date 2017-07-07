//
//  ConfirmViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/20/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit

class ConfirmViewController : UIViewController {
    
    @IBOutlet weak var confCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let done = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(confirm))
        //self.navigationItem.rightBarButtonItem = done
      
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        self.view.endEditing(true)
        let confCode = confCodeTextField.text!
        if (confCode != "") {
            let CardNumber = KeychainWrapper.defaultKeychainWrapper.string(forKey: "CardNo")!
            let installID = KeychainWrapper.defaultKeychainWrapper.string(forKey: "installID")!
            let installationHkey = Card.makeHash(str: confCode+CardNumber, level: 7)
            //TODO : make verify HPINCODE
            let SenderConfirmationCode = Card.makeHash(str: installationHkey+CardNumber, level: 7)
            
            
            ActivateInstallation(installID: installID, CardNumber: CardNumber, SenderConfirmationCode: SenderConfirmationCode, installationHkey: installationHkey)
        } else {
             _ = SweetAlert().showAlert("Error".localized(), subTitle: "Please Enter Confirmation Code".localized(), style: AlertStyle.error)
            
        }
    }
    
    func ActivateInstallation(installID: String, CardNumber: String, SenderConfirmationCode:String, installationHkey : String) {
        SwiftSpinner.show(" Connecting to server  ...".localized())
        
        let requestURL : URL = URL(string: "https://icashapi.azurewebsites.net/api/ConfirmInstallation/"+installID+"/"+CardNumber+"/"+SenderConfirmationCode)!
        
        
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest){
            (data,response,error) in
            SwiftSpinner.hide()
            if response != nil {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if (statusCode == 200) {
                    let dataString = String(data: data!, encoding: .utf8)
                    let result =  Int(dataString!)!
                    //if (dataString! == "true"){
                    if result > 0 {
                        OperationQueue.main.addOperation {
                            if (KeychainWrapper.defaultKeychainWrapper.set(installationHkey, forKey: "installHashKey")) && (KeychainWrapper.defaultKeychainWrapper.set(result+1, forKey:"voucherCounter")){
                                _ = SweetAlert().showAlert("Success".localized(), subTitle: "Card in Activated".localized(), style: AlertStyle.success , buttonTitle: " Okay".localized()){ (isButton) -> Void in

                                    self.performSegue(withIdentifier: "showMainPage", sender: self)
                                }
                            }else {
                                _ = SweetAlert().showAlert("Error".localized())
                            }
                        }
                    }else {
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: "Please Check Confirmation Code".localized(), style: AlertStyle.error)
                        }
                    }
                }else {
                    OperationQueue.main.addOperation {
                        _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                    }
                }
            }
            
        }
        task.resume()
        
}
}
