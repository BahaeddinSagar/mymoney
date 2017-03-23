//
//  CardInfo.swift
//  iCash
//
//  Created by Bahaeddin Sagar on 8/23/16.
//  Copyright © 2016 Umbrella. All rights reserved.
//

import Foundation
import Crypto


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
    
    var CardNo:String?

    var installID:String?
    var installHashKey:String?
    var voucherCounter:Int
//    var VHPinCode:String?
//    var VHEPinCode:String?
    
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
    
/*    //Save variables
    func save() ->Bool{
       let saveSuccessfulCardNo: Bool = KeychainWrapper.defaultKeychainWrapper.set(CardNo!, forKey: "CardNo")
//        let saveSuccessfulAccNo: Bool = KeychainWrapper.defaultKeychainWrapper().setString(AccNo!, forKey: "AcccNo")
        let saveSuccessfulInstallID: Bool = KeychainWrapper.defaultKeychainWrapper.set(installID!, forKey: "installID")
        let saveSuccessfulInstallHash: Bool = KeychainWrapper.defaultKeychainWrapper.set(installHashKey!, forKey: "installHashKey")
        let saveSuccessfulCounter: Bool = KeychainWrapper.defaultKeychainWrapper.set(voucherCounter, forKey: "voucherCounter")
     let saveSuccessfulPIN: Bool = KeychainWrapper.defaultKeychainWrapper.set(VHPinCode!, forKey: "HPinCode")
        let saveSuccessfulEPIN: Bool = KeychainWrapper.defaultKeychainWrapper.set(VHEPinCode!, forKey: "HEPinCode")
        return(saveSuccessfulCardNo && saveSuccessfulInstallID && saveSuccessfulInstallHash && saveSuccessfulPIN && saveSuccessfulEPIN && saveSuccessfulCounter)
        
 
    }
    
 */
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
        
    
    
}
