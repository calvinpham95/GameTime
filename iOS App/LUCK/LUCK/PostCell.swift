//  Created by Anirudh Narayan on 11/16/17.
//  Copyright © 2017 Anirudh Narayan. All rights reserved.

import UIKit

class PostCell: UITableViewCell {
    

   
    @IBOutlet var teamVSLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var checkMarkImage: UIImageView!
    
    var team1Name: String = ""
    var team2Name: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWithData(_ data: NSDictionary) {
        
        checkMarkImage.image = UIImage(named: "Check mark unselected")
        if let team1 = data["team1"] , let team2 = data["team2"], let date = data["startDate"] {
            var temp1 = team1 as? String
            var temp2 = team2 as? String
            self.team1Name = temp1!
            self.team2Name = temp2!
            teamVSLabel.text = temp1! + " vs " + temp2!
            
            var subString = ""
            var count = 0
            for i in String(describing: date)
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
            let sysDate = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: sysDate)
            
            let year =  components.year
            let month = components.month
            let day: Int = components.day!
            
            var future = gameDay - day
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
    }
    
    func changeStylToBlack() {
        //userImage?.layer.cornerRadius = 30.0
        //postText.text = nil
        //postName.font = UIFont(name: "HelveticaNeue-Light", size:18) ?? .systemFont(ofSize: 18)
        //postName.textColor = .white
        backgroundColor = UIColor(red: 15/255.0, green: 16/255.0, blue: 16/255.0, alpha: 1.0)
    }
}

