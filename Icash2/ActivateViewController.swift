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
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchClicked(_ sender: UISwitch) {
        if swi.isOn {
            actiCodeTextField.text=""
            phoneTextField.text=""
            actiCodeTextField.isEnabled = false
            phoneTextField.isEnabled = false
        } else {
            actiCodeTextField.isEnabled = true
            phoneTextField.isEnabled = true
        }
        
    }
    
   
    
    @IBAction func confirm(_ sender: Any) {
        CardNumber = cardNumberTextField.text!
        if swi.isOn{
            acticode = actiCodeTextField.text!
            phone = phoneTextField.text!
            
            if (CardNumber == "" || acticode == "") {
                _=SweetAlert().showAlert("الرجاء ادخال رقم البطاقة و رقم التفعيل ", subTitle: " " , style: AlertStyle.error)
                
            }else if phone.characters.count != 11 {
                _=SweetAlert().showAlert("الرجاء ادخال رقم الهاتف بصيغة  ", subTitle: "2189XXXXXXXX " , style: AlertStyle.error)
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
                _=SweetAlert().showAlert("الرجاء ادخال رقم البطاقة  ", subTitle: " " , style: AlertStyle.error)
                
            }
        }
        
   
        
        
    }
    
    
    
    
    
    
    func ActivateReq ( CardNo:  String, tel: String, ActivationCode: String, ConfirmationCode: String){
        SwiftSpinner.show(" يتم الاتصال بالخادم ...")
        let requestedurl : URL = URL (string: "http://icashapi.azurewebsites.net/api/ActivateReq/"+"/"+CardNo+"/"+tel+"/"+ActivationCode+"/"+ConfirmationCode)!
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
                    case -8 :
                        //print("issued but not distributed yet")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("خطأ", subTitle: "issued but not distributed yet", style: AlertStyle.error)
                        }
                        
                    case -7 :
                        //print("internal error")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("خطأ", subTitle: "internal error", style: AlertStyle.error)
                        }
                        
                    case -6 :
                        //to get instulattion ID
                        self.ActivateInstallationReq(CardNo: CardNo)
                        
                        
                    case -5 :
                        //print("card doesn't exist")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("خطأ", subTitle: "card doesn't exist", style: AlertStyle.error)
                        }
                        
                    case -4 :
                        print("card already activated")
                        //to get instulattion ID
                        self.ActivateInstallationReq(CardNo: CardNo)
                        
                        
                    case -3 :
                        //print("issued but not distributed yet")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("خطأ", subTitle: "issued but not distributed yet", style: AlertStyle.error)
                        }
                        
                    case -2 :
                        //print("issued but not distributed yet")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("خطأ", subTitle: "issued but not distributed yet", style: AlertStyle.error)
                        }
                        
                    case -1 :
                        print("illigale request")
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("حطأ", subTitle: "illigale request", style: AlertStyle.error)
                        }
                        
                    case 0..<1000000 :
                        // save finalresult which is InstallationID
                        if KeychainWrapper.defaultKeychainWrapper.set(dataString!, forKey: "installID")  {
                            self.installid = dataString!
                            // TODO : Show an alert to user to wait for the SMS
                            //print("All good,message will be sent to you soon")
                            // to show the result
                            OperationQueue.main.addOperation {
                                _ = SweetAlert().showAlert("نجحت العملية",subTitle: "ستصلك رسالة برقم التأكيد قريبا ", style: AlertStyle.success)
                                self.performSegue(withIdentifier: "goToConfirm", sender: self)
                            }
                        }
                    default :
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("فشلت العملية",subTitle: "نأمل المحاولة مجددا ", style: AlertStyle.error)
                        }
                        break
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("فشلت العملية",subTitle: "نأمل التحقق من الوصول للانترنت ", style: AlertStyle.error)
                }
            }
        }
        task.resume()
    }
    
    
    
    func ActivateInstallationReq(CardNo: String) {
        SwiftSpinner.show("Connecting to server...")
        let requestURL : URL = URL(string: "http://icashapi.azurewebsites.net/api/ActivateInstallationReq/"+CardNo)!
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
                    self.installid = dataString!
                    if KeychainWrapper.defaultKeychainWrapper.set(self.installid, forKey: "installID"){
                        OperationQueue.main.addOperation {
                             _ = SweetAlert().showAlert("نجحت العملية",subTitle: "ستصلك رسالة برقم التأكيد قريبا ", style: AlertStyle.success)
                            self.performSegue(withIdentifier: "goToConfirm", sender: self)
                        }
                    }
                } else {
                    OperationQueue.main.addOperation {
                        _ = SweetAlert().showAlert("خطأ", subTitle: "نأمل المحاولة مجددا ", style: AlertStyle.error)
                        print("operation failed")
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("فشلت العملية",subTitle: "نأمل التحقق من الوصول للانترنت ", style: AlertStyle.error)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
}
