//
//  eventDetailViewController.swift
//  Duke Personal Assistant
//
//  Created by James Leong on 11/3/20.
//

import UIKit

class eventDetailViewController: UIViewController {


    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDesc: UILabel!
    
    var eventHeader: String!
    var eventStart: Date!
    var eventEnd: Date!
    var eventDescription: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTitle.text = eventHeader
        eventDesc.text = eventDescription
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d yyyy"
        eventDate.text = formatter.string(from: eventStart)
        
        formatter.dateFormat = "h:mm a"
        eventTime.text = "from " + formatter.string(from: eventStart) + " to " + formatter.string(from: eventEnd)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
