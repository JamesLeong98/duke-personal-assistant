//
//  entryToDoViewController.swift
//  Duke Personal Assistant
//
//  Created by Christine Go on 10/29/20.
//

import UIKit
import CoreData

class entryToDoViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet weak var sectionField: UIPickerView!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var customCategoryField: UITextField!
    @IBAction func doneClicked(_ sender: Any) {
        let name = textField.text
        let selectedCategory = pickerData[sectionField.selectedRow(inComponent: 0)]
        
        // Input validation
        if (name == "") {
            DispatchQueue.main.async {
                // Null entry for required field
                let nullTitleAlert = UIAlertController(title: "Incomplete task", message: "Please include a title for the task", preferredStyle: .alert)
                nullTitleAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(nullTitleAlert, animated: true)
            }
            return
        }
        if (selectedCategory.name == "") {
            DispatchQueue.main.async {
                // Null entry for required field
                let nullCategoryAlert = UIAlertController(title: "Incomplete task", message: "Please include a category for the task", preferredStyle: .alert)
                nullCategoryAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(nullCategoryAlert, animated: true)
            }
            return
        }
        if selectedCategory.name == "Other" {
            let RGB = String(Float.random(in: 0..<1)) + ";" + String(Float.random(in: 0..<1)) + ";" + String(Float.random(in: 0..<1))
            if customCategoryField.text == "" {
                self.category = Category(name: "Other", color: RGB)
            }
            else {
                // Add custom category to CoreData
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
                let newCategory = NSManagedObject(entity: categoryEntity!, insertInto: context)
                newCategory.setValue(customCategoryField.text!, forKey: "name")
                newCategory.setValue(RGB, forKey: "color")
                do {
                    try context.save()
                } catch {
                    //show an error message
                    DispatchQueue.main.async {
                        // Decoding Error
                        let alert = UIAlertController(title: "Saving Error", message: "Failed to save new category. Please try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
                
                self.category = Category(name: customCategoryField.text!, color: RGB)
            }
        }
        else {
            self.category = selectedCategory
        }
        self.name = name
        self.date = dateField.date
        self.desc = descriptionField.text
        
        performSegue(withIdentifier: "doneAddingTask", sender: self)
    }
    
    var pickerData: [Category] = [Category]()
    
    var name: String? = nil
    var date: Date? = Date()
    var desc: String? = ""
    var category: Category? = nil
    
    struct Category {
        let name: String
        let color: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textField.becomeFirstResponder()
        textField.delegate = self
        dateField.setDate(Date(), animated: true)
        // Do any additional setup after loading the view.
        // Connect data:
        sectionField.delegate = self
        sectionField.dataSource = self
        
        // Input the data into the array
        //load the data from CoreData on startup
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        request.returnsObjectsAsFaults = false
        do {
            pickerData.append(Category(name: "", color: ""))
            let result = try context.fetch(request)
            for category in result as! [NSManagedObject] {
                //initialize variables
                pickerData.append(Category(name: category.value(forKey: "name") as! String, color: category.value(forKey: "color") as! String))
            }
            pickerData.append(Category(name: "Other", color: ""))
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (pickerData[row].name)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerData[row].name == "Other") {
            customCategoryField.isHidden = false
        }
        else {
            customCategoryField.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
