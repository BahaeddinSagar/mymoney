//
//  ShowRecordsTableViewController.swift
//  Icash
//
//  Created by Bahaeddin Sagar on 6/16/17.
//  Copyright © 2017 Umbrella. All rights reserved.
//

import UIKit
import SwiftyJSON


class ShowRecordsTableViewController: UITableViewController {

    
    
    @IBOutlet weak var DisplayBalance: UILabel!
    var startDate = ""
    var endDate = ""
    var resultnum = ""
    var Email = ""
    var PINcode = ""
    var balance = ""

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //DisplayBalance.text = "Your Blanace is: \n".localized() + balance
        GetRecords()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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

    

}
