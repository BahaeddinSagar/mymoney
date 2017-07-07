//
//  ShowRecordsViewController.swift
//  Icash2
//
//  Created by Bahaeddin Sagar on 5/27/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShowRecordsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var DisplayBalance: UILabel!
    var startDate = ""
    var endDate = ""
    var resultnum = ""
    var Email = ""
    var PINcode = ""
    var balance = ""
    var RecordArray : Array<Any> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DisplayBalance.text = "Your Blanace is: \n".localized() + balance
        GetRecords()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func GetRecords(){
        SwiftSpinner.show(" Connecting to Server ...".localized())
        let requestURL : URL = URL(string: "https://icash.azurewebsites.net/api/GetStatment/0/0/12-12-2017/12-12-2017/10/True/me@example.com/0/0")!
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
                    var RecordArray : Array<Any> = []
                    let jsons = JSON(data: data!)
                    for (index,json):(String, JSON) in jsons {
                        let Record = RecordClass(json: json)
                        RecordArray.append(Record)
                        if Record.opning != nil  {
                            print(Record.opning!)
                            print(index)
                            /*
                             _ =  SweetAlert().showAlert("Your Blanace is:",subTitle: dataString!, style: AlertStyle.none)
                             */
                        }

                    }
                    
                    }else {
                        OperationQueue.main.addOperation {
                            _ = SweetAlert().showAlert("Error".localized(),subTitle: " Please Try Again ".localized(), style: AlertStyle.error)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    let cellReuseIdentifier = "cell"
  /*
    func displayRecords( Records : array) {
        tableView.array
        
        
        
        
    }
    */
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.RecordArray.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.RecordArray[indexPath.row] as! String
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
    


