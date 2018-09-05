//
//  PickGameViewController.swift
//  LUCK
//
//  Created by Calvin Pham on 12/2/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

class PickGameViewController: UIViewController, ChainUp {

    func chainUp1() {
        
    }
    
    func chainUp2() {
        let setUpVC = storyboard!.instantiateViewController(withIdentifier: "ContactsViewController")
        self.navigationController?.pushViewController(setUpVC, animated: true);
        
    }
    
    @IBOutlet var myView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller: CreateBetViewController = storyboard.instantiateViewController(withIdentifier: "CreateBetViewController") as! CreateBetViewController
        
        controller.dele = self
        
        //add as a childviewcontroller
        addChildViewController(controller)
        
        // Add the child's View as a subview
        controller.view.frame = myView.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView.addSubview(controller.view)
        
        
        
        // tell the childviewcontroller it's contained in it's parent
        controller.didMove(toParentViewController: self)
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
