//
//  calendarViewController.swift
//  Duke Personal AssistantcalenadrViewController
//
//  Created by James Leong on 10/29/20.
//

import FSCalendar
import UIKit
import CoreData

class calendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var selectedDate: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var tempStore: [String: [NSManagedObject]] = [:]
    
    var selectedDay: Date? = Calendar.current.startOfDay(for: Date())
    var selectedDayString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //set selected date to today's date by default
        updateSelectedDate(date: Calendar.current.startOfDay(for: Date()))
        
        //add bottom border line to calendar
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: calendar.frame.height - 1, width: calendar.frame.width, height: 1.0)
        bottomLine.borderColor = UIColor.lightGray.cgColor
        bottomLine.borderWidth = 0.3
        calendar.layer.addSublayer(bottomLine)
        
    }
    
    //update table and label
    func updateSelectedDate(date: Date) {
        selectedDay = date
        selectedDayString = convertDateToString(date: date)
        updateSelectedDateLabel(date: date)
    }
    
    //update the label in table view
    func updateSelectedDateLabel(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let dateString = formatter.string(from: date)
        selectedDate.text = dateString
    }
    
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM d"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    //function called when a date is selected
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateSelectedDate(date: date)
        tableView.reloadData()
    }
    
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempStore[selectedDayString]?.count ?? 0
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! calendarTableViewCell
        
        let event = tempStore[selectedDayString]?[indexPath.row]
        
        if (event != nil) {
            cell.eventTitle.text = event!.value(forKey: "title") as? String
            cell.eventStart = event!.value(forKey: "start") as? Date
            cell.eventEnd = event!.value(forKey: "end") as? Date
            cell.eventDesc = event!.value(forKey: "desc") as? String
   
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            cell.eventTime.text = formatter.string(from: cell.eventStart) + " - " + formatter.string(from: cell.eventEnd)
            
            let RGB = unWrapColor(color: event!.value(forKey: "color") as! String)
            cell.colorBox.backgroundColor = UIColor.init(red: RGB[0], green: RGB[1], blue: RGB[2], alpha: 0.3)
        }
        
        return cell
      }
    
    func unWrapColor(color: String) -> Array<CGFloat> {
        let RGB = color.components(separatedBy: ";")
        let red = CGFloat(truncating: NumberFormatter().number(from: RGB[0])!)
        let green = CGFloat(truncating: NumberFormatter().number(from: RGB[1])!)
        let blue = CGFloat(truncating: NumberFormatter().number(from: RGB[2])!)
        return [red, green, blue]
    }
    
    //delete cells
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFromCoreData(event: tempStore[selectedDayString]![indexPath.row])
            tempStore[selectedDayString]!.remove(at: indexPath.row)
            
            //so the dot under the date on calendar will be removed
            if tempStore[selectedDayString]!.count == 0 {
                tempStore.removeValue(forKey: selectedDayString)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        calendar.reloadData()
    }
    
    //dots below dates
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM d"
        let dateString = formatter.string(from: date)
        if tempStore.keys.contains(dateString){
            return 1
        }

      return 0
    }
    
    //receive new input from add new event page
    @IBAction func done(segue:UIStoryboardSegue) {
        let entryVC = segue.source as! newEventViewController

        //save to persistence
        let newEvent = saveToCoreData(title: entryVC.eventTitle!, start: entryVC.eventStart!, end: entryVC.eventEnd!, desc: entryVC.eventDescription!)
        
        //get date key of new event
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM d"
        let key = formatter.string(from: newEvent.value(forKey: "start") as! Date)
       
        //if date already exists in dict, append
        if tempStore[key] == nil {
            tempStore[key] = []
        }
        tempStore[key]!.append(newEvent)
        
        //sort the updated array
        tempStore[key]!.sort(by: { ($0.value(forKey: "start") as! Date) < ($1.value(forKey: "start") as! Date) })
        
        tableView.reloadData()
        calendar.reloadData()
   }
    
    //function to save new event to core data
    func saveToCoreData(title: String, start: Date, end: Date, desc: String) -> NSManagedObject {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let eventEntity = NSEntityDescription.entity(forEntityName: "Events", in: context)
        let newEvent = NSManagedObject(entity: eventEntity!, insertInto: context)
        newEvent.setValue(title, forKey: "title")
        newEvent.setValue(start, forKey: "start")
        newEvent.setValue(end, forKey: "end")
        newEvent.setValue(desc, forKey: "desc")
        newEvent.setValue("0.920;0.498;0", forKey: "color")
        do {
            try context.save() //data saved to persistant storage
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Saving Error", message: "Failed to save new event. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        return newEvent
    }
    
    func deleteFromCoreData(event: NSManagedObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(event as NSManagedObject)
        do {
            try context.save() //data saved to persistant storage
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Deleting Error", message: "Failed to delete event. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    //when creating new event, pass selected date to new entry VC so new event date is automatically set as selected date
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createEvent" {
            let destVC = segue.destination as! newEventViewController
            destVC.defaultDate = selectedDay!.addingTimeInterval(Date().timeIntervalSince(Calendar.current.startOfDay(for: Date())))
        } else if segue.identifier == "displayEvent" {
            let destVC = segue.destination as! eventDetailViewController
            let myRow = tableView!.indexPathForSelectedRow
            let selectedCell = tableView!.cellForRow(at: myRow!) as! calendarTableViewCell
    
            destVC.eventHeader = selectedCell.eventTitle.text
            destVC.eventStart = selectedCell.eventStart
            destVC.eventEnd = selectedCell.eventEnd
            destVC.eventDescription = selectedCell.eventDesc
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // (re)load the data from CoreData and update calendar + table view whenever the calendar is shown
        tempStore = [:]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for event in result as! [NSManagedObject] {
                //initialize variables
                let start = event.value(forKey: "start") as! Date
                let key = convertDateToString(date: start)
                
                //add to tempStore, sorted by start datetime
                if tempStore[key] == nil {
                    tempStore[key] = []
                }
                tempStore[key]!.append(event)
                tempStore[key]!.sort(by: { ($0.value(forKey: "start") as! Date) < ($1.value(forKey: "start") as! Date) })
            }
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Loading Error", message: "Failed to load events. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        calendar.reloadData()
        tableView.reloadData()
    }
}
