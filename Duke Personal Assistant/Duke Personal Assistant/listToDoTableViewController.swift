//
//  listToDoTableViewController.swift
//  Duke Personal Assistant
//
//  Created by Christine Go on 10/29/20.
//

import UIKit
import CoreData

class listToDoTableViewController: UITableViewController {
    
//    struct ListItem {
//        var deadline: Date!
//        var title: String!
//        var description: String!
//    }
    
    struct SectionItem {
        var sectionName : String!
        var sectionColor: UIColor!
        var sectionList : [NSManagedObject]!
    }
    
    var tempStore: [String: [NSManagedObject]] = [:]
    
    var objectArray = [SectionItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 40;

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return objectArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return objectArray[section].sectionList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)

        cell.textLabel?.text = (objectArray[indexPath.section].sectionList[indexPath.row].value(forKey: "name") as! String)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return objectArray[section].sectionName
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = objectArray[section].sectionColor
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)   {
        if editingStyle == UITableViewCell.EditingStyle.delete   {
            deleteFromCoreData(todo: objectArray[indexPath.section].sectionList![indexPath.row])
            objectArray[indexPath.section].sectionList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            if (objectArray[indexPath.section].sectionList.isEmpty) {
                objectArray.remove(at: indexPath.section)
                let indexSet = IndexSet(arrayLiteral: indexPath.section)
                tableView.deleteSections(indexSet, with: .automatic)
            }
       }
    }
    
    @IBAction func done(segue:UIStoryboardSegue) {
        let entryVC = segue.source as! entryToDoViewController
        //save to persistence
        let courseName = entryVC.category?.name
        let courseColor = entryVC.category?.color
        let newEntry = saveToCoreData(title: entryVC.name!, deadline: entryVC.date!, desc: entryVC.desc!, course: courseName!, color: courseColor!)
          
        var keyExists = false
        
        for (index, element) in objectArray.enumerated() {
            if (element.sectionName == courseName) {
                objectArray[index].sectionList.append(newEntry)
                keyExists = true
            }
        }
        let RGB = unWrapColor(color: courseColor!)
        let color = UIColor.init(red: RGB[0], green: RGB[1], blue: RGB[2], alpha: 0.3)
        
        if (!keyExists) {
            objectArray.append(SectionItem(sectionName: courseName, sectionColor: color, sectionList: [newEntry]))
        }

       tableView.reloadData()
    }
    
    func unWrapColor(color: String) -> Array<CGFloat> {
        let RGB = color.components(separatedBy: ";")
        let red = CGFloat(truncating: NumberFormatter().number(from: RGB[0])!)
        let green = CGFloat(truncating: NumberFormatter().number(from: RGB[1])!)
        let blue = CGFloat(truncating: NumberFormatter().number(from: RGB[2])!)
        return [red, green, blue]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailView" {
            
        let destVC = segue.destination as! detailToDoViewController

        let indexPath = tableView.indexPathForSelectedRow
        let row = indexPath!.row
        let section = indexPath!.section
        
        let selectedListItem = objectArray[section].sectionList[row]
            
            destVC.name = selectedListItem.value(forKey: "name") as! String
            destVC.desc = selectedListItem.value(forKey: "desc") as! String
            
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd, hh:mm"
            destVC.deadline = df.string(from: selectedListItem.value(forKey: "deadline") as! Date)
        }
    }
    
    //function to save new event to core data
    func saveToCoreData(title: String, deadline: Date, desc: String, course: String, color: String) -> NSManagedObject {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let eventEntity = NSEntityDescription.entity(forEntityName: "Todos", in: context)
        let newTodo = NSManagedObject(entity: eventEntity!, insertInto: context)
        newTodo.setValue(title, forKey: "name")
        newTodo.setValue(deadline, forKey: "deadline")
        newTodo.setValue(desc, forKey: "desc")
        newTodo.setValue(course, forKey: "course")
        newTodo.setValue(color, forKey: "color")
        do {
            try context.save() //data saved to persistant storage
        } catch {
            //show an error message
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Saving Error", message: "Failed to save new todo. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        return newTodo
    }
    
    func deleteFromCoreData(todo: NSManagedObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(todo as NSManagedObject)
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
    
    override func viewDidAppear(_ animated: Bool) {
        objectArray = []
        tempStore = [:]
        
        //load the data from CoreData on startup
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todos")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for todo in result as! [NSManagedObject] {
                //initialize variables
                let course = todo.value(forKey: "course") as! String
                
                //add to tempStore, sorted by start datetime
                if tempStore[course] == nil {
                    tempStore[course] = []
                }
                tempStore[course]!.append(todo)
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
        for (key, value) in tempStore {
            let RGB = unWrapColor(color: value[0].value(forKey: "color") as! String)
            let color = UIColor.init(red: RGB[0], green: RGB[1], blue: RGB[2], alpha: 0.3)
            objectArray.append(SectionItem(sectionName: key, sectionColor: color, sectionList: value))
        }
        objectArray = objectArray.sorted(by: { $0.sectionName < $1.sectionName })
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
