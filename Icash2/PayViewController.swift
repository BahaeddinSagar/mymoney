//
//  Pay.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/19/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

class PayViewController : UIViewController , QRCodeReaderViewControllerDelegate{
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
                        self.cardNumberTextField.text = result.value
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
        self.view.endEditing(true)
        let CoustemerID = cardNumberTextField.text!
        let installID = card.installID!
        //AmountTextField.
        if AmountTextField.text! != "" && CoustemerID != "" && CCcodeTextField.text! != "" {
            let amount = Card.changeToFloat(Float(AmountTextField.text!)!)
            let ConfirmationCode = CCcodeTextField.text!
            
            let SenderConfirmationCode = Card.makeHash(str: card.installHashKey! + CoustemerID + ConfirmationCode + amount, level: 7)
            
            sendInvoice(installID: installID, CoustemerID: CoustemerID, amount: amount, ConfirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfirmationCode)
        }else {
            _ = SweetAlert().showAlert("خطأ", subTitle: "الرجاء التأكد من البيانات", style: AlertStyle.error)
        }
        
       
        
        
    }
    
    func sendInvoice(installID : String , CoustemerID : String, amount :String, ConfirmationCode : String, SenderConfirmationCode :String){
        SwiftSpinner.show(" يتم الاتصال بالخادم ...")
        
        let requestURL: URL = URL(string: "https://icashapi.azurewebsites.net/api/PayInvoice/" + installID + "/" + CoustemerID + "/" + amount + "/" + ConfirmationCode+"/"+SenderConfirmationCode)!
        print(requestURL)
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
