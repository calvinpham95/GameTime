//
//  BetsViewController.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/12/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit
import MessageUI


var globalUserProfile: [String: Any] = [:]

class BetsViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    @IBOutlet var myTableView: UITableView!
    var refreshOutlet  = UIRefreshControl()
    
    var betsData: [[String:Any]] = []
    
    let cellIdentifier = "betsCell"
    var chatId: String = ""
    

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
        self.betsData = []
        self.getUserData()
        
        var pendingBets: NSArray = globalUserProfile["pendingBets"] as! NSArray
        print(pendingBets.count)
        if (pendingBets.count != 0)
        {
            self.tabBarController?.tabBar.items?[1].badgeValue = String(describing: pendingBets.count)
        }
        else
        {
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
        }
        
        myTableView.reloadData()
        
        
 
    }
    
    


    override func viewDidLoad() {
    
        super.viewDidLoad()
        myTableView.register(UINib(nibName: "BetsCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        
        myTableView.estimatedRowHeight = 60.0
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.allowsSelection = true
        myTableView.refreshControl = self.refreshOutlet
        self.refreshOutlet.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.refreshOutlet.attributedTitle = NSAttributedString(string: "Refreshing bets feed", attributes: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc private func handleRefresh(_ sender: Any) {
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        self.betsData = []
        getUserData()
    }
    
    func getUserData()
    {
        
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
        
        var activeBets = globalUserProfile["activeBets"] as! NSArray
        
        var potData : [String:Any] = [:]
        var potID: String = ""
        var count = 0
        while(count != activeBets.count)
        {
            var potID = String(describing: activeBets[count])
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
            
            print(potData)
            var temp = String(describing: potData["gameId"]!)
            //print(temp)
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
            
            var acceptedParticipants: NSArray = potData["acceptedParticipants"] as! NSArray
            
          //  print (acceptedParticipants)
            var pendingParticipants: NSArray = potData["pendingParticipants"] as! NSArray
            //var chatID: String = (potData["chatID"] as? String)!
            
            var allParticipants: [String] = []
            for t in pendingParticipants {
                allParticipants.append(String(describing: t))
            }
            for y in acceptedParticipants {
                var dict = y as! [String: Any]
                var temp = String(describing: dict["uid"]!)
                if (temp != globalPhoneNumber) {
                    allParticipants.append(temp)
                }
            }
            
            
            var teamChosen = ""
            var amt = ""
            for i in acceptedParticipants
            {
                //print(i)
                var dict = i as! [String: Any]
                //print(dict)
                var temp = String(describing: dict["uid"]!)
                //print(temp)
                if (temp == globalPhoneNumber)
                {
                    teamChosen = String(describing: dict["team"]!)
                    amt = String(describing: dict["amount"]!)
                    break
                }
                
            }
            
            var leagueName = potData["league"] as! String
            var team1 = gameData["team1"] as! String
            var team2 = gameData["team2"] as! String
            var date = gameData["startDate"] as! String
            var indic = ""
            
            if (pendingParticipants.count != 0)
            {
                indic = "pending"
            }
            else
            {
                indic = "confirmed"
            }
            
            var userDict: [String: Any] = ["team1": team1, "team2": team2, "date": date, "league": leagueName, "teamBet": teamChosen, "tokensBet": amt, "indicator": indic, "pot": potID, "allParticipants": allParticipants]
            self.betsData.append(userDict)
            
            count = count + 1
        }
        
        self.myTableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            if self.refreshOutlet.isRefreshing
            {
                self.refreshOutlet.endRefreshing()
            }
        })
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    @IBAction func createBetButton(_ sender: Any) {
        let setUpVC = storyboard!.instantiateViewController(withIdentifier: "PickGameViewController")
        self.navigationController?.pushViewController(setUpVC, animated: true);
        //self.performSegue(withIdentifier: "PickGamesSegue", sender: self)
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print("RETURNING NUMBER OF ROWS")
        return self.betsData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BetsCell
            else { return BetsCell() }
        
        cell.configureWithData(team1: self.betsData[indexPath.row]["team1"] as! String,team2: self.betsData[indexPath.row]["team2"] as! String, date: self.betsData[indexPath.row]["date"] as! String,  league: self.betsData[indexPath.row]["league"] as! String, teamBet: self.betsData[indexPath.row]["teamBet"] as! String, tokensBet: self.betsData[indexPath.row]["tokensBet"] as! String, indicator: self.betsData[indexPath.row]["indicator"] as! String, pot: self.betsData[indexPath.row]["pot"] as! String, allParticipants: self.betsData[indexPath.row]["allParticipants"] as! [String])

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        print("A ROW WAS SELECTED")
        
        let cell = myTableView.cellForRow(at: indexPath) as! BetsCell
        
        
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        print("ALL PARTICIPANTS: \(cell.allParticipants)")
        // Configure the fields of the interface.
        composeVC.recipients = cell.allParticipants
        composeVC.body = "What's up?"
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.
        
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)}

}
