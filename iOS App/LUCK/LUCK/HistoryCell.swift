//
//  HistoryCell.swift
//  LUCK
//
//  Created by Anirudh Narayan on 12/7/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

   
    @IBOutlet weak var leagueImage: UIImageView!
    @IBOutlet weak var teamsPlaying: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var Details: UILabel!
    @IBOutlet weak var AmtWonOrLost: UILabel!
    
    
    func configureWithData(team1: String, team2: String, date: String, league: String, chosenTeam: String, net_profit: String, betAmount: String, win: String) {
        
        
       // var temp = team1 + " vs " + team2
        self.teamsPlaying?.text = team1 + " vs " + team2
        self.AmtWonOrLost?.text = net_profit
        if (win == "true") {
            let myColor = UIColor(red: 26/255.0, green: 164/255.0, blue: 122/255.0, alpha: 100)
            
            self.AmtWonOrLost?.textColor = myColor
            self.AmtWonOrLost?.text = "+" + self.AmtWonOrLost.text!
        }
        else {
            let myColor = UIColor(red: 179/255.0, green: 67/255.0, blue: 67/255.0, alpha: 100)
            self.AmtWonOrLost?.textColor = myColor
            self.AmtWonOrLost?.text = self.AmtWonOrLost.text!
        }
        if (league == "nba")
        {
            leagueImage?.image = UIImage(named: "NBA Primary logo")
        }
        else if (league == "nfl")
        {
            leagueImage.image = UIImage(named: "NFL Primary logo")
        }
        else if (league == "nhl")
        {
            leagueImage.image = UIImage(named: "NHL Primary logo")
        }
        else
        {
            leagueImage.image = UIImage(named: "EPL Primary logo")
        }
        
        var subString = ""
        var count = 0
        for i in date
        {
            if (i == "-")
            {
                count = count + 1
                continue
            }
            if (count == 2)
            {
                subString = subString + String(describing: i)
            }
            
        }
        
        var gameDay: Int = Int(subString)!
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year =  components.year
        let month = components.month
        let day: Int = components.day!
        
        var past = day - gameDay
        
        Details?.text = betAmount + " tokens on " + chosenTeam
        
        if (past == 0)
        {
            self.date?.text = "Today"
        }
        else if (past == 1)
        {
            self.date?.text = "Yesterday"
        }
        else
        {
            var dateStr = String(describing: past)
            self.date?.text = dateStr + " days ago"
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
}
