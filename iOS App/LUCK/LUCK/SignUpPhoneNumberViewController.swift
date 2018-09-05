//
//  SignUpPhoneNumberViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 12/11/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

var signUpPhoneNumber: String = ""

class SignUpPhoneNumberViewController: UIViewController {

    @IBOutlet var navBarOutlet: UINavigationItem!
    @IBAction func closeSignUpAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBOutlet var phoneNumberField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberField.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        phoneNumberField.keyboardAppearance = .dark
        phoneNumberField.autocorrectionType = .no
        phoneNumberField.textContentType =  UITextContentType("")
        phoneNumberField.becomeFirstResponder()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var continueButton: UIButton!
    @IBAction func continueAction(_ sender: Any) {
        
        if (validatePhone(value: phoneNumberField.text!))
        {
            signUpPhoneNumber = phoneNumberField.text!
            print("signUpPhoneNumber: " + (signUpPhoneNumber))
            let setUpVC = storyboard!.instantiateViewController(withIdentifier: "SignUpEmailViewController")
            self.navigationController?.pushViewController(setUpVC, animated: true);
        }
        else
        {
            let alert = UIAlertController(title: "Invalid phone number", message: "Please enter a valid 9 digit phone number.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func validatePhone(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
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
