//
//  ExplainFailViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 4/3/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit


class ExplainFailViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var shopIDTextField: UITextField!
    @IBOutlet weak var amountTextFiled: UITextField!
    @IBOutlet weak var ConfirmationCodeTextField: UITextField!
    @IBOutlet weak var errorTextField: UITextField!
    
    var shopID = ""
    var amount = ""
    var confirmationCode = ""
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let regEX = "^(?:|0|[1-9]{0,7})(?:\\.\\d{0,3})?$"
        let newstring = amountTextFiled.text! + string
        if newstring.range(of: regEX, options:.regularExpression) != nil {
            return true
        } else {
            return false
        }
    }
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: Selector(("btnOpenCamera")))
        self.navigationItem.rightBarButtonItem = camera
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        shopIDTextField.text = self.shopID
        amountTextFiled.text = self.amount
        ConfirmationCodeTextField.text = self.confirmationCode
        
        
            }
   
   
    @IBAction func explain(_ sender: UIButton) {
        // read from text fields
        let shopID = shopIDTextField.text!
        var amount = amountTextFiled.text!
        let confirmationcode = ConfirmationCodeTextField.text!
        let failcode = errorTextField.text!
        // if user entered every field then
        if amountTextFiled.text! != "" && shopID != "" && ConfirmationCodeTextField.text! != "" && failcode != "" {
        amount = String(Card.changeToFloat(Float(amount)!))
            // read the output from doOperation ( returns a string )
        let result = doOperation (failcode: failcode, confirmationCode: confirmationcode, amount: amount, shopID: shopID)
       
        _ = SweetAlert().showAlert(" ", subTitle:result, style: AlertStyle.none)
        }
        
    }
    // function that returns the reason for failing
    func doOperation(failcode : String, confirmationCode : String, amount : String , shopID: String) ->  String {
        let card = Card()
        if failcode == Card.makeHash(str: "WrongCode" + card.CardNo! + confirmationCode + amount + shopID, level: 2){
            return " Confirmation Code Error ".localized()
        }
        if failcode == Card.makeHash(str: "BalanceNotEnough" + card.CardNo! + confirmationCode + amount + shopID, level: 2){
            return " Not Enough Balance ".localized()
        }
        if failcode == Card.makeHash(str: "InternalError" + card.CardNo! + confirmationCode + amount + shopID, level: 2){
            return " Error while making purchase ".localized()
        }
        return " Error while making purchase ".localized()
        
    }
    
    //TODO : add validator
    
    
    
}
