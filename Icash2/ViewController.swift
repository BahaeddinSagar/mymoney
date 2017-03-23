//
//  ViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/19/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var cardNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if KeychainWrapper.defaultKeychainWrapper.string(forKey: "installHashKey") == nil  {
            performSegue(withIdentifier: "showActivatePage", sender: self)
        } else {
            cardNumberLabel.text = KeychainWrapper.defaultKeychainWrapper.string(forKey: "CardNo")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func checkBalance(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "تفقد الرصيد", message: "الرجاء ادخال رقمك السري ", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            /////////////////////////////////My code is here
            let PINcode = textField!.text
            if PINcode == nil || PINcode == ""
            {
                _ = SweetAlert().showAlert("الرجاء ادخال الرقم السري ")
                
            } else {
               
                
                let card = Card()
               
                let voucherCounterString = String(describing: card.voucherCounter)
                let HPINcode =  Card.makeHash(str: card.CardNo!+PINcode!, level: 7)
                let ConfirmationCode = Card.makeHash(str: card.installID! + HPINcode + voucherCounterString , level: 7)
                let SenderConfirmationCode = Card.makeHash(str: card.installHashKey!+voucherCounterString+ConfirmationCode, level: 7)
                
                self.checkBalanceReq(installationID: card.installID!, VoucherCounter: voucherCounterString, ConfirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfirmationCode)
                
                
                
            }
            
        
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    func checkBalanceReq(installationID : String , VoucherCounter : String , ConfirmationCode :String , SenderConfirmationCode : String) {
        SwiftSpinner.show(" يتم الاتصال بالخادم ...")
        let requestURL : URL = URL(string: "https://icashapi.azurewebsites.net/api/ChechBalance/"+installationID+"/"+VoucherCounter+"/"+ConfirmationCode+"/"+SenderConfirmationCode)!
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
                    let result = Float(dataString!)
                    if result != nil && result! >= 0 {
                        
                        let card = Card()
                        _ = card.saveVC(VC: VoucherCounter)
                        
                        
                        OperationQueue.main.addOperation {
                            _ =  SweetAlert().showAlert("رصيدك هو",subTitle: dataString!, style: AlertStyle.none)
                        }
                        
                    }else {
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("فشلت العملية",subTitle: "نأمل التأكد من الرقم السري ", style: AlertStyle.error)
                        }
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
