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
   func scanAction() {
        do {
            if try QRCodeReader.supportsMetadataObjectTypes() {
                reader.modalPresentationStyle = .formSheet
                reader.delegate               = self
                
                reader.completionBlock = { (result: QRCodeReaderResult?) in
                    if let result = result {
                        print("Completion with result: \(result.value) of type \(result.metadataType)")
                        // to read the first part as the shopID, second part as amount
                       
                        let seperatedResult = result.value.components(separatedBy: ",")
                        if seperatedResult[0] != "" && seperatedResult[1] != "" {
                        self.shopIDTextField.text = seperatedResult[0]
                        self.AmountTextField.text = seperatedResult[1]
                        }
                        else {
                            _ = SweetAlert.showAlert("Error".localized(), subTitle: " Wrong QRcode ".localized(), style: AlertStyle.warning)
                        }
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
                alert.addAction(UIAlertAction(title: "Done".localized(), style: .cancel, handler: nil))
                
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
            alert.addAction(UIAlertAction(title: "Done".localized(), style: .cancel, handler: nil))
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
    

    
    
    
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var shopIDTextField: UITextField!
    @IBOutlet weak var AmountTextField: UITextField!
    @IBOutlet weak var PINcodeTextField: UITextField!
    var card = Card()
    
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
        
        
        
    }

   
    @IBAction func GenerateCode(_ sender: UIButton) {
        self.view.endEditing(true)
        // McardNumber is the number of the shop, not the cardID
        let McardNumber = shopIDTextField.text!
        
        let PINcode = PINcodeTextField.text!
        
        //if AmountTextField.text! != "" && McardNumber != "" && PINcode != "" {
        
        // if amount can be made to float, continue, otherwise show error
        if let amountt = Float(AmountTextField.text!), McardNumber != "", PINcode != "" {
        let amount = Card.changeToFloat(amountt)
        
        let cardNumber = card.CardNo!
        let VC = String(card.voucherCounter)
            // makd the Hash PIN COde
        let HPINcode = Card.makeHash(str: cardNumber + PINcode, level: 7)
            // makeing the Confirmation code
        let ConfirmationCode = Card.makeHash(str: card.installID! + HPINcode + amount + McardNumber + VC, level: 4)
            // the code is given by this operation
        var finalCC : Int = Int(ConfirmationCode)!
        finalCC = finalCC*10 + card.voucherCounter % 10
        card.saveVC(VC: VC)
        /////// create QRCODE image
        var qrCode = QRCode(String(finalCC))!
        //qrCode.size = self.imageViewLarge.bounds.size
        qrCode.errorCorrection = .High
        
        _ = SweetAlert().showAlert("Purchase code is :", subTitle: String(describing: finalCC) , style: AlertStyle.customImage(image: qrCode.image!))
        
        
        
        } else {
            _ = SweetAlert().showAlert("Error", subTitle: " الرجاء التحقق من صحة البيانات ", style: AlertStyle.warning)
        }
    
    
    }
    

       
    
    


}
