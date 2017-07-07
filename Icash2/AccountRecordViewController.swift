//
//  AccountRecordViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 5/27/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import SwiftyJSON

class AccountRecordViewController: UIViewController  {

    @IBOutlet weak var PINcodeTextField: UITextField!
    @IBOutlet weak var advan: UISwitch!
    @IBOutlet weak var from: UITextField!
    @IBOutlet weak var to: UITextField!
    @IBOutlet weak var NumberOfTransactions: UITextField!
    @IBOutlet weak var Email: UITextField!
    
    let datePicker = UIDatePicker()
    let card = Card()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let next = UIBarButtonItem(title: "next", style: .plain, target: self, action: #selector(getRecords))
        //self.navigationItem.rightBarButtonItem = next

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func editchanged(_ sender: SkyFloatingLabelTextField) {
       /*
         Validation of PIN code field
        if let text = PINcodeTextField.text {
            if let floatingLabelTextField = PINcodeTextField as? SkyFloatingLabelTextField {
                if(text.characters.count != 4) {
                    floatingLabelTextField.errorMessage = "min PIN code is 4 characters".localized()
                }
                else {
                    // The error message will only disappear when we reset it to nil or empty string
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
         */
    }
    @IBAction func editchangedEmail(_ sender: Any) {
        if let text = Email.text {
            if let floatingLabelTextField = Email as? SkyFloatingLabelTextField {
                if(text.characters.count < 3 || !text.contains("@")) {
                    floatingLabelTextField.errorMessage = "Invalid email"
                }
                else {
                    // The error message will only disappear when we reset it to nil or empty string
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)
        from.text = result
        
        createDatePicekr()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func advanced(_ sender: Any) {
        if advan.isOn {
           from.isHidden=false
            to.isHidden=false
            NumberOfTransactions.isHidden=false
            Email.isHidden=false
            
        } else {
            from.isHidden=true
            to.isHidden=true
            NumberOfTransactions.isHidden=true
            Email.isHidden=true
            
        }
        
        
        
    }
    
    @IBAction func ButtonClicked(_ sender: Any) {
        getRecords()
    }
    
    
    
    
    
    func getRecords () {
        let card = Card()
        let PINcode = PINcodeTextField.text!
        let voucherCounterString = String(describing: card.voucherCounter+1)
        _ = card.saveVC(VC: voucherCounterString)
        print(voucherCounterString)
        let HPINcode =  Card.makeHash(str: card.CardNo!+PINcode, level: 7)
        let ConfirmationCode = Card.makeHash(str: card.installID! + HPINcode + voucherCounterString , level: 7)
        let SenderConfirmationCode = Card.makeHash(str: card.installHashKey!+voucherCounterString+ConfirmationCode, level: 7)
        
        self.checkBalanceReq(installationID: card.installID!, VoucherCounter: voucherCounterString, ConfirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfirmationCode , PINcode: PINcode)
        

        
        
        
        
        
        
       /*
        let cardNo = card.CardNo!
        let installID = card.installID!
        let installHashKey = card.installHashKey!
        var voucherCounter = card.voucherCounter+1
        var VC = String(voucherCounter)
        
        let startDate = from.text!
        let endDate = to.text!
        let resultnum = NumberOfTransactions.text!
        
        let HPINcode = Card.makeHash(str: cardNo+PINcode, level: 7)
        let ConfirmationCode = Card.makeHash(str: installID+HPINcode+VC+startDate+endDate+resultnum, level: 7)
        let SenderConfirmationCode = Card.makeHash(str: installHashKey+VC+ConfirmationCode, level: 7)
        */
        
        
    }
    
    
    
    func checkBalanceReq(installationID : String , VoucherCounter : String , ConfirmationCode :String , SenderConfirmationCode : String, PINcode : String) {
        SwiftSpinner.show(" Connecting to Server ...".localized())
        let requestURL : URL = URL(string: "https://icashapi.azurewebsites.net/api/ChechBalance/"+installationID+"/"+VoucherCounter+"/"+ConfirmationCode+"/"+SenderConfirmationCode)!
        print(requestURL)
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
                    if result != nil && result! >= 0.0 {
                        
                        let card = Card()
                        _ = card.saveVC(VC: VoucherCounter)
                        
                        
                        OperationQueue.main.addOperation {
                            let showrecords = self.storyboard?.instantiateViewController(withIdentifier: "showrecords") as! ShowRecordsViewController
                            
                            showrecords.startDate = self.from.text!
                            showrecords.endDate = self.to.text!
                            showrecords.resultnum = self.NumberOfTransactions.text!
                            showrecords.Email = self.Email.text!
                            showrecords.PINcode = PINcode
                            showrecords.balance = dataString!
                            
                            self.navigationController?.pushViewController(showrecords, animated: true)
                            
                            /*
                            _ =  SweetAlert().showAlert("Your Blanace is:",subTitle: dataString!, style: AlertStyle.none)
                            */
                        }
                        
                    }else {
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(),subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
                        }
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

    
    
    
    
    func createDatePicekr(){
        
        //date picket mode
        datePicker.datePickerMode = .date
     
        //toolbar
        let toolbarFrom = UIToolbar()
        toolbarFrom.sizeToFit()
        
        //bar button item
        let donebutton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedFrom))
        toolbarFrom.setItems([donebutton], animated: false)
        // assign date picker to field
        from.inputAccessoryView = toolbarFrom
        from.inputView = datePicker
        
        //toolbar
        let toolbarTo = UIToolbar()
        toolbarTo.sizeToFit()
        
        //bar button item
        let donebuttonto = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedTo))
        toolbarTo.setItems([donebuttonto], animated: false)
        // assign date picker to field
        to.inputAccessoryView = toolbarTo
        to.inputView = datePicker
    }
    func donePressedFrom() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        from.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    func donePressedTo() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        to.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }


}
