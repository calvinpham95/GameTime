//
//  SignUpViewController.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/15/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

var newUserCreated: Int = 0

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        passwordTextField.keyboardAppearance = .dark
        passwordTextField.textContentType =  UITextContentType("")
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        confirmPasswordTextField.keyboardAppearance = .dark
        passwordTextField.textContentType =  UITextContentType("")
        
        passwordTextField.becomeFirstResponder()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    @IBAction func signUpButton(_ sender: Any) {
        
        if (passwordTextField.text != confirmPasswordTextField.text)
        {
            let alert = UIAlertController(title: "", message: "Your passwords do not match.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let json: [String: Any] =
            [
                "firstname": signUpFirstName,
                "lastname": signUpLastname,
                "password": passwordTextField.text!,
                "email": signUpEmail,
                "phone": Int(signUpPhoneNumber)!
            ]
 
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            
            let semaphore = DispatchSemaphore(value: 0)
            var successIndicator = 0
            
            let url = URL(string: "http://"+ipAddress+":3000/api/user/registerUser")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {

                    if (String(describing: responseJSON["message"]!) == "Success! User Created. Verification code sent.")
                    {
                        successIndicator = 1
                        semaphore.signal()
                    }
                    else if (String(describing: responseJSON["message"]!) == "Invalid phone number!")
                    {
                        let alert = UIAlertController(title: "Alert", message: "Unable to send SMS verfication text.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        semaphore.signal()
                        
                        
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Alert", message: "This user is already present!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        semaphore.signal()
                        
                    }
                }
            }
            
            task.resume()
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            if (successIndicator == 1)
            {
                globalPhoneNumber = signUpPhoneNumber
                newUserCreated = 1
                self.dismiss(animated: true, completion: nil)
                
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
