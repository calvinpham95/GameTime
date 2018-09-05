//
//  InvitesViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 11/23/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

var inviteeFirstTeam: String = ""
var inviteeSecondTeam: String = ""
var inviteePotSelected: String = ""
var inviteeBetAmt: Int = Int()

class InvitesViewController: UITableViewController, CustomCellUpdater {
    
    

    @IBOutlet var myTableView: UITableView!
    
    func updateTableView() {
        self.viewWillAppear(false)
        self.myTableView.reloadData()
    
        
    }
    
    func inviteeAccepted(team1: String, team2: String, potID: String, betPlaced: Int) {
        inviteeFirstTeam = team1
        inviteeSecondTeam = team2
        inviteePotSelected = potID
        inviteeBetAmt = betPlaced
        
        
        let setUpVC = storyboard!.instantiateViewController(withIdentifier: "InviteePickTeamViewController")
        self.navigationController?.pushViewController(setUpVC, animated: true);
    }
    
    let cellIdentifier = "invitesCell"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myTableView.reloadData()
    }
    
    override func viewDidLoad() {
        myTableView.delegate = self
        myTableView.dataSource = self
        super.viewDidLoad()
        myTableView.register(UINib(nibName: "InvitesCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        
        myTableView.estimatedRowHeight = 60.0
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.allowsSelection = true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.tabBarController?.tabBar.isHidden = false
        let semaphore = DispatchSemaphore(value: 0)
        
        // NEED TO CHANGE THIS LINE TO THE CORRECT API CALL AND THE REST SHOULD WORK
        let url = URL(string: "http://"+ipAddress+":3000/api/user/getUserProfile/" + globalPhoneNumber)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            globalUserProfile = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        var pendingBets: NSArray = globalUserProfile["pendingBets"] as! NSArray
        if (pendingBets.count != 0)
        {
            self.tabBarController?.tabBar.items?[1].badgeValue = String(describing: pendingBets.count)
        }
        else
        {
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
        }
        
 
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
        var pendingBets = globalUserProfile["pendingBets"] as! NSArray
        return pendingBets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var pendingBets = globalUserProfile["pendingBets"] as! NSArray
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InvitesCell
            else { return InvitesCell() }
        
        let semaphore = DispatchSemaphore(value: 0)
        var potID = String(describing: pendingBets[indexPath.row])
        var potData : [String:Any] = [:]
        var url = URL(string: "http://"+ipAddress+":3000/api/pot/getPot/" + potID)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        var task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            potData = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        var temp = String(describing: potData["gameId"]!)
        var gameData: [String: Any] = [:]
        url = URL(string: "http://"+ipAddress+":3000/api/game/getGame/" + temp)!
        request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            gameData = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        var temp1 = potData["acceptedParticipants"] as! NSArray
        var temp2 = temp1[0] as! NSDictionary

        var inviterPhone = String(describing: temp2["uid"]!)
     
        var inviterBet = temp2["amount"]
        var inviterData: [String: Any] = [:]
        url = URL(string: "http://"+ipAddress+":3000/api/user/getUserProfile/" + inviterPhone)!
        request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            inviterData = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        
        var leagueName = potData["league"] as! String
        var team1 = gameData["team1"] as! String
        var team2 = gameData["team2"] as! String
        var date = gameData["startDate"] as! String
        var inviterFirstName = inviterData["firstname"] as! String
        
        cell.configureWithData(team1: team1, team2: team2, date: date, inviter: inviterFirstName, league: leagueName, pot: potID, bet: inviterBet as! Int)
        cell.delegate = self
    
        return cell
    }
    

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
