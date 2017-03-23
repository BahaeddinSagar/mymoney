//
//  Pay.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/19/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit

class PayViewController : UIViewController {
    
    @IBOutlet weak var AmountTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var CCcodeTextField: UITextField!
    
    var card = Card()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
    @IBAction func Send(_ sender: UIButton) {
        let CoustemerID = cardNumberTextField.text!
        let installID = card.installID!
        let amount = AmountTextField.text!
        let ConfirmationCode = CCcodeTextField.text!
        
        let SenderConfirmationCode = Card.makeHash(str: card.installHashKey! + CoustemerID + ConfirmationCode + amount, level: 7)
        
        sendInvoice(installID: installID, CoustemerID: CoustemerID, amount: amount, ConfirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfirmationCode)
        
        
    }
    
    func sendInvoice(installID : String , CoustemerID : String, amount :String, ConfirmationCode : String, SenderConfirmationCode :String){
        SwiftSpinner.show(" يتم الاتصال بالخادم ...")
        
        let requestURL: URL = URL(string: "http://icashapi.azurewebsites.net/api/PayInvoice/" + "/" + installID + "/" + CoustemerID + "/" + amount + "/" + ConfirmationCode+"/"+SenderConfirmationCode)!
        let session = URLSession.shared
        let task = session.dataTask(with: requestURL) {
            (data,response,error) in
            SwiftSpinner.hide()
            if response != nil {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if (statusCode == 200){
                    let dataString = String(data: data!, encoding: .utf8)
                    
                    self.card.saveVC(VC: String(self.card.voucherCounter))
                    
                    OperationQueue.main.addOperation {
                        _ = SweetAlert().showAlert(dataString!)
                    }
                   
                }
                
            }
            else {
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("فشلت العملية",subTitle: "نأمل التحقق من الوصول للانترنت ", style: AlertStyle.error)
                }
            }
        }
        task.resume()
    }
    
}
