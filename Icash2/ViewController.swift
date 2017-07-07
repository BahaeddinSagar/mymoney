//
//  ViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/19/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import Localize_Swift


class ViewController: UIViewController {
    
    
    @IBOutlet weak var cardNumberLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidLoad), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if KeychainWrapper.defaultKeychainWrapper.string(forKey: "installHashKey") == nil  {
            performSegue(withIdentifier: "showActivatePage", sender: self)
        } else {
            cardNumberLabel.setTitle(KeychainWrapper.defaultKeychainWrapper.string(forKey: "CardNo"), for: .normal)
            cardNumberLabel.titleLabel?.font = UIFont(name : "OCRAExtended" , size: 20)
            
        }
        /*
        print (Localize.availableLanguages())
        print (Localize.currentLanguage())
        print(NSLocalizedString("OK", comment: " " ))
        print("OK".localized(using: "ar-LY"))
        print("OK".localized())
        */
        // 1
        let nav = self.navigationController?.navigationBar
        // 2
        //nav?.barStyle = UIBarStyle.init(rawValue: <#T##Int#>)!
        nav?.tintColor = UIColor.white
        nav?.barTintColor = UIColor(red:0.22, green:0.32, blue:0.47, alpha:1.0)
        nav?.titleTextAttributes=[NSForegroundColorAttributeName : UIColor.white]
        self.navigationItem.title = ""
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        imageView.contentMode = .scaleAspectFit
        // 4
        let image = UIImage(named: "logomain")
        imageView.image = image
        // 5
        navigationItem.titleView = imageView
        
        
        
    }
    
        
    @IBAction func checkBalance(_ sender: UIButton) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Check Balance".localized(), message: "Please Enter your PIN ".localized(), preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
            textField.keyboardType = UIKeyboardType.numberPad
            textField.isSecureTextEntry = true
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { [weak alert] (_) in
            }))
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
           
            /////////////////////////////////My code is here
            self.resignFirstResponder()
            let PINcode = textField!.text
            if PINcode == nil || PINcode == ""
            {
                _ = SweetAlert().showAlert(" PIN code cannot be Empty ".localized())
                
            } else {
               
                
                let card = Card()
                
                
                let voucherCounterString = String(describing: card.voucherCounter+1)
                _ = card.saveVC(VC: voucherCounterString)
                print(voucherCounterString)
                let HPINcode =  Card.makeHash(str: card.CardNo!+PINcode!, level: 7)
                let ConfirmationCode = Card.makeHash(str: card.installID! + HPINcode + voucherCounterString , level: 7)
                let SenderConfirmationCode = Card.makeHash(str: card.installHashKey!+voucherCounterString+ConfirmationCode, level: 7)
                
                self.checkBalanceReq(installationID: card.installID!, VoucherCounter: voucherCounterString, ConfirmationCode: ConfirmationCode, SenderConfirmationCode: SenderConfirmationCode)
                
                
                
            }
            
        
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    func checkBalanceReq(installationID : String , VoucherCounter : String , ConfirmationCode :String , SenderConfirmationCode : String) {
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
                    if result != nil && result! >= 0 {
                        
                        let card = Card()
                        _ = card.saveVC(VC: VoucherCounter)
                        
                        
                        OperationQueue.main.addOperation {
                            _ =  SweetAlert().showAlert("Your Blanace is:".localized(),subTitle: dataString!, style: AlertStyle.none)
                        }
                        
                    }else {
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized() ,subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
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
    
    
        
    
    
    
    
    
}
