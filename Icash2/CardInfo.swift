//
//  CardInfo.swift
//  iCash
//
//  Created by Bahaeddin Sagar on 8/23/16.
//  Copyright © 2016 Umbrella. All rights reserved.
//

import Foundation
import Crypto
import UIKit


//extenstion for string to transfer from HEXA to DECIMAL
extension String {
    var drop0xPrefix:          String { return hasPrefix("0x") ? String(characters.dropFirst(2)) : self }
    var drop0bPrefix:          String { return hasPrefix("0b") ? String(characters.dropFirst(2)) : self }
    var hexaToDecimal:            Int { return Int(drop0xPrefix, radix: 16) ?? 0 }
    var hexaToBinaryString:    String { return String(hexaToDecimal, radix: 2) }
    var decimalToHexaString:   String { return String(Int(self) ?? 0, radix: 16) }
    var decimalToBinaryString: String { return String(Int(self) ?? 0, radix: 2) }
    var binaryToDecimal:          Int { return Int(drop0bPrefix, radix: 2) ?? 0 }
    var binaryToHexaString:    String { return String(binaryToDecimal, radix: 16) }
}

class Card {
    
    var CardNo:String? // رقم البطاقه
    var installID:String? // رمز خاص بالجهاز
    var installHashKey:String? // رمز الخاص بالجهاز بعد التشفير
    var voucherCounter:Int  // عداد العمليات
    var VHPinCode:String?
    var VHEPinCode:String?
    
    
    //init to get data from keychain
    init(){
       CardNo = KeychainWrapper.defaultKeychainWrapper.string(forKey: "CardNo")!

       installID = KeychainWrapper.defaultKeychainWrapper.string(forKey: "installID")!
       installHashKey = KeychainWrapper.defaultKeychainWrapper.string(forKey: "installHashKey")!
       voucherCounter = KeychainWrapper.defaultKeychainWrapper.integer(forKey: "voucherCounter")!
//       VHPinCode = KeychainWrapper.defaultKeychainWrapper.string(forKey: "HPinCode")!
//       VHEPinCode = KeychainWrapper.defaultKeychainWrapper.string(forKey: "HEPinCode")!
    }
    //Special init for start
    init(startint : Int){
        voucherCounter=0
        KeychainWrapper.defaultKeychainWrapper.set(0, forKey: "voucherCounter")
    }
    
    func saveVC(VC : String) {
         KeychainWrapper.defaultKeychainWrapper.set(Int(VC)!+1, forKey: "voucherCounter")
        
    }
    
   //Save variables
    func save() {
        _ = KeychainWrapper.defaultKeychainWrapper.set(CardNo!, forKey: "CardNo")
//      let saveSuccessfulAccNo: Bool = KeychainWrapper.defaultKeychainWrapper().setString(AccNo!, forKey: "AcccNo")
        _ = KeychainWrapper.defaultKeychainWrapper.set(installID!, forKey: "installID")
        _ = KeychainWrapper.defaultKeychainWrapper.set(installHashKey!, forKey: "installHashKey")
        _ = KeychainWrapper.defaultKeychainWrapper.set(voucherCounter, forKey: "voucherCounter")
        _ = KeychainWrapper.defaultKeychainWrapper.set(VHPinCode!, forKey: "HPinCode")
        _ = KeychainWrapper.defaultKeychainWrapper.set(VHEPinCode!, forKey: "HEPinCode")
        
 
    }
    
 
    //HEXA TO DECIMAL
    static func HexToDeci(_ Hex:String) -> String{
        
        let result = Hex.hexaToDecimal
        print(result)
        
        return "\(result)"
    }
    //get substring from a string
    static func getSubString(_ str:String , startindex: Int, endindex: Int) -> String{
        return str[str.characters.index(str.startIndex, offsetBy: startindex)...str.characters.index(str.startIndex, offsetBy: endindex)]
    }
    
    static func getlastString(_ str:String ,startindex: Int)-> String{
        let sstartindex = -1 * startindex
     return  str.substring(from:str.index(str.endIndex, offsetBy: sstartindex))
    }
    
    static func makeHash(str: String, level: Int) -> String{
        var strr = getlastString(str.md5!, startindex: level+3 )
        
        strr = getSubString(strr, startindex: 0, endindex: level-1)
        return HexToDeci(strr)
    }
    
    static func changeToFloat(_ num: Float) -> String {
      return String(format: "%.4f", num)
    }
    
    
    static func generateBarcode(from string: String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setDefaults()
            //Margin
            filter.setValue(7.00, forKey: "inputQuietSpace")
            filter.setValue(data, forKey: "inputMessage")
            //Scaling
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.applying(transform) {
                let context:CIContext = CIContext.init(options: nil)
                let cgImage:CGImage = context.createCGImage(output, from: output.extent)!
                let rawImage:UIImage = UIImage.init(cgImage: cgImage)
                
                //Refinement code to allow conversion to NSData or share UIImage. Code here:
                //http://stackoverflow.com/questions/2240395/uiimage-created-from-cgimageref-fails-with-uiimagepngrepresentation
                let cgimage: CGImage = (rawImage.cgImage)!
                let cropZone = CGRect(x: 0, y: 0, width: Int(rawImage.size.width), height: Int(rawImage.size.height))
                let cWidth: size_t  = size_t(cropZone.size.width)
                let cHeight: size_t  = size_t(cropZone.size.height)
                let bitsPerComponent: size_t = cgimage.bitsPerComponent
                //THE OPERATIONS ORDER COULD BE FLIPPED, ALTHOUGH, IT DOESN'T AFFECT THE RESULT
                let bytesPerRow = (cgimage.bytesPerRow) / (cgimage.width  * cWidth)
                
                let context2: CGContext = CGContext(data: nil, width: cWidth, height: cHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: cgimage.bitmapInfo.rawValue)!
                
                context2.draw(cgimage, in: cropZone)
                
                let result: CGImage  = context2.makeImage()!
                let finalImage = UIImage(cgImage: result)
                
                return finalImage
                
            }
        }
        
        return nil
    }
    
    
}
