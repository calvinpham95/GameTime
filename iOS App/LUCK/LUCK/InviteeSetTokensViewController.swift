//
//  InviteeSetTokensViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 11/24/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

class InviteeSetTokensViewController: UIViewController {

    @IBOutlet var tokenTextField: UITextView!
    
    @IBAction func doneButtonPressed(_ sender: Any) {

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tokenTextField.keyboardType = UIKeyboardType.phonePad
        tokenTextField.becomeFirstResponder()

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
