//
//  BuyAndExplainViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 4/15/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import QRCode



class BuyAndExplainViewController: UIViewController, QRCodeReaderViewControllerDelegate, UITextFieldDelegate  {

       
    
    var shopID : String = ""
    var Amount : String = ""
    var ConfirmationCode = ""
    //let Gen = GenerateInvoiceViewController.self
    
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
                        self.ShopIDTextField.text = seperatedResult[0]
                        self.AmountTextField.text = seperatedResult[1]
                        
                        
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
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil))
                
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
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        secondview.isHidden = true
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(self.scanAction))
        self.navigationItem.rightBarButtonItem = camera
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.title = "Buy"
        
        
               // 1
        //let nav = self.navigationController?.navigationBar
        // 2
        //nav?.barStyle = UIBarStyle.black
        //nav?.tintColor = UIColor.yellow
        // 3
        //let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        //imageView.contentMode = .scaleAspectFit
        // 4
        //let image = UIImage(named: "Apple_Swift_Logo")
        //imageView.image = image
        // 5
        //navigationItem.titleView = imageView
    }
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    
    @IBOutlet weak var secondview: UIView!
    
    @IBOutlet weak var ShopIDTextField: UITextField!
    @IBOutlet weak var AmountTextField: UITextField!
    @IBOutlet weak var PINCodeTextField: UITextField!
    var card = Card()

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let regEX = "^(?:|[0-9]{0,7})(?:\\.\\d{0,3})?$"
        let newstring = AmountTextField.text! + string
        if newstring.range(of: regEX, options:.regularExpression) != nil {
            return true
        } else {
            return false
        }
    }
    

    
    
    
    
    
   
    @IBAction func DisplayCode(_ sender: Any) {
        self.view.endEditing(true)
        // McardNumber is the number of the shop, not the cardID
        let McardNumber = ShopIDTextField.text!
        
        let PINcode = PINCodeTextField.text!
        
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
            
            _ = SweetAlert().showAlert("Purchase code is :".localized(), subTitle: String(describing: finalCC) , style: AlertStyle.customImage(image: qrCode.image!))
            
            self.ConfirmationCode = String(describing: finalCC)
            self.shopID = McardNumber
            self.Amount = amount
            
            
        } else {
            _ = SweetAlert().showAlert("Error".localized(), subTitle: "Check the data and try again".localized(), style: AlertStyle.warning)
        }
        

        
        
        
    }
    
    
    
    
    @IBAction func change(_ sender: Any) {
        switch segment.selectedSegmentIndex {
        case 0:
            
            secondview.isHidden = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.title = "Buy".localized()
        case 1:
            
            secondview.isHidden = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            let EX = self.storyboard?.instantiateViewController(withIdentifier: "ExplainFail") as! ExplainFailViewController
            EX.shopID = self.shopID
            EX.amount = self.Amount
            EX.confirmationCode = self.ConfirmationCode
            
            self.navigationItem.title = "Explain faliure".localized()
            
        default:
            
            secondview.isHidden = true
        }
        
        
    }
    
    //TODO : add validator
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
