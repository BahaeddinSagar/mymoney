//
//  transferMoney.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/19/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import QRCode



extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


class transferMoney : UIViewController , QRCodeReaderViewControllerDelegate , UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let regEX = "^(?:|[0-9]{0,7})(?:\\.\\d{0,3})?$"
        let newstring = AmountTextDield.text! + string
        if newstring.range(of: regEX, options:.regularExpression) != nil {
            return true
        } else {
            return false
        }
    }
    
    ////////////////////////
    lazy var reader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
        $0.showTorchButton = true
    })
    func scanAction() {
        do {
            if try QRCodeReader.supportsMetadataObjectTypes() {
                reader.modalPresentationStyle = .formSheet
                reader.delegate               = self
                
                reader.completionBlock = { (result: QRCodeReaderResult?) in
                    if let result = result {
                        print("Completion with result: \(result.value) of type \(result.metadataType)")
                        self.RxCardNumberTextField.text = result.value
                    }
                }
                
                present(reader, animated: true, completion: nil)
            }
        } catch let error as NSError {
            switch error.code {
            case -11852:
                let alert = UIAlertController(title: "Error".localized(), message: "This app is not authorized to use Back Camera.".localized(), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting".localized(), style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
                
                
                
            case -11814:
                let alert = UIAlertController(title: "Error".localized(), message: "Reader not supported by the current device".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay".localized(), style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            default:()
            }
        }
        
    }
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true) { [weak self] in
            let alert = UIAlertController(
                title: "QRCodeReader",
                message: String (format:"%@ (of type %@)", result.value, result.metadataType),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Okay".localized(), style: .cancel, handler: nil))
            // no need to show the result
            //self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    ///////////////////////
    
    
    
    
    
    
    
    
    
    
    
    
    
    @IBOutlet weak var RxCardNumberTextField: UITextField!
    @IBOutlet weak var AmountTextDield: UITextField!
    @IBOutlet weak var PINcode: UITextField!
    
    
    var card = Card()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(transferMoney.scanAction))
        self.navigationItem.rightBarButtonItem = camera

        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationItem.title = " Transfer "
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func transfer(_ sender: UIButton) {
        self.view.endEditing(true)
        
        validationSuccessful()
        
        
    }
    
    func validationSuccessful(){
        
        
        let RcardNumber = RxCardNumberTextField.text!
        let cardNumber = card.CardNo!
        
        
        // if AmountTextDield.text! != "" && RcardNumber != "" && PINcode.text! != "" && RcardNumber.characters.count == 9 {
            let amountt = Float(AmountTextDield.text!) 
            let amount = Card.changeToFloat(amountt!)
            let message1 =  "You will transfer ".localized()
            let message2 = "to the account with card number  ".localized()
            let message =  message1 + amount + message2 + RcardNumber
            _ = SweetAlert().showAlert("Transfer money".localized(), subTitle: message, style: AlertStyle.warning, buttonTitle:"Cancel".localized(), buttonColor:UIColor.colorFromRGB(0xFF0000) , otherButtonTitle:  "Done".localized(), otherButtonColor: UIColor.colorFromRGB(0xD0D0D0)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    // cancel - DO NOTING
                    
                }
                else {
                    
                    let PIN = self.PINcode.text!
                    let vouchercounter = self.card.voucherCounter+2
                    let VC = String(describing: vouchercounter)
                    let installID = self.card.installID!
                    let installHashKey = self.card.installHashKey!
                    
                    let HPINcode = Card.makeHash(str: cardNumber+PIN, level: 7)
                    let ConfirmationCode = Card.makeHash(str: installID + HPINcode + VC + amount + RcardNumber , level: 7)
                    let SenderConfimrationCode = Card.makeHash(str: installHashKey + RcardNumber + ConfirmationCode + amount, level: 7)
                    
                    self.sendmoney(InstallationID: installID, RcardNumber: RcardNumber, Amount: amount, Vouchercounter: VC, ConfirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfimrationCode)
                    
                    
                }
            }
                    /*
         let PIN = PINcode.text!
         let vouchercounter = card.voucherCounter+2
         let VC = String(describing: vouchercounter)
         let installID = card.installID!
         let installHashKey = card.installHashKey!
         
         let HPINcode = Card.makeHash(str: cardNumber+PIN, level: 7)
         let ConfirmationCode = Card.makeHash(str: installID + HPINcode + VC + amount + RcardNumber , level: 7)
         let SenderConfimrationCode = Card.makeHash(str: installHashKey + RcardNumber + ConfirmationCode + amount, level: 7)
         
         sendmoney(InstallationID: installID, RcardNumber: RcardNumber, Amount: amount, Vouchercounter: VC, ConfirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfimrationCode)
         */
        
        
        
    }
    
   
    
    
   
    
    
    
    func sendmoney( InstallationID : String, RcardNumber:String, Amount:String,Vouchercounter: String , ConfirmationCode: String, SenderConfirmationCode: String){
        
        SwiftSpinner.show(" Connecting to server ...".localized())
        
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
                            
                            _ =  SweetAlert().showAlert("Transfer Completed ".localized())
                        }
                    }
                    else {
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(), subTitle: "Check the data and try again".localized(), style: AlertStyle.error)
                            print(result!)
                        }
                        
                    }
                    
                    
                    
                    
                }else{
                    OperationQueue.main.addOperation {
                        _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                        

                    }
                }
                
            }
            else{
                OperationQueue.main.addOperation {
                    _ = SweetAlert().showAlert("Error".localized(),subTitle: "Check Internet Connectivity and try again ".localized(), style: AlertStyle.error)
                    

                }
            }
        }
        task.resume()
        
        
    }
    
    
}
