//
//  calendarTableViewCell.swift
//  Duke Personal Assistant
//
//  Created by James Leong on 10/29/20.
//

import UIKit

class calendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var colorBox: UILabel!
    
    var eventStart: Date!
    var eventEnd: Date!
    var eventDesc: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
