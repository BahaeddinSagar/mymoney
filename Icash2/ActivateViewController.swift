//
//  Activate.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 3/19/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit

class Activate : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
    
    @IBAction func confirm(_ sender: Any) {
        
        
   
        
        self.performSegue(withIdentifier: "goToConfirm", sender: self)
        
    }
    
    
}
