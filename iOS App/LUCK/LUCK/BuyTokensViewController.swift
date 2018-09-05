//
//  BuyTokensViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 12/5/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit
import Stripe

class BuyTokensViewController: UIViewController, STPPaymentCardTextFieldDelegate, UITextViewDelegate {
    
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var tokensAMT: UITextView!
    var field1Satisfied = false
    var field2Satisfied = false
    
    @IBOutlet var payButtonInactive: UIButton!
    @IBOutlet var payButtonActive: UIButton!
    @IBAction func payButtonActiveAction(_ sender: Any) {
        let card = paymentTextField.cardParams
        STPAPIClient.shared().createToken(withCard: card) { (token, error) in
            if let error = error {
                print (error)
            }
            else if let token = token {
                print (token)
                self.chargeUsingToken(token: token)
            }
        }
    }
    
    
    let paymentTextField = STPPaymentCardTextField()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokensAMT.delegate = self
        //self.tokensAMT.keyboardAppearance = .dark
        //paymentTextField.keyboardAppearance = .dark
        
        // Do any additional setup after loading the view.
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (tokensAMT.text != nil && Int(tokensAMT.text)! >= 50)
        {
            field1Satisfied = true
            errorLabel.text = ""
            
        }
        else
        {
            errorLabel.text = "There is a minimum purchase of 50 tokens."
        }
        
        if (field1Satisfied && field2Satisfied)
        {
            self.payButtonInactive.isHidden = true
            self.payButtonActive.isHidden = false
        }
        
    }

    

    override func viewWillAppear(_ animated: Bool) {
        paymentTextField.frame = CGRect.init(x: 15, y: 265, width: self.view.frame.width - 30, height: 44)
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        //self.payButtonOutlet.isHidden = true
        self.payButtonActive.isHidden = true
        self.payButtonInactive.isHidden = false
        self.field1Satisfied = false
        self.field2Satisfied = false
        self.tabBarController?.tabBar.isHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.isValid
        {
            field2Satisfied = true
        
        }
        if (field1Satisfied && field2Satisfied)
        {
            self.payButtonInactive.isHidden = true
            self.payButtonActive.isHidden = false
            //self.payButtonOutlet.isHidden = false
        }
        
    }
    
    
    func chargeUsingToken(token: STPToken)
    {
        let json: [String: Any] =
            [
                "tokens": Int(tokensAMT.text)!,
                "uid": Int(globalPhoneNumber)!,
                "stripeToken": token.tokenId
            ]
        
        print(json)

        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        let semaphore = DispatchSemaphore(value: 0)
        var successIndicator = 0
        
        let url = URL(string: "http://"+ipAddress+":3000/api/payments/charge")!
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
                print(responseJSON)
                if (String(describing: responseJSON["message"]!) == "Success")
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
    
            print("Transaction successful")
            self.navigationController?.popViewController(animated: true)
            
        }
        
        
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
