//
//  ContactsCell.swift
//  LUCK
//
//  Created by Anirudh Narayan on 11/17/17.
//  Copyright © 2017 Calvin Pham. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {

    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var PhoneNumberLabel: UILabel!
    @IBOutlet weak var CheckMarkImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithData(_ data: NSDictionary) {
        if let phone = data["phone"],let fullname = data["fullname"]
       {
        
        
       
        
        var temp1: String = fullname as! String
        var temp2: String = phone as! String
      
            self.NameLabel.text = temp1
            self.PhoneNumberLabel.text = temp2
        
        }
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        //CheckMarkImage.image = UIImage(named: "Check mark unselected")
        
        // Configure the view for the selected state
    }
    
}
