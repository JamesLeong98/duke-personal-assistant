//
//  newEventViewController.swift
//  Duke Personal Assistant
//
//  Created by James Leong on 10/29/20.
//

import UIKit

class newEventViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
   

    @IBOutlet weak var newEventTitle: UITextField!
    @IBOutlet weak var newEventStart: UIDatePicker!
    @IBOutlet weak var newEventEnd: UIDatePicker!
    @IBOutlet weak var newEventDescription: UITextField!
    
    var defaultDate: Date = Date()
    var eventTitle: String? = ""
    var eventStart: Date? = Date()
    var eventEnd: Date? = Date()
    var eventDescription: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEventTitle.becomeFirstResponder()
        newEventTitle.delegate = self
        newEventDescription.delegate = self
        newEventStart.setDate(defaultDate, animated: true)
        newEventEnd.setDate(defaultDate, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newEventTitle.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSegue" {
            eventTitle = newEventTitle.text
            eventDescription = newEventDescription.text
            eventStart = newEventStart.date
            eventEnd = newEventEnd.date
        }
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
