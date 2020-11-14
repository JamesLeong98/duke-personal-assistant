//
//  coursesTableViewCell.swift
//  Duke Personal Assistant
//
//  Created by Paul Rhee on 11/5/20.
//

import UIKit

class coursesTableViewCell: UITableViewCell {
    @IBOutlet weak var catalogInfo: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var meetingPattern: UILabel!
    @IBOutlet weak var location: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /*override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }*/

}
