//
//  SignUpEmailViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 12/11/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

var signUpEmail: String = ""

class SignUpEmailViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBAction func continueAction(_ sender: Any) {
        
        if (isValidEmail(testStr: emailTextField.text!))
        {
            signUpEmail = emailTextField.text!
            let setUpVC = storyboard!.instantiateViewController(withIdentifier: "SignUpFLNameViewController")
            self.navigationController?.pushViewController(setUpVC, animated: true);
        }
        else
        {
            let alert = UIAlertController(title: "Invalid email", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        emailTextField.autocorrectionType = .no
        
        emailTextField.textContentType =  UITextContentType("")
        emailTextField.keyboardAppearance = .dark
        emailTextField.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
