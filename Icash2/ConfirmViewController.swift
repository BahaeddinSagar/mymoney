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
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        let confCode = confCodeTextField.text!
        if (confCode != "") {
            let CardNumber = KeychainWrapper.defaultKeychainWrapper.string(forKey: "CardNo")!
            let installID = KeychainWrapper.defaultKeychainWrapper.string(forKey: "installID")!
            let installationHkey = Card.makeHash(str: confCode+CardNumber, level: 7)
            //TODO : make verify HPINCODE
            let SenderConfirmationCode = Card.makeHash(str: installationHkey+CardNumber, level: 7)
            
            
            ActivateInstallation(installID: installID, CardNumber: CardNumber, SenderConfirmationCode: SenderConfirmationCode, installationHkey: installationHkey)
        }
    }
    
    func ActivateInstallation(installID: String, CardNumber: String, SenderConfirmationCode:String, installationHkey : String) {
        SwiftSpinner.show(" يتم الاتصال بالخادم ...")
        let requestURL : URL = URL(string: "https://icashapi.azurewebsites.net/api/ActivateInstallation/"+installID+"/"+CardNumber+"/"+SenderConfirmationCode)!
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
                    if (dataString! == "true"){
                        OperationQueue.main.addOperation {
                            if (KeychainWrapper.defaultKeychainWrapper.set(installationHkey, forKey: "installHashKey")) && (KeychainWrapper.defaultKeychainWrapper.set(8, forKey:"voucherCounter")){
                                _ = SweetAlert().showAlert("نجحت العملية", subTitle: "تم التفعيل بنجاح", style: AlertStyle.success , buttonTitle: " حسنا"){ (isButton) -> Void in

                                    self.performSegue(withIdentifier: "showMainPage", sender: self)
                                }
                            }else {
                                _ = SweetAlert().showAlert("خطأ")
                            }
                        }
                    }else {
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("خطأ", subTitle: "الرجاء التأكد من رقم التأكيد", style: AlertStyle.error)
                        }
                    }
                }else {
                    OperationQueue.main.addOperation {
                        _ = SweetAlert().showAlert("فشلت العملية",subTitle: "نأمل التحقق من الوصول للانترنت ", style: AlertStyle.error)
                    }
                }
            }
            
        }
        task.resume()
        
}
}
