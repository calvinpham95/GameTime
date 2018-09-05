//
//  ProfileViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 12/5/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tokensLabel: UILabel!
    @IBOutlet var logOutButton: UIButton!
    @IBAction func logOutAction(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LandingScreenViewController") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func cashOut(_ sender: Any) {
        
        var usersToken: Int = globalUserProfile["tokens"] as! Int
        var earnings: Float = Float(usersToken)/100
        let doubleStr = String(format: "%.2f", earnings)
        // Create the alert controller
        let alertController = UIAlertController(title: "", message: "All tokens will be deducted from your account and a Visa gift card of $" + doubleStr + " will be sent to your email." , preferredStyle: .alert)
        
        // Create the actions
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let semaphore = DispatchSemaphore(value: 0)
            var successIndicator = 0
            // create post request
            var url = URL(string: "http://"+ipAddress+":3000/api/user/cashout/" + globalPhoneNumber)!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            var task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    //print(responseJSON)
                    if (String(describing: responseJSON["message"]!) == "success")
                    {
                        successIndicator = 1
                        semaphore.signal()
                        
                    }
                    else
                    {
                        semaphore.signal()
                    }
                }
            }
            
            task.resume()
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            url = URL(string: "http://"+ipAddress+":3000/api/user/getUserProfile/" + globalPhoneNumber)!
            request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            task = URLSession.shared.dataTask(with: request) { data, response, error -> Void in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                globalUserProfile = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                semaphore.signal()
            }
            
            task.resume()
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            print(globalUserProfile)
            print(globalUserProfile["tokens"] as! Int)
            self.tokensLabel.text = String(describing: globalUserProfile["tokens"]!) + " Tokens"
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var previousBets = NSArray()
    
    var betsData: [[String:Any]] = []
    let cellIdentifier = "historyCell"
    var imageData = NSData()
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    @IBAction func pickImageButton(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.image = pickedImage
            self.makePictureRound()
            self.imageData = UIImagePNGRepresentation(pickedImage)! as NSData
            UserDefaults.standard.set(imageData, forKey: "savedImage2")
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func makePictureRound() {
        self.imageView.layer.cornerRadius = imageView.frame.size.width / 2
        self.imageView.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
        //tableView.register(UINib.init(nibName: "historyCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self 
        tableView.delegate = self
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        var loadedImage: NSData = UIImagePNGRepresentation(self.imageView.image!)! as NSData
        if let tempData = UserDefaults.standard.object(forKey: "savedImage2") {
        if(loadedImage.isEqual(to: tempData as! Data)){
            print("Loaded Image is same as Saved Image")
        }
        else {
            
            self.imageView.image = UIImage(data: tempData as! Data)
        }
        }
        self.makePictureRound()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        // Get user's profile everytime view appears to refresh
        let semaphore = DispatchSemaphore(value: 0)
        
        
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
        
        var firstName: String = globalUserProfile["firstname"] as! String
        var lastname: String = globalUserProfile["lastname"] as! String
        
        nameLabel.text = firstName + " " + lastname
        tokensLabel.text =  String(describing: globalUserProfile["tokens"]!) + " Tokens"
        //print(globalUserProfile)
        self.previousBets = globalUserProfile["previousBets"] as! NSArray
        print("HISTORY DATA: \(previousBets)")
        var date = ""
        var team1 = ""
        var team2 = ""
        var betAmount = ""
        var net_profit = ""
        var chosenTeam = ""
        var win = ""
        var league = ""
        
        
        for i in previousBets {
            var dict = i as! [String: Any]
            date = String(describing: dict["date"]!)
            team1 = String(describing: dict["team1"]!)
            team2 = String(describing: dict["team2"]!)
            betAmount = String(describing: dict["betAmount"]!)
            net_profit = String(describing: dict["net_profit"]!)
            chosenTeam = String(describing: dict["chosenTeam"]!)
            win = String(describing: dict["win"]!)
            league = String(describing: dict["league"]!)
            var userDict: [String: Any] = ["date": date, "team1": team1, "team2": team2, "betAmount": betAmount, "net_profit": net_profit, "chosenTeam": chosenTeam, "win": win, "league": league]
            self.betsData.append(userDict)
        }
        
        self.tableView.reloadData()
    }
    
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.betsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HistoryCell
            else { return HistoryCell() }
        print ("BETSDATA: \(self.betsData)")
        cell.configureWithData(team1: self.betsData[indexPath.row]["team1"] as! String, team2: self.betsData[indexPath.row]["team2"] as! String, date: self.betsData[indexPath.row]["date"] as! String, league: self.betsData[indexPath.row]["league"] as! String, chosenTeam: self.betsData[indexPath.row]["chosenTeam"] as! String, net_profit: self.betsData[indexPath.row]["net_profit"] as! String, betAmount: self.betsData[indexPath.row]["betAmount"] as! String, win: self.betsData[indexPath.row]["win"] as! String)
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Betting History"
    }
}
