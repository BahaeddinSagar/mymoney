//
//  GenerateInvoiceViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/22/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import QRCode



class GenerateInvoiceViewController : UIViewController, QRCodeReaderViewControllerDelegate {
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
                        self.shopIDTextField.text = result.value
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
    

    
    
    
    
    
        @IBOutlet weak var shopIDTextField: UITextField!
    @IBOutlet weak var AmountTextField: UITextField!
    @IBOutlet weak var PINcodeTextField: UITextField!
    var card = Card()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    @IBAction func GenerateCode(_ sender: UIButton) {
        self.view.endEditing(true)
        let McardNumber = shopIDTextField.text!
        let amount = Card.changeToFloat(Float(AmountTextField.text!)!)
        let PINcode = PINcodeTextField.text!
        
        let cardNumber = card.CardNo!
        let VC = String(card.voucherCounter)
        let HPINcode = Card.makeHash(str: cardNumber + PINcode, level: 7)
        let ConfirmationCode = Card.makeHash(str: card.installID! + HPINcode + amount + McardNumber + VC, level: 4)
        var finalCC : Int = Int(ConfirmationCode)!
        finalCC = finalCC*10 + card.voucherCounter % 10
        card.saveVC(VC: VC)
        /////// create QRCODE image
        var qrCode = QRCode(String(finalCC))!
        //qrCode.size = self.imageViewLarge.bounds.size
        qrCode.errorCorrection = .High
        
        _ = SweetAlert().showAlert("رمز الشراء هو ", subTitle: String(describing: finalCC) , style: AlertStyle.customImage(image: qrCode.image!))
        
        
        

    
    
    }
    



}
