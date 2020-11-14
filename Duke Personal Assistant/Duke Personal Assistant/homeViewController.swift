//
//  homeViewController.swift
//  Duke Personal Assistant
//
//  Created by James Leong on 11/10/20.
//

import UIKit
import CoreData

class homeViewController: UIViewController {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var events: UIButton!
    @IBOutlet weak var tasksToday: UIButton!
    @IBOutlet weak var courses: UIButton!
    @IBOutlet weak var tasksTotal: UIButton!
    @IBOutlet weak var quote: UILabel!
    
    // Opening appropriate tab when clicking on corresponding box
    @IBAction func navigateToMyCourses(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func navigateToPlanner(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func navigateToTasks(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
    
    var dateToday = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //formatting and styling
        events.layer.cornerRadius = 10
        events.clipsToBounds = true
        events.backgroundColor = UIColor(red: 255/255.0, green: 213/255.0, blue: 229/255.0, alpha: 1.0)
        tasksToday.layer.cornerRadius = 10
        tasksToday.clipsToBounds = true
        tasksToday.backgroundColor = UIColor(red: 176/255.0, green: 222/255.0, blue: 255/255.0, alpha: 1.0)
        courses.layer.cornerRadius = 10
        courses.clipsToBounds = true
        courses.backgroundColor = UIColor(red: 255/255.0, green: 211/255.0, blue: 182/255.0, alpha: 1.0)
        tasksTotal.layer.cornerRadius = 10
        tasksTotal.clipsToBounds = true
        tasksTotal.backgroundColor = UIColor(red: 168/255.0, green: 230/255.0, blue: 207/255.0, alpha: 1.0)
        
        //load numbers
        setTodayDate()
        setTodayEvent()
        setTodayTask()
        setSemesterCourse()
        setSemesterTask()
        setQuote()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        if (!Calendar.current.isDate(dateToday, inSameDayAs: Date())) {
            dateToday = Date()
            setTodayDate()
            setQuote()
        }
        setTodayEvent()
        setTodayTask()
        setSemesterCourse()
        setSemesterTask()
    }
    
    func setTodayDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d YYYY"
        let dateString = formatter.string(from: dateToday)
        date.text = dateString
    }
    
    func setTodayEvent() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local

        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: dateToday) // eg. 2016-10-10 00:00:00
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)

        // Set predicate as date being today's date
        let fromPredicate = NSPredicate(format: "start >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "start < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.predicate = datePredicate
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            events.setTitle(String(result.count), for: .normal)
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Loading Error", message: "Failed to load events. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func setTodayTask() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todos")
        
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local

        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: dateToday) // eg. 2016-10-10 00:00:00
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)

        // Set predicate as date being today's date
        let fromPredicate = NSPredicate(format: "deadline >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "deadline < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.predicate = datePredicate
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            tasksToday.setTitle(String(result.count), for: .normal)
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Loading Error", message: "Failed to load tasks. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func setSemesterCourse() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Courses")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            var coursesSet: Set = Set<String>()
            for data in result as! [NSManagedObject] {
                coursesSet.insert(data.value(forKey: "courseId") as! String)
            }
            courses.setTitle(String(coursesSet.count), for: .normal)
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Loading Error", message: "Failed to load courses. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func setSemesterTask() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todos")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            tasksTotal.setTitle(String(result.count), for: .normal)
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Loading Error", message: "Failed to load tasks. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    struct quoteRes: Codable {
        let contents: contents
    }

    struct contents: Codable {
        let quotes: [quotes]
    }
    
    struct quotes: Codable {
        let quote: String?
        let author: String?
    }
    
    var quoteData: quoteRes?
    
    func setQuote() {
        let mySession = URLSession(configuration: URLSessionConfiguration.default)
        let url = URL(string: "https://quotes.rest/qod?language=en")!
        let task = mySession.dataTask(with: url) { [self] data, response, error in
            
            guard let content = data else {
                return
            }
            
            let decoder = JSONDecoder()
            do {
                // decode the JSON
                self.quoteData = try decoder.decode(quoteRes.self, from: content)
                DispatchQueue.main.async {
                    if (self.quoteData != nil) {
                        quote.text = self.quoteData!.contents.quotes[0].quote! + " ~" + self.quoteData!.contents.quotes[0].author!
                    }
                }
            } catch {
                return
            }
        }
    
        task.resume()
    }
}
