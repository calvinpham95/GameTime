//
//  BetsCell.swift
//  LUCK
//
//  Created by Calvin Pham on 11/17/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

class BetsCell: UITableViewCell {

    @IBOutlet var teamsPlayingLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var teamBetLabel: UILabel!
    @IBOutlet var leagueImage: UIImageView!
    @IBOutlet var potIndicator: UIImageView!
    
    var potID: String = ""
    var allParticipants: [String] = []
    
    
    func configureWithData(team1: String, team2: String, date: String, league: String, teamBet: String, tokensBet: String, indicator: String, pot: String, allParticipants: [String]) {
        
        self.potID = pot
        self.allParticipants = allParticipants
        
        if (indicator == "pending")
        {
            potIndicator.image = UIImage(named: "yellowdot")
            
        }
        else
        {
            potIndicator.image = UIImage(named: "greendot")
        }
        teamsPlayingLabel.text = team1 + " vs " + team2
        
        if (league == "nba")
        {
            leagueImage.image = UIImage(named: "NBA Primary logo")
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
        
        var future = gameDay - day
        
        teamBetLabel.text = teamBet + " Win - " + tokensBet + " tokens"
        
        if (future == 0)
        {
            dateLabel.text = "Today"
        }
        else if (future == 1)
        {
            dateLabel.text = "Tomorrow"
        }
        else
        {
            var dateStr = String(describing: future)
            dateLabel.text = "In " + dateStr + " days"
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
