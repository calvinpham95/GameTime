//
//  SignUpFLNameViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 12/11/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

var signUpFirstName: String = ""
var signUpLastname: String = ""

class SignUpFLNameViewController: UIViewController {
    @IBOutlet var fullNameTextField: UITextField!
    @IBAction func continueButton(_ sender: Any) {
        let fullNameArray = (self.fullNameTextField.text?.components(separatedBy: " "))!
        if (fullNameArray.count != 2)
        {
            let alert = UIAlertController(title: "Try again", message: "Please enter your first name and last name.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else
        {
            signUpFirstName = fullNameArray[0]
            signUpLastname = fullNameArray[1]
            let setUpVC = storyboard!.instantiateViewController(withIdentifier: "SignUpPasswordViewController")
            self.navigationController?.pushViewController(setUpVC, animated: true);
    
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fullNameTextField.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        fullNameTextField.autocorrectionType = .no
        fullNameTextField.keyboardAppearance = .dark
        fullNameTextField.textContentType =  UITextContentType("")
        fullNameTextField.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
