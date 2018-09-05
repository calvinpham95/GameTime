//
//  SetTokensViewController.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/17/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//
var tokens: String = ""
import UIKit
import Foundation

class SetTokensViewController: UIViewController {

    @IBOutlet weak var tokenTextField: UITextView!
    var randomNumber = 0;
    @IBAction func DoneButton(_ sender: Any) {
        tokens = tokenTextField.text
        self.randomNumber = random9DigitString()
        createPot()

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenTextField.keyboardType = UIKeyboardType.phonePad
        tokenTextField.becomeFirstResponder()
//        for i in globalPhoneNumberArray {
//            self.selectedUserForChat.append(String(i))
//        }
    
    //self.selectedUserForChat.append(globalPhoneNumberArray as [String])
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func random9DigitString() -> Int {
        let min: UInt32 = 100_000_000
        let max: UInt32 = 999_999_999
        let i = min + arc4random_uniform(max - min + 1)
        return Int(i)
    }
    
    func createPot() {
        let json: [String: Any] =
            [
                "id": self.randomNumber ,
                "pendingParticipants": globalPhoneNumberArray,
                "acceptedParticipants":
                [
                    [
                    "uid": globalPhoneNumber, "amount": Int(tokens)!, "team": selectedTeam
                    ]
                ],
                "gameId": gameID,
                "league": currentLeagueChosen.lowercased()
        ]
        
        print(json)

        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let url = URL(string: "http://"+ipAddress+":3000/api/pot/createPot")!
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
            //print(responseJSON)
            if let responseJSON = responseJSON as? [String: Any] {
                var messageFromBackend: String
                print(responseJSON)
                if (responseJSON["message"] == nil)
                {
                    messageFromBackend = responseJSON["error"] as! String
                    let alert = UIAlertController(title: "", message: "You do not have enough tokens to make this bet.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    messageFromBackend = responseJSON["message"] as! String
                }
                if (messageFromBackend == "A new pot has been successfully created")
                {
                    successIndicator = 1
                    semaphore.signal();
                }
                else
                {
                    semaphore.signal();
                }
            }
        }
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        if (successIndicator == 1)
        {
            //var jsonID = String(describing: json["id"]!)
            print("Success, creating pot")
        
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        else
        {
            print("POT COULD NOT BE CREATED")
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
