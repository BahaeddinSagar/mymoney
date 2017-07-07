//
//  SettingViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/23/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit

class SettingViewController : UIViewController {
    var card = Card()
    
    @IBOutlet weak var oldPINtextField: UITextField!
    @IBOutlet weak var newPINtextField: UITextField!
    @IBOutlet weak var confimPINtextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
        let nav = self.navigationController?.navigationBar
        nav?.backItem?.title = ""
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title=" Change PIN Code "
    }
    
       
    @IBAction func changePIN(_ sender: UIButton) {
        self.resignFirstResponder()
        //  read newPIN and oldPIN and create the HashKyes
        let oldPIN = oldPINtextField.text!
        let newPIN = newPINtextField.text!
        let confirmPIN = confimPINtextField.text!
        // Minimum PINcode characters
        if newPIN.characters.count != 4 {
            _ = SweetAlert().showAlert( "Error".localized()  ,subTitle: "PIN code should have minimum 4 numbers".localized(), style: AlertStyle.warning)
            // confirming that codes match
        } else if newPIN != confirmPIN {
            _ = SweetAlert().showAlert("Error".localized()  ,subTitle: "Codes don't match".localized(), style: AlertStyle.warning)
        }else {
            // TO make hash and Emergency hash PIN code for new and old codes
            let HPCS = Card.makeHash(str: card.CardNo!+oldPIN,level: 7)
            let NHPCS = Card.makeHash(str: card.CardNo!+newPIN,level: 7)
            // TO reverse the new and old PINS to be used in the next step
            let reversePC = String(oldPIN.characters.reversed())
            let reverseNPC = String(newPIN.characters.reversed())
            // to make the Emergency hash code
            let EHPCS = Card.makeHash(str: card.CardNo!+reversePC ,level: 7)
            let ENHPCS = Card.makeHash(str: card.CardNo!+reverseNPC , level: 7)
            
            let voucherCounter = String(card.voucherCounter+2)
            
            // making confirmation codes
            
            let ConfirmationCode = Card.makeHash(str: HPCS + NHPCS + ENHPCS + voucherCounter, level: 7)
            let SenderConfirmationCode = Card.makeHash(str: card.installHashKey! + NHPCS + ENHPCS + voucherCounter + ConfirmationCode , level: 7)
            // making the initial request
            ChangePIN(installID: card.installID! , NHPC: NHPCS, RNHPC: ENHPCS, voucherCounter: voucherCounter, confirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfirmationCode,HPCS: HPCS)
            
        }
        
        
        
        // TODO create new hash pin code and reverse hash pin code
        // TODO create CC and SCC
        // CC = Hcode(PCHK.ToString() + NHPCS + RNHPCS + Counter.ToString(), 7);
        // SCC = Hcode(InsHK.ToString() + NHPCS + RNHPCS+ Counter.ToString() + CC.ToString(), 7);
        // request the URL string URL = ServerURL + "ChangeBinReq/" + InstallID.ToString() + "/" + NHPCS + "/" + RNHPCS + "/" + Counter.ToString() + "/" + CC.ToString() + "/" + SCC.ToString();
        // result is true or false
    }
    
    func ChangePIN(installID : String, NHPC : String, RNHPC : String, voucherCounter : String, confirmationCode : String, SenderConfirmationCode : String , HPCS : String) {
        SwiftSpinner.show(" Connecting to server...".localized())
        // make request
        let requestURL: URL = URL(string: "https://icashapi.azurewebsites.net/api/ChangeBinReq/"+installID+"/"+NHPC+"/"+RNHPC+"/"+voucherCounter+"/"+confirmationCode+"/"+SenderConfirmationCode)!
        print(requestURL)
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            SwiftSpinner.hide()
            if response != nil {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if (statusCode == 200) {
                    let dataString = String(data: data!, encoding: .utf8)
                    let result = Int(dataString!)
                    if result != nil && result! >= 0{
                        // if result is > 0 then OK
                        // SMS should be sent to the client and the client should enter the code
                        OperationQueue.main.addOperation {
                            //1. Create the alert controller.
                            let alert = UIAlertController(title: "SMS code".localized(), message: "an SMS code is sent to you, enter it here".localized(), preferredStyle: .alert)
                            
                            //2. Add the text field. You can configure it however you need.
                            alert.addTextField { (textField) in
                                textField.text = ""
                                textField.keyboardType = UIKeyboardType.numberPad
                            }
                            
                            // 3. Grab the value from the text field, and print it when the user clicks OK.
                            // if cancel pressed, do nothing
                            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { [weak alert] (_) in
                            }))
                            // if OK is pressed, continue
                            alert.addAction(UIAlertAction(title: "Enter".localized(), style: .default, handler: { [weak alert] (_) in
                                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                                /////////////////////////////////My code is here
                                self.resignFirstResponder()
                                let SMScode = textField!.text
                                // if code is entered correctly
                                if SMScode != "" {
                                    // make hash from SMS code, HashPINcode, NewHashPinCode and EmergencyHashPinCode
                                    let  HashedSMS = Card.makeHash(str: HPCS + Card.makeHash(str:NHPC+RNHPC+SMScode!,level: 7),level: 7)
                                    // make sender confirmation code from installID, SMScode (dataString) and HashedSMS
                                    let  SCC = Card.makeHash(str: self.card.installHashKey!+dataString!+HashedSMS ,level: 7)
                                    // making the second request to confirm the change of the PIN, with dataString is SMScode
                                    self.confirmPIN(installID: self.card.installID!, RequestID: dataString!, HashedSMS: HashedSMS, SenderConfirmationCode: SCC, voucherCounter: voucherCounter)
                                }
                                
                                
                            }))
                            // this is to show the alert box
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        // if reult < 0 then error
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(),subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
                    }
                } else {
                    // if status code != 200 then error
                    OperationQueue.main.addOperation {
                        _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                    }
                }
                
            }else {
                // if result is nil then error
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                }
            }
        }
        task.resume()
        
    }
    
    
    func confirmPIN(installID : String, RequestID : String, HashedSMS : String, SenderConfirmationCode : String , voucherCounter: String ) {
        SwiftSpinner.show("Connecting to server...".localized())
        
        let requestURL: URL = URL(string: "https://icashapi.azurewebsites.net/api/ConfirmedNewPin/"+installID+"/"+RequestID+"/" + HashedSMS+"/"+SenderConfirmationCode)!
        print(requestURL)
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            SwiftSpinner.hide()
            if response != nil {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if (statusCode == 200) {
                    let dataString = String(data: data!, encoding: .utf8)
                    let result = Int(dataString!)
                    // if the returned string is the same as instalHashKey then
                    if dataString! == self.card.installHashKey {
                        // read the new PIN
                        let PIN = self.newPINtextField.text!
                        // create new VHPINcode and VHEPINCode
                        self.card.VHPinCode = Card.makeHash(str: self.card.CardNo!+PIN,level: 7)
                        let reverseNPC = String(PIN.characters.reversed())
                        self.card.VHEPinCode = Card.makeHash(str: self.card.CardNo!+reverseNPC , level: 7)
                        // this is to save all data except vouchercouter
                        self.card.save()
                        // this is to save voucher counter
                        self.card.saveVC(VC: voucherCounter)
                        OperationQueue.main.addOperation {
                            // show that everything is good
                            _ = SweetAlert().showAlert("Success".localized(),subTitle: "PIN code changed successfully ".localized(), style: AlertStyle.success)
                        }
                        
                    } else {
                        // if returned string != install hash key, error !
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: "Please Check SMS Code".localized(), style: AlertStyle.error)
                        }
                    }
                } else {
                    OperationQueue.main.addOperation {
                      // if statuscode != 200 error
                        _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                    }
                }
            }else {
                // if responce is nil, error !
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                }
            }
            
        }
        task.resume()
        
    }
    
    @IBAction func endEdit1(_ sender: Any) {
        resignFirstResponder()
    }
    
    
    
    //TODO : Add validator for PIN (4 numbers) and they must match
    
}
