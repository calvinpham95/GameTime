//
//  InviteePickTeamViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 11/24/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

var inviteeSelectedTeam: String = ""

class InviteePickTeamViewController: UIViewController {
    @IBOutlet var team1Button: UIButton!
    
    @IBOutlet var team2Button: UIButton!
    
    @IBOutlet var view1: UIView!
    @IBOutlet var view2: UIView!
    
    
    @IBOutlet var team1Image: UIImageView!
    @IBOutlet var team2Image: UIImageView!
    
    @IBAction func inviteeAcceptBet(_ sender: Any) {
        self.acceptInvite()
        
    }
    @IBAction func team1ButtonPressed(_ sender: Any) {
        inviteeSelectedTeam = inviteeFirstTeam
        print("first team selected")
        self.view2.backgroundColor = .white
        let myColor = UIColor(red: 26/255.0, green: 164/255.0, blue: 122/255.0, alpha: 100)
        self.view1.backgroundColor = myColor
       
    }
    
    @IBAction func team2ButtonPressed(_ sender: Any) {
        inviteeSelectedTeam = inviteeSecondTeam
        print("second team selected")
        self.view1.backgroundColor = .white
        let myColor = UIColor(red: 26/255.0, green: 164/255.0, blue: 122/255.0, alpha: 100)
        self.view2.backgroundColor = myColor
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        team1Button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        team2Button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        team1Button.setImage(UIImage(named: inviteeFirstTeam), for: .normal)
        team2Button.setImage(UIImage(named: inviteeSecondTeam), for: .normal)
        self.view1.backgroundColor = .white
        self.view2.backgroundColor = .white
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func acceptInvite()
    {
        var tokens = inviteeBetAmt
        var potID = Int(inviteePotSelected)
        var phoneNum = Int(globalPhoneNumber)
        
        let json: [String: Any] =
            [
                "pid": potID!,
                "uid": phoneNum!,
                "bet": tokens,
                "team": inviteeSelectedTeam
                
        ]
        
        print(json)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let url = URL(string: "http://"+ipAddress+":3000/api/pot/inviteeAcceptsSimple")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData
        
        let semaphore = DispatchSemaphore(value: 0)
        var successIndicator = 0
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                var messageFromBackend: String
                if (responseJSON["message"] == nil)
                {
                    messageFromBackend = responseJSON["error"] as! String
                    
                }
                else
                {
                    messageFromBackend = responseJSON["message"] as! String
                }
                if (messageFromBackend == "Pending participant has successfully accepted invite")
                {
                    successIndicator = 1
                    semaphore.signal();
                }
                else
                {
                    let alert = UIAlertController(title: "", message: "You do not have enough tokens to make this bet!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    semaphore.signal()
                    semaphore.signal();
                }
            }
        }
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        if (successIndicator == 1)
        {
            print("Success, accepted pot")
            self.navigationController?.popToRootViewController(animated: true)
        }
        else
        {
            print("Could not accept pot")
        }
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
