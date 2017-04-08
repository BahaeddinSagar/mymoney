//
//  ExplainFailViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 4/3/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit


class ExplainFailViewController : UIViewController {

    @IBOutlet weak var shopIDTextField: UITextField!
    @IBOutlet weak var amountTextFiled: UITextField!
    @IBOutlet weak var ConfirmationCodeTextField: UITextField!
    @IBOutlet weak var errorTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


   
   
    @IBAction func explain(_ sender: UIButton) {
        let shopID = shopIDTextField.text!
        var amount = amountTextFiled.text!
        let confirmationcode = ConfirmationCodeTextField.text!
        let failcode = errorTextField.text!
        if amountTextFiled.text! != "" && shopID != "" && ConfirmationCodeTextField.text! != "" && failcode != "" {
        amount = String(Card.changeToFloat(Float(amount)!))
        let result = doOperation (failcode: failcode, confirmationCode: confirmationcode, amount: amount, shopID: shopID)
       
        _ = SweetAlert().showAlert(" ", subTitle:result, style: AlertStyle.none)
        }
        
    }
    
    func doOperation(failcode : String, confirmationCode : String, amount : String , shopID: String) ->  String {
        let card = Card()
        if failcode == Card.makeHash(str: "WrongCode" + card.CardNo! + confirmationCode + amount + shopID, level: 2){
            return " رمز تأكيد عملية الدفع خاطئ "
        }
        if failcode == Card.makeHash(str: "BalanceNotEnough" + card.CardNo! + confirmationCode + amount + shopID, level: 2){
            return " لا تملك رصيد كافي لاتمام عملية الدفع "
        }
        if failcode == Card.makeHash(str: "InternalError" + card.CardNo! + confirmationCode + amount + shopID, level: 2){
            return " حصل مشكلة في الخدمة أثناء عملية الدفع "
        }
        return " حصل مشكلة في الخدمة أثناء عملية الدفع "
        
    }
    
    
    
}
