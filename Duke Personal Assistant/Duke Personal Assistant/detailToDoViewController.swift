//
//  detailToDoViewController.swift
//  Duke Personal Assistant
//
//  Created by Christine Go on 10/29/20.
//

import UIKit

class detailToDoViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var name: String = ""
    var desc: String = ""
    var deadline: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleLabel.text = name
        self.descriptionLabel.text = desc
        self.dateLabel.text = "Deadline: " + deadline
        self.image.image = UIImage(named: "taskDevil")!
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
