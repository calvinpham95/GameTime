//
//  PickTeamViewController.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/17/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

var selectedTeam: String = ""
class PickTeamViewController: UIViewController {
    

    @IBOutlet weak var Button1Outlet: UIButton!
    @IBOutlet weak var Button2Outlet: UIButton!

    @IBOutlet weak var view1: UIView!
    //@IBOutlet weak var backgroundImage1: UIImageView!
    @IBOutlet weak var view2: UIView!
    
   // @IBOutlet weak var backgroundImage2: UIImageView!
    
    var button1Selected = false
    var button2Selected = true
    
    @IBAction func placeBet(_ sender: Any) {
        let setUpVC = storyboard!.instantiateViewController(withIdentifier: "SetTokensViewController")
        self.navigationController?.pushViewController(setUpVC, animated: true);
    }
    
    @IBAction func Team1Button(_ sender: Any) {
        selectedTeam = firstTeam
        self.view2.backgroundColor = .white
        let myColor = UIColor(red: 26/255.0, green: 164/255.0, blue: 122/255.0, alpha: 100)
        self.view1.backgroundColor = myColor
        
    }
    
    @IBAction func Team2Button(_ sender: Any) {
        selectedTeam = secondTeam
        self.view1.backgroundColor = .white
        let myColor = UIColor(red: 26/255.0, green: 164/255.0, blue: 122/255.0, alpha: 100)
        self.view2.backgroundColor = myColor
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Button1Outlet.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        Button2Outlet.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        if (currentLeagueChosen == "NHL" && (firstTeam == "Kings" || secondTeam == "Kings"))
        {
            if (firstTeam == "Kings")
            {
                Button1Outlet.setImage(UIImage(named: "Hockey-Kings"), for: .normal)
                Button2Outlet.setImage(UIImage(named: secondTeam), for: .normal)
                
            }
            else if (secondTeam == "Kings")
            {
                Button1Outlet.setImage(UIImage(named: firstTeam), for: .normal)
                Button2Outlet.setImage(UIImage(named: "Hockey-Kings"), for: .normal)
            }
        }
        else if (currentLeagueChosen == "NFL" && (firstTeam == "Jets" || secondTeam == "Jets"))
        {
            if (firstTeam == "Jets")
            {
                Button1Outlet.setImage(UIImage(named: "NFL-Jets"), for: .normal)
                Button2Outlet.setImage(UIImage(named: secondTeam), for: .normal)
                
            }
            else if (secondTeam == "Jets")
            {
                Button1Outlet.setImage(UIImage(named: firstTeam), for: .normal)
                Button2Outlet.setImage(UIImage(named: "NFL-Jets"), for: .normal)
            }
            
        }
        else if (currentLeagueChosen == "NFL" && (firstTeam == "Panthers" || secondTeam == "Panthers"))
        {
            if (firstTeam == "Panthers")
            {
                Button1Outlet.setImage(UIImage(named: "NFL-Panthers"), for: .normal)
                Button2Outlet.setImage(UIImage(named: secondTeam), for: .normal)
                
            }
            else if (secondTeam == "Panthers")
            {
                Button1Outlet.setImage(UIImage(named: firstTeam), for: .normal)
                Button2Outlet.setImage(UIImage(named: "NFL-Panthers"), for: .normal)
            }
            
        }
        else
        {
            Button1Outlet.setImage(UIImage(named: firstTeam), for: .normal)
            Button2Outlet.setImage(UIImage(named: secondTeam), for: .normal)
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
