//
//  CardInfoViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 6/1/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import QRCode

class CardInfoViewController: UIViewController {

    @IBOutlet weak var qrcodeImage: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var barcodeImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var qrCode = QRCode(KeychainWrapper.defaultKeychainWrapper.string(forKey: "CardNo")!)!
        //qrCode.size = self.imageViewLarge.bounds.size
        qrCode.errorCorrection = .High
        
        let card = Card()
        cardNumberLabel.text = card.CardNo!
        cardNumberLabel.font = UIFont(name: "OCRAExtended", size: 20)
        
        qrcodeImage.image = qrCode.image
        
        barcodeImage.image = Card.generateBarcode(from: card.CardNo!)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    

    
    
    
}
