//
//  Activate.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/19/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit


class ActivateViewController : UIViewController {
    
    
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var actiCodeTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var swi: UISwitch!
    var installid : String!
    var acticode : String!
    var phone : String!
    var CardNumber : String!
    
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let next = UIBarButtonItem(title: "next", style: .plain, target: self, action: #selector(confirm))
        //self.navigationItem.rightBarButtonItem = next
        
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
        validator.registerField(cardNumberTextField, errorLabel:cardErrorLabel , rules: [RequiredRule(),ExactLengthRule(length: 9, message : "Must be 9 digits" )])
        validator.registerField(actiCodeTextField, errorLabel: actiErrorLabel, rules: [RequiredRule(), FloatRule(message: " Must be float ")])
        validator.registerField(phoneTextField, errorLabel: PhoneErrorLabel, rules: [RequiredRule(),ExactLengthRule(length: 12, message : "use the form 218XXX" )])
 */
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchClicked(_ sender: UISwitch) {
        if swi.isOn {
            actiCodeTextField.text=""
            phoneTextField.text=""
            actiCodeTextField.isHidden = true
            phoneTextField.isHidden = true
        } else {
            actiCodeTextField.isHidden = false
            phoneTextField.isHidden = false
        }
        
    }
    
   
    
    @IBAction func confirm(_ sender: Any) {
        self.view.endEditing(true)
        
        
        validationSuccessful()
    }
    
    
   
    
    func validationSuccessful(){
    
        
        CardNumber = cardNumberTextField.text!
        if !swi.isOn{
            acticode = actiCodeTextField.text!
            phone = phoneTextField.text!
            
            if (CardNumber == "" || acticode == "") {
                _=SweetAlert().showAlert("Error ".localized(), subTitle: " Card Number and Activation code are required ".localized() , style: AlertStyle.error)
                
            }else if phone.characters.count != 12 {
                _=SweetAlert().showAlert("Phone number ".localized(), subTitle: "must be in the form : "+"2189XXXXXXXX " , style: AlertStyle.error)
            }else {
                var code = CardNumber + phone
                code = code + acticode
                let ConfirmationCode = Card.makeHash(str: (code) , level: 7)
                ActivateReq(CardNo: CardNumber, tel: phone, ActivationCode: acticode, ConfirmationCode: ConfirmationCode)
            }
        }else{
            // TOD read cardNumber field and call ActicateInstallation
            if CardNumber != "" {
                ActivateInstallationReq(CardNo: CardNumber)
            }else{
                _=SweetAlert().showAlert(" ", subTitle: "Card Number is required ".localized() , style: AlertStyle.error)
                
            }
        }
        
   
        
        
    }
    
    
    
    
    
    
    func ActivateReq ( CardNo:  String, tel: String, ActivationCode: String, ConfirmationCode: String){
        SwiftSpinner.show("Connecting to server ...".localized())
        let requestedurl : URL = URL (string: "https://icashapi.azurewebsites.net/api/ActivateReq/"+CardNo+"/"+tel+"/"+ActivationCode+"/"+ConfirmationCode)!
        print(requestedurl)
        let urlRequest : URLRequest = URLRequest(url: requestedurl)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            SwiftSpinner.hide()
            
            if response != nil {
                let httpResponse = response as! HTTPURLResponse
                if (httpResponse.statusCode == 200){
                    
                    let dataString = String(data: data!,encoding: .utf8)
                    let result = Int(dataString!)
                    
                    
                    switch(result!){
                    case -14 :
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle:" Card already activated with different Phone Number ".localized(), style: AlertStyle.error)
                        }
                    case -16 :
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle:" Card already activated with different Phone Number ".localized(), style: AlertStyle.error)
                        }
                    case -8 :
                        //print("issued but not distributed yet")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
                        
                    case -7 :
                        //print("internal error")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
                        
                    case -6 :
                        //to get instulattion ID
                        self.ActivateInstallationReq(CardNo: CardNo)
                        
                        
                    case -5 :
                        //print("card doesn't exist")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
                        
                    case -4 :
                        print("card already activated")
                        //to get instulattion ID
                        self.ActivateInstallationReq(CardNo: CardNo)
                        
                        
                    case -3 :
                        //print("issued but not distributed yet")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
                        
                    case -2 :
                        //print("issued but not distributed yet")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
                        
                    case -1 :
                        print("illigale request")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
                        
                    case 0..<10000000 :
                        // save finalresult which is InstallationID
                        if KeychainWrapper.defaultKeychainWrapper.set(dataString!, forKey: "installID") && KeychainWrapper.defaultKeychainWrapper.set(CardNo, forKey: "CardNo") {
                            self.installid = dataString!
                            // TODO : Show an alert to user to wait for the SMS
                            // print("All good,message will be sent to you soon")
                            // to show the result
                            OperationQueue.main.addOperation {
                                _ = SweetAlert().showAlert("Succuss".localized(),subTitle: " you will recieve an SMS with confirmation Code shortly", style: AlertStyle.success)
                                self.performSegue(withIdentifier: "goToConfirm", sender: self)
                            }
                        }
                    default :
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(),subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
                        break
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                }
            }
        }
        task.resume()
    }
    
    
    
    func ActivateInstallationReq(CardNo: String) {
        SwiftSpinner.show(" Connecting to server ...".localized())
        let requestURL : URL = URL(string: "https://icashapi.azurewebsites.net/api/ActivateInstallationReq/"+CardNo)!
        let urlRequest : URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data,response,error) in
            SwiftSpinner.hide()
            if response != nil {
                let dataString = String (data:data!,encoding: .utf8)
                let result = Int(dataString!)
                if (result! > 0)
                {
                    if KeychainWrapper.defaultKeychainWrapper.set(dataString!, forKey: "installID") && KeychainWrapper.defaultKeychainWrapper.set(CardNo, forKey: "CardNo") {
                        self.installid = dataString!
                        // TODO : Show an alert to user to wait for the SMS
                        //print("All good,message will be sent to you soon")
                        // to show the result
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Succuss".localized(),subTitle: " you will recieve an SMS with confirmation Code shortly".localized(), style: AlertStyle.success)
                            self.performSegue(withIdentifier: "goToConfirm", sender: self)
                        }
                    }

                } else {
                    OperationQueue.main.addOperation {
                        _ = SweetAlert().showAlert("Error".localized(),subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        print("operation failed")
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
}
