//
//  LoginViewController.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/15/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

var ipAddress : String = "192.168.0.3"
import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        phoneNumberTextField.autocorrectionType = .no
        phoneNumberTextField.textContentType =  UITextContentType("")
        phoneNumberTextField.keyboardAppearance = .dark
        phoneNumberTextField.becomeFirstResponder()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        passwordTextField.autocorrectionType = .no
        passwordTextField.textContentType =  UITextContentType("")
        passwordTextField.keyboardAppearance = .dark
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet var loginLabel: UILabel!
    
    @IBAction func segueToMe(segue: UIStoryboardSegue) {
    }
    
    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        
        if let id = identifier {
            if id == "returnToMainViewController" {
                let unwindSegue = UIStoryboardUnwindSegueFromRight(identifier: id, source: fromViewController, destination: toViewController)
                return unwindSegue
            }
        }
        
        return super.segueForUnwinding(to: toViewController, from: fromViewController, identifier: identifier)!
    }

    
    
    
    @IBAction func closeLoginAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        // ********* Will need to fix this
        if (phoneNumberTextField.text == "" || passwordTextField.text == "")
        {
            loginLabel.text = "Please provide valid login credentials."
        }
        

        let semaphore = DispatchSemaphore(value: 0)
        var successIndicator = 0
        // create post request
        let url = URL(string: "http://"+ipAddress+":3000/api/login/" + phoneNumberTextField.text! + "/" + passwordTextField.text!)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
     
                if (String(describing: responseJSON["message"]!) == "success")
                {
                    successIndicator = 1
                    semaphore.signal()
                    
                }
                else
                {
                    
                    let alert = UIAlertController(title: "", message: "Invalid login credentials.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    semaphore.signal()
                }
            }
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        if (successIndicator == 1)
        {

            globalPhoneNumber = self.phoneNumberTextField.text!
     
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
            
            var verificationNum = globalUserProfile["verification"] as! Int
        
            if (verificationNum == 1)
            {
                self.performSegue(withIdentifier: "BetsHomeScreenSegue", sender: self)
            }
            else
            {
                self.performSegue(withIdentifier: "VerifySegue", sender: self)
            }
            
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

var globalPhoneNumber: String = ""
