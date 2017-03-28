//
//  transferMoney.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/19/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit

class transferMoney : UIViewController {
    
    
    @IBOutlet weak var RxCardNumberTextField: UITextField!
    @IBOutlet weak var AmountTextDield: UITextField!
    @IBOutlet weak var PINcode: UITextField!
    
    var card = Card()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func transfer(_ sender: UIButton) {
        self.view.endEditing(true)
        let RcardNumber = RxCardNumberTextField.text!
        let cardNumber = card.CardNo!
        let amount = Card.changeToFloat(Float(AmountTextDield.text!)!)
        //let amount = AmountTextDield.text!
        let PIN = PINcode.text!
        let vouchercounter = card.voucherCounter+1
        let VC = String(describing: vouchercounter)
        let installID = card.installID!
        let installHashKey = card.installHashKey!
        
        let HPINcode = Card.makeHash(str: cardNumber+PIN, level: 7)
        let ConfirmationCode = Card.makeHash(str: installID + HPINcode + VC + amount + RcardNumber , level: 7)
        let SenderConfimrationCode = Card.makeHash(str: installHashKey + RcardNumber + ConfirmationCode + amount, level: 7)
        
        sendmoney(InstallationID: installID, RcardNumber: RcardNumber, Amount: amount, Vouchercounter: VC, ConfirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfimrationCode)
        
        
        
    }
    
    
    
    func sendmoney( InstallationID : String, RcardNumber:String, Amount:String,Vouchercounter: String , ConfirmationCode: String, SenderConfirmationCode: String){
        
        SwiftSpinner.show(" يتم الاتصال بالخادم ...")
        
        let requestURL: URL = URL(string: "https://icashapi.azurewebsites.net/api/SendMoney/"+InstallationID+"/"+RcardNumber+"/"+Amount+"/"+Vouchercounter+"/"+ConfirmationCode+"/"+SenderConfirmationCode)!
        print(requestURL)
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data,response,error) in
            SwiftSpinner.hide()
            
            if response != nil {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if statusCode == 200 {
                    
                    let dataString = String(data: data!, encoding: .utf8)
                    let result = Int (dataString!)
                    self.card.saveVC(VC: Vouchercounter)
                    
                    if (result! > 0){
                        OperationQueue.main.addOperation {
                            
                            _ =  SweetAlert().showAlert("تم التحويل ")
                        }
                    }
                    else {
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("خطأ", subTitle: "الرجاء التأكد من البيانات", style: AlertStyle.error)
                            print(result!)
                        }

                    }
                    
                    
                    
                    
                }
            }
            else{
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("فشلت العملية",subTitle: "نأمل التحقق من الوصول للانترنت ", style: AlertStyle.error)
                }
            }
        }
        task.resume()
        
        
    }
    
    
}
