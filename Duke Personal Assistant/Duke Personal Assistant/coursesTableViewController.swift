//
//  coursesTableViewController.swift
//  Duke Personal Assistant
//
//  Created by Paul Rhee on 10/29/20.
//

import UIKit
import CoreData

class coursesTableViewController: UITableViewController {

    @IBAction func done(segue: UIStoryboardSegue) {
        let entryVC = segue.source as! addCourseViewController
        let sectionsToAdd = entryVC.sectionsToAdd
        if !sectionsToAdd.isEmpty {
            enrollments.append(contentsOf: sectionsToAdd)
        }
        tableView.reloadData()
    }

    var enrollments: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Courses")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for course in result as! [NSManagedObject] {
                enrollments.append(course)
            }
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Loading Error", message: "Failed to load course enrollments. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrollments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCoursesCell", for: indexPath) as! coursesTableViewCell
        // Configure the cell...
        
        let enrollment = enrollments[indexPath.row]
    
        cell.catalogInfo.text = "\(enrollment.value(forKey: "subject") as! String) \(enrollment.value(forKey: "catalogNumber") as! String) (\(enrollment.value(forKey: "sectionType") as! String))"
        cell.courseName.text = (enrollment.value(forKey: "courseName") as! String)
        cell.meetingPattern.text = "\(enrollment.value(forKey: "meetingPattern") as! String) \(enrollment.value(forKey: "meetingTime") as! String)"
        cell.location.text = (enrollment.value(forKey: "location") as! String)
        let RGB = unWrapColor(color: (enrollment.value(forKey: "color") as! String))
        cell.backgroundColor = UIColor.init(red: RGB[0], green: RGB[1], blue: RGB[2], alpha: 0.3)
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    func unWrapColor(color: String) -> Array<CGFloat> {
        let RGB = color.components(separatedBy: ";")
        let red = CGFloat(truncating: NumberFormatter().number(from: RGB[0])!)
        let green = CGFloat(truncating: NumberFormatter().number(from: RGB[1])!)
        let blue = CGFloat(truncating: NumberFormatter().number(from: RGB[2])!)
        return [red, green, blue]
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove from CoreData (Courses Entity)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(enrollments[indexPath.row] as NSManagedObject)
            
            // Load tasks from CoreData
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todos")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for todo in result as! [NSManagedObject] {
                    let taskCourseName = todo.value(forKey: "course") as! String
                    let courseSubject = enrollments[indexPath.row].value(forKey: "subject") as! String
                    let catalogNum = enrollments[indexPath.row].value(forKey: "catalogNumber") as! String
                    
                    // If task is linked to deleted course, delete task
                    if (taskCourseName == courseSubject + " " + catalogNum) {
                        context.delete(todo)
                    }
                }
            } catch {
                //show an error message
                DispatchQueue.main.async {
                    // Decoding Error
                    let alert = UIAlertController(title: "Loading Error", message: "Failed to load todos. Please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            // Remove from local state of courses
            enrollments.remove(at: indexPath.row)
            do {
                try context.save() //data saved to persistant storage
            } catch {
                //show an error message
                DispatchQueue.main.async {
                    // Decoding Error
                    let alert = UIAlertController(title: "Deleting Error", message: "Failed to delete event or task. Please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        tableView.reloadData()
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
