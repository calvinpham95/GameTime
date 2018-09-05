//
//  ContactsViewController.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/17/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit
import Foundation
import SwiftAddressBook
import AddressBook
import Contacts
import ContactsUI


var phoneNumberPassedToNextVC: String = ""
var globalInviteListArray: [[String:String]] = []
var globalPhoneNumberArray: [Int] = []
var globalNameArray: [String] = []

class ContactsViewController: UITableViewController {
    
    @IBOutlet var pickTeamButtonOutlet: UIBarButtonItem!
    @IBAction func pickTeamButton(_ sender: Any) {
        let setUpVC = storyboard!.instantiateViewController(withIdentifier: "PickTeamViewController")
        self.navigationController?.pushViewController(setUpVC, animated: true);
        
    }
    
//    var team1Name : String = ""
//    var team2Name : String = ""

    @IBOutlet weak var myTableView: UITableView!
    let cellIdentifier = "ContactsCell"
    var blackTheme = false
   // var itemInfo = IndicatorInfo(title: "View")
    var userData: [[String: Any]] = []
    
    var phoneNumbers = [String]()
    var cleanedPhoneNumbers = [String]()
    var fullNames = [String]()

 //   var phoneNumberUnfilteredArray: [[String]] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
//        print("Team Name 1: " + team1Name)
//        print("Team Name 2: " + team2Name)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        myTableView.register(UINib(nibName: "ContactsCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        myTableView.estimatedRowHeight = 60.0
        myTableView.rowHeight = UITableViewAutomaticDimension
        //tableView.allowsSelection = true
        
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        globalInviteListArray = []
        globalPhoneNumberArray = []
        myTableView.reloadData()
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
        globalInviteListArray = []
        globalPhoneNumberArray = []
         
        // #warning Incomplete implementation, return the number of rows
        self.userData = ContactsDataProvider.sharedInstance.getData()

        
        var contacts = [CNContact]()
        
        //let keys = [CNContactPhoneNumbersKey, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as [Any]
        let keys = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        let contactStore = CNContactStore()
        
        for userProfile in self.userData
        {

            var data = userProfile["phone"]
            var data2 = userProfile["firstname"]
            var data3 = userProfile["lastname"]
            var temp1: String = String(describing: data!)
           var temp2: String = String(describing: data2!)
             var temp3: String = String(describing: data3!)
            
            
            for tempnumber in phoneNumbers {
                if (tempnumber.count == 12 ) {
                    var powerranger = tempnumber
                    powerranger.remove(at: tempnumber.startIndex)
                    powerranger.remove(at: tempnumber.startIndex)
                    self.cleanedPhoneNumbers.append(powerranger)
                }
                else if (tempnumber.count == 11) {
                    var powerranger = tempnumber
                    powerranger.remove(at: tempnumber.startIndex)
                    self.cleanedPhoneNumbers.append(powerranger)
                }
                else if (tempnumber.count != 11 || tempnumber.count != 12){
                    self.cleanedPhoneNumbers.append(tempnumber)
                }

            }
            if (cleanedPhoneNumbers.contains(temp1)) {
            

                globalInviteListArray.append(["phone":temp1, "fullname": temp2+" "+temp3])


            }

            if (temp1 != globalPhoneNumber) {
            globalInviteListArray.append(["phone":temp1, "fullname": temp2+" "+temp3])
            }


        }
        
        
        
        if (globalInviteListArray.count == 0)
        {
            let alert = UIAlertController(title: "", message: "Seems like no friends in your contact book are Game Time users. Invite some of your friends to join the platform to create bets!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            // viewDidLoad
            self.navigationItem.rightBarButtonItem = nil
            
            
        }
        else
        {
            self.navigationItem.rightBarButtonItem = self.pickTeamButtonOutlet
            
        }
        
        

        return globalInviteListArray.count
        //return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContactsCell,
            let data = globalInviteListArray[indexPath.row] as? NSDictionary else { return ContactsCell()}
        
        cell.configureWithData(data)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let cell = myTableView.cellForRow(at: indexPath) as! ContactsCell
        if (globalPhoneNumberArray.contains(Int(cell.PhoneNumberLabel.text!)!))
        {
            cell.CheckMarkImage.image = UIImage(named: "Check mark unselected")
            var count = 0
            for i in globalPhoneNumberArray
            {
                if (i == Int(cell.PhoneNumberLabel.text!)!)
                {
                    globalPhoneNumberArray.remove(at: count)
                    break
                }
                count = count + 1
            }
        }
        else
        {
            cell.CheckMarkImage.image = UIImage(named: "Check mark selected")
            // phoneNumberPassedToNextVC = cell.PhoneNumberLabel.text!
            globalPhoneNumberArray.append(Int(cell.PhoneNumberLabel.text!)!)
            
        }
 
        
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

}


