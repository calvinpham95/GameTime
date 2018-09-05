//
//  VerifyViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 12/12/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit
import PinCodeTextField

class VerifyViewController: UIViewController {

    @IBOutlet var pinCodeTextField: PinCodeTextField!
    var correctCode: Bool = false
    
    @IBOutlet var verifyDisabled: UIButton!
    @IBOutlet var verifiedEnabled: UIButton!
    
    @IBAction func button(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToMainViewController", sender: self)
    }
    
    @IBAction func verifyButton(_ sender: Any) {
        if (correctCode)
        {
            let json: [String: Any] =
                [
                    "phone": Int(globalPhoneNumber)!,
                    "code": Int(self.pinCodeTextField.text!)!
                ]
            
            print(json)
            
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            
            let semaphore = DispatchSemaphore(value: 0)
            var successIndicator = 0
            
            let url = URL(string: "http://"+ipAddress+":3000/api/user/checkVerified")!
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
                    print("response from backend when trying to create profile:")
                    print(responseJSON["message"])
                    if (String(describing: responseJSON["message"]!) == "Success! User is now verified")
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
            self.performSegue(withIdentifier: "VerifiedSegue", sender: self)
            
        }
        else
        {
            let alert = UIAlertController(title: "Oops", message: "Invalid verification code was entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBOutlet var resendVerificationButton: UIButton!
    @IBAction func resendVerificationAction(_ sender: Any) {
        
        let json: [String: Any] =
            [
                "phone": Int(globalPhoneNumber)!
            ]
        
        print(json)
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        
        let semaphore = DispatchSemaphore(value: 0)
        var successIndicator = 0
        
        let url = URL(string: "http://"+ipAddress+":3000/api/user/resendVerification")!
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
                print("response from backend when trying to create profile:")
                print(responseJSON["message"])
                if (String(describing: responseJSON["message"]!) == "Success! New verification code sent")
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
        
        if (successIndicator == 1)
        {
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
            let alert = UIAlertController(title: "", message: "A new verification code was sent to your phone.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else
        {
            let alert = UIAlertController(title: "", message: "Unable to send a new verification code.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.pinCodeTextField.becomeFirstResponder()
        }
        pinCodeTextField.delegate = self
        pinCodeTextField.keyboardType = .numberPad
        pinCodeTextField.keyboardAppearance = .dark
        pinCodeTextField.autocorrectionType = .no
        
        let semaphore = DispatchSemaphore(value: 0)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.correctCode = false
        self.pinCodeTextField.text = ""
        self.verifiedEnabled.isHidden = true
        self.verifyDisabled.isHidden = false
    }
    

}

extension VerifyViewController: PinCodeTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        
        
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        let value: String = textField.text ?? ""
        if (value.count != 4)
        {
            self.verifyDisabled.isHidden = false
            self.verifiedEnabled.isHidden = true
            
        }

    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        let value: String = textField.text ?? ""
        self.verifiedEnabled.isHidden = false
        self.verifyDisabled.isHidden = true
        
        if (Int(value)! == globalUserProfile["verification"] as! Int)
        {
            self.correctCode = true
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {

        return true
    }
}
