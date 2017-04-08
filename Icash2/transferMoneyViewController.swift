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

class transferMoney : UIViewController , QRCodeReaderViewControllerDelegate {
    
    ////////////////////////
    lazy var reader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
        $0.showTorchButton = true
    })
    @IBAction func scanAction(_ sender: AnyObject) {
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
                let alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
                
                
                
            case -11814:
                let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
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
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self?.present(alert, animated: true, completion: nil)
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
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func transfer(_ sender: UIButton) {
        self.view.endEditing(true)
        
        
        
        
        let RcardNumber = RxCardNumberTextField.text!
        let cardNumber = card.CardNo!
        
        
        if AmountTextDield.text! != "" && RcardNumber != "" && PINcode.text! != "" && RcardNumber.characters.count == 9 {
        let amount = Card.changeToFloat(Float(AmountTextDield.text!)!)
        let message1 =  " سوف يتم تحويل مبلغ "
        let message2 = "الى البطاقة رقم "
        let message =  message1 + amount + message2 + RcardNumber
        _ = SweetAlert().showAlert("تحويل رصيد", subTitle: message, style: AlertStyle.warning, buttonTitle:"الغاء العملية", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "اتمام العملية", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
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
                    
                    
                    
                    
                }else{
                    OperationQueue.main.addOperation {
                        _ = SweetAlert().showAlert("فشلت العملية",subTitle: "نأمل التحقق من الوصول للانترنت ", style: AlertStyle.error)
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
