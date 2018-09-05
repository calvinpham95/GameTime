//
//  InvitesCell.swift
//  LUCK
//
//  Created by Calvin Pham on 11/23/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

protocol CustomCellUpdater { 
    func updateTableView()
    func inviteeAccepted(team1: String, team2: String, potID: String, betPlaced: Int)
}

class InvitesCell: UITableViewCell {

    @IBOutlet var leagueImage: UIImageView!
    
    var delegate: CustomCellUpdater?
    
    var tokens: Int = Int()
    var potID : String = ""
    var opponent1: String = ""
    var opponent2: String = ""
    
    @IBOutlet var vsLabel: UILabel!
    @IBOutlet var gameDate: UILabel!
    @IBOutlet var inviterLabel: UILabel!
    
    @IBOutlet var acceptButton: NSLayoutConstraint!
    
    @IBOutlet var declineButton: UIButton!
    
    @IBAction func acceptButtonAction(_ sender: Any) {
        
        self.delegate?.inviteeAccepted(team1: self.opponent1, team2: self.opponent2, potID: potID, betPlaced: tokens)
        
    }
    @IBAction func declineButtonAction(_ sender: Any) {
        let json: [String: Any] =
            [
                "pid": potID,
                "uid": globalPhoneNumber
            ]
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        
        let semaphore = DispatchSemaphore(value: 0)
        var successIndicator = 0
        
        let url = URL(string: "http://"+ipAddress+":3000/api/pot/inviteeRejects")!
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
                if (String(describing: responseJSON["message"]!) == "Invitee has been successfully removed")
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
        self.delegate?.updateTableView()
        
    }
    
    
    func configureWithData(team1: String, team2: String, date: String, inviter: String, league: String, pot: String, bet: Int) {
        
        self.tokens = bet
        vsLabel.text = team1 + " vs " + team2
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
        if (future == 0)
        {
            gameDate.text = "Today"
        }
        else if (future == 1)
        {
            gameDate.text = "Tomorrow"
        }
        else
        {
            var dateStr = String(describing: future)
            gameDate.text = "In " + dateStr + " days"
        }
        
        inviterLabel.text = "Invited by " + inviter + " - " + String(describing: tokens) + " tokens"
        opponent1 = team1
        opponent2 = team2
        self.potID = pot
        
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
