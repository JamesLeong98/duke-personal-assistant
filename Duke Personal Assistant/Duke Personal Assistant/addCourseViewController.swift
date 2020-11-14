//
//  addCourseViewController.swift
//  Duke Personal Assistant
//
//  Created by Paul Rhee on 10/29/20.
//

import CoreData
import UIKit
import iOSDropDown

class addCourseViewController: UIViewController {
    
    @IBOutlet weak var departmentDropdown: DropDown!
    @IBOutlet weak var courseDropdown: DropDown!
    @IBOutlet weak var lectureDropdown: DropDown!
    @IBOutlet weak var labDiscDropdown: DropDown!
    @IBOutlet weak var addCoursesButton: UIButton!
    var sectionsToAdd: [NSManagedObject] = []
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    @IBAction func addToCourses(_ sender: Any) {
        // Dim screen and show loading indicator
        self.showLoading()
        
        // CoreData initialization
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let courseEntity = NSEntityDescription.entity(forEntityName: "Courses", in: context)
        let eventEntity = NSEntityDescription.entity(forEntityName: "Events", in: context)
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        
        let myCalendar = Calendar(identifier: .gregorian)
        
        do {
            let RGB = String(Float.random(in: 0..<1)) + ";" + String(Float.random(in: 0..<1)) + ";" + String(Float.random(in: 0..<1))
            
            if (self.lectureDropdown.selectedIndex != nil) {
                let lectureSection: Section = self.lectureDropdown.optionIds![self.lectureDropdown.selectedIndex!]! as! addCourseViewController.Section
                let newLecture = NSManagedObject(entity: courseEntity!, insertInto: context)
                let newCategory = NSManagedObject(entity: categoryEntity!, insertInto: context)
                var newEvents: [NSManagedObject] = []

                // Preparing category associated with new course
                prepareCategoryForCoreData(newCategory: newCategory, name: "\(lectureSection.subject) \(lectureSection.catalogNumber)", color: RGB)
                
                if lectureSection.meetingTime != "TBA" {
                    let splitTime = lectureSection.meetingTime.split(separator: "-")
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    
                    // Start time parse
                    dateFormatter.dateFormat = "h:mma "
                    let startTimeAsDate = dateFormatter.date(from: String(splitTime[0]))!
                    let startTime = myCalendar.dateComponents([.hour, .minute], from: startTimeAsDate)
                    
                    // End time parse
                    dateFormatter.dateFormat = " h:mma"
                    let endTimeAsDate = dateFormatter.date(from: String(splitTime[1]))!
                    let endTime = myCalendar.dateComponents([.hour, .minute], from: endTimeAsDate)
                    
                    
                    // Iterating from start date to end date for class meetings
                    var dateIterator = lectureSection.startDate
                    while dateIterator < lectureSection.endDate {
                        let dayOfWeek = myCalendar.dateComponents([.weekday], from: dateIterator)
                        if lectureSection.isMeetingWeekday[dayOfWeek.weekday! - 1] {
                            let startClassTime = myCalendar.date(bySettingHour: startTime.hour!, minute: startTime.minute!, second: 0,  of: dateIterator)!
                            let endClassTime = myCalendar.date(bySettingHour: endTime.hour!, minute: endTime.minute!, second: 0, of: dateIterator)!
                            
                            let newEvent = NSManagedObject(entity: eventEntity!, insertInto: context)
                            prepareEventForCoreData(newEvent: newEvent, start: startClassTime, end: endClassTime, desc: "\(lectureSection.courseName) at/as \(lectureSection.location)", title: "\(lectureSection.subject) \(lectureSection.catalogNumber) (\(lectureSection.sectionType))", color: RGB)
                            
                            newEvents.append(newEvent)
                        }
                        dateIterator = myCalendar.date(byAdding: .day, value: 1, to: dateIterator)!
                    }
                }
                
                
                prepareCourseForCoreData(newCourse: newLecture, newEvents: newEvents, newCategory: newCategory, sectionInfo: lectureSection, color: RGB)
                
                try context.save()
                sectionsToAdd.append(newLecture)
            }
            if (self.labDiscDropdown.selectedIndex != nil && self.labDiscDropdown.optionIds![self.labDiscDropdown.selectedIndex!] != nil) {
                let labDiscSection: Section = self.labDiscDropdown.optionIds![self.labDiscDropdown.selectedIndex!]! as! addCourseViewController.Section
                let newLabDisc = NSManagedObject(entity: courseEntity!, insertInto: context)
                
                var newEvents: [NSManagedObject] = []

                
                // Preparing class meeting events associated with new course
                if labDiscSection.meetingTime != "TBA" {
                    let splitTime = labDiscSection.meetingTime.split(separator: "-")
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    
                    // Start time parse
                    dateFormatter.dateFormat = "h:mma "
                    let startTimeAsDate = dateFormatter.date(from: String(splitTime[0]))!
                    let startTime = myCalendar.dateComponents([.hour, .minute], from: startTimeAsDate)
                    
                    // End time parse
                    dateFormatter.dateFormat = " h:mma"
                    let endTimeAsDate = dateFormatter.date(from: String(splitTime[1]))!
                    let endTime = myCalendar.dateComponents([.hour, .minute], from: endTimeAsDate)
                    
                    
                    // Iterating from start date to end date for class meetings
                    var dateIterator = labDiscSection.startDate
                    while dateIterator < labDiscSection.endDate {
                        let dayOfWeek = myCalendar.dateComponents([.weekday], from: dateIterator)
                        if labDiscSection.isMeetingWeekday[dayOfWeek.weekday! - 1] {
                            let startClassTime = myCalendar.date(bySettingHour: startTime.hour!, minute: startTime.minute!, second: 0,  of: dateIterator)!
                            let endClassTime = myCalendar.date(bySettingHour: endTime.hour!, minute: endTime.minute!, second: 0, of: dateIterator)!
                            
                            let newEvent = NSManagedObject(entity: eventEntity!, insertInto: context)
                            prepareEventForCoreData(newEvent: newEvent, start: startClassTime, end: endClassTime, desc: "\(labDiscSection.courseName) at/as \(labDiscSection.location)", title: "\(labDiscSection.subject) \(labDiscSection.catalogNumber) (\(labDiscSection.sectionType))", color: RGB)
                            
                            newEvents.append(newEvent)
                        }
                        dateIterator = myCalendar.date(byAdding: .day, value: 1, to: dateIterator)!
                    }
                }
                
                prepareCourseForCoreData(newCourse: newLabDisc, newEvents: newEvents, newCategory: nil, sectionInfo: labDiscSection, color: RGB)
                
                try context.save()
                sectionsToAdd.append(newLabDisc)
            }
        } catch {
            DispatchQueue.main.async {
                // Decoding Error
                let alert = UIAlertController(title: "Saving Error", message: "Failed to save new enrollment(s). Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.hideLoading()
                self.present(alert, animated: true)
            }
        }
        
        self.hideLoading()
        performSegue(withIdentifier: "dismissAddCourses", sender: self)
    }
    
    struct GetCoursesResponse: Codable {
        let ssrGetCoursesResp: SsrGetCoursesResp

        enum CodingKeys: String, CodingKey {
            case ssrGetCoursesResp = "ssr_get_courses_resp"
        }
    }

    struct SsrGetCoursesResp: Codable {
        let courseSearchResult: CourseSearchResult

        enum CodingKeys: String, CodingKey {
            case courseSearchResult = "course_search_result"
        }
    }

    struct CourseSearchResult: Codable {
        let subjects: Subjects
    }

    struct Subjects: Codable {
        let subject: Subject
    }

    struct Subject: Codable {
        let courseSummaries: CourseSummaries

        enum CodingKeys: String, CodingKey {
            case courseSummaries = "course_summaries"
        }
    }

    struct CourseSummaries: Codable {
        let courseSummary: [[String: String?]]

        enum CodingKeys: String, CodingKey {
            case courseSummary = "course_summary"
        }
    }
    
    struct Course {
        let course_id: String
        let offer_number: String
    }
    
    
    struct GetSectionsResponse: Decodable {
        let ssrGetClassesResp: SsrGetClassesResp

        enum CodingKeys: String, CodingKey {
            case ssrGetClassesResp = "ssr_get_classes_resp"
        }
    }

    struct SsrGetClassesResp: Decodable {
        let searchResult: SearchResult

        enum CodingKeys: String, CodingKey {
            case searchResult = "search_result"
        }
    }

    struct SearchResult: Decodable {
        let subjects: SectionSubjects
    }

    struct SectionSubjects: Decodable {
        let subject: SubjectClass
    }

    struct SubjectClass: Decodable {
        let classesSummary: ClassesSummary

        enum CodingKeys: String, CodingKey {
            case classesSummary = "classes_summary"
        }
    }

    struct ClassesSummary: Decodable {
        var classSummary: [ClassSummary]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let singleClassSummary = try? container.decode(ClassSummary.self, forKey: .classSummary) {
                self.classSummary = [singleClassSummary]
                return
            } else if let multipleClassSummary = try? container.decode([ClassSummary].self, forKey: .classSummary){
                self.classSummary = multipleClassSummary
                return
            }
            throw DecodingError.typeMismatch(ClassesSummary.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unidentified type"))
        }

        enum CodingKeys: String, CodingKey {
            case classSummary = "class_summary"
        }
    }

    struct ClassSummary: Codable {
        let crseID: String
        let crseIDLovDescr: String
        let subject: String
        let catalogNbr: String
        let crseOfferNbr: String
        let classSection: String
        let ssrComponent: String?
        let classesMeetingPatterns: ClassesMeetingPatterns

        enum CodingKeys: String, CodingKey {
            case crseID = "crse_id"
            case crseIDLovDescr = "crse_id_lov_descr"
            case subject
            case catalogNbr = "catalog_nbr"
            case crseOfferNbr = "crse_offer_nbr"
            case classSection = "class_section"
            case ssrComponent = "ssr_component"
            case classesMeetingPatterns = "classes_meeting_patterns"
        }
    }

    struct ClassesMeetingPatterns: Codable {
        let classMeetingPattern: ClassMeetingPattern

        enum CodingKeys: String, CodingKey {
            case classMeetingPattern = "class_meeting_pattern"
        }
    }
    
    struct ClassMeetingPattern: Codable {
        let facilityIDLovDescr: String?
        let startDt, endDt: String
        let stndMtgPat: String?
        let ssrMtgSchedLong: String?
        let mon, tues, wed, thurs, fri, sat, sun: String

        enum CodingKeys: String, CodingKey {
            case facilityIDLovDescr = "facility_id_lov_descr"
            case startDt = "start_dt"
            case endDt = "end_dt"
            case stndMtgPat = "stnd_mtg_pat"
            case ssrMtgSchedLong = "ssr_mtg_sched_long"
            case mon, tues, wed, thurs, fri, sat, sun
        }
    }
    
    
    struct Section {
        let courseID: String
        let courseOfferNumber: String
        let subject: String
        let catalogNumber: String
        let courseName: String
        let sectionType: String
        let location: String
        let startDate: Date
        let endDate: Date
        let meetingPattern: String
        let meetingTime: String
        let isMeetingWeekday: [Bool]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Style button
        addCoursesButton.layer.cornerRadius = 10
        addCoursesButton.clipsToBounds = true
        
        // Loading animation configuration
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        activityIndicator.frame = view.frame
        
        // URLSession config initialization
        let mySession = URLSession(configuration: URLSessionConfiguration.default)
        
        // Department dropdown configuration
        self.departmentDropdown.optionArray = Constants.Departments
        self.departmentDropdown.didSelect{(selectedText, index, id) in
            DispatchQueue.main.async {
                // Hide subsequent fields and "Add to My Courses" button to "reset" the form
                if (!self.courseDropdown.isHidden) {
                    self.courseDropdown.selectedIndex = nil
                    self.courseDropdown.text = nil
                    self.courseDropdown.isHidden = true
                }
                if (!self.lectureDropdown.isHidden) {
                    self.lectureDropdown.selectedIndex = nil
                    self.lectureDropdown.isHidden = true
                }
                if (!self.labDiscDropdown.isHidden) {
                    self.labDiscDropdown.selectedIndex = nil
                    self.labDiscDropdown.isHidden = true
                }
                if (!self.addCoursesButton.isHidden) {
                    self.addCoursesButton.isHidden = true
                }
                
                self.showLoading()
            }
            
            let formattedUrlString = "\(Constants.API.dukeAPIRoot)curriculum/courses/subject/\(selectedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)?access_token=\(Constants.API.API_KEY)"
            let getCoursesForDepartmentURL = URL(string: formattedUrlString)!
            
            let task = mySession.dataTask(with: getCoursesForDepartmentURL) { data, response, error in
                
                // ensure there is no error for this HTTP response
                guard error == nil else {
                    print ("error: \(error!)")
                    DispatchQueue.main.async {
                        let errorAlert = UIAlertController(title: "Network error", message: "Encountered an error when trying to retrieve the courses in the \(selectedText) department. Check your internet connection.", preferredStyle: .alert)
                        
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                        self.hideLoading()
                        self.present(errorAlert, animated: true)
                    }
                    return
                }

                // ensure there is data returned from this HTTP response
                guard let content = data else {
                    print("No data")
                    DispatchQueue.main.async {
                        let noDataAlert = UIAlertController(title: "Error", message: "No data was received when trying to retrieve courses in \(selectedText) department", preferredStyle: .alert)
                        
                        noDataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.hideLoading()
                        self.present(noDataAlert, animated: true)
                    }
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    let coursesInDepartment = try decoder.decode(GetCoursesResponse.self, from: content)
                    var courseDropdownOptions: [String] = []
                    var courseDropdownIds: [Course] = []
                    coursesInDepartment.ssrGetCoursesResp.courseSearchResult.subjects.subject.courseSummaries.courseSummary.forEach{course in
                        courseDropdownOptions.append("\( course["catalog_nbr"]!!.trimmingCharacters(in: NSCharacterSet.whitespaces)) - \( course["course_title_long"]!!)")
                        courseDropdownIds.append(Course(course_id: "\(course["crse_id"]!!)", offer_number: "\(course["crse_offer_nbr"]!!)"))
                    }
                    self.courseDropdown.optionArray = courseDropdownOptions
                    self.courseDropdown.optionIds = courseDropdownIds
                    
                    // Shows the course dropdown with populated options
                    DispatchQueue.main.async {
                        if (self.courseDropdown.isHidden) {
                            self.courseDropdown.isHidden = false
                        }
                        self.hideLoading()
                    }
                } catch {
                    print("JSON Decode error")
                    DispatchQueue.main.async {
                        let invalidResponseAlert = UIAlertController(title: "Invalid response", message: "Error: Received an invalid response from API. Check credentials", preferredStyle: .alert)
                        
                        invalidResponseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                        self.hideLoading()
                        self.present(invalidResponseAlert, animated: true)
                    }
                }
            }
            
            task.resume()
            
        }
        
        self.courseDropdown.didSelect{(selectedText, index, id) in
            DispatchQueue.main.async {
                // Hide subsequent fields and "Add to My Courses" button to "reset" the form
                if (!self.lectureDropdown.isHidden) {
                    self.lectureDropdown.selectedIndex = nil
                    self.lectureDropdown.text = nil
                    self.lectureDropdown.isHidden = true
                }
                if (!self.labDiscDropdown.isHidden) {
                    self.labDiscDropdown.selectedIndex = nil
                    self.labDiscDropdown.text = nil
                    self.labDiscDropdown.isHidden = true
                }
                if (!self.addCoursesButton.isHidden) {
                    self.addCoursesButton.isHidden = true
                }
                
                self.showLoading()
            }
            let selectedCourseIdentifiers: Course = id as! addCourseViewController.Course
            
            let formattedUrlString = "\(Constants.API.dukeAPIRoot)curriculum/classes/strm/\(Constants.CURRENT_SEMESTER.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)/crse_id/\(selectedCourseIdentifiers.course_id)?crse_offer_nbr=\(selectedCourseIdentifiers.offer_number)&access_token=\(Constants.API.API_KEY)"
            let getSectionsForCourseURL = URL(string: formattedUrlString)!
            
            let task = mySession.dataTask(with: getSectionsForCourseURL) { data, response, error in
                
                // ensure there is no error for this HTTP response
                guard error == nil else {
                    print ("error: \(error!)")
                    DispatchQueue.main.async {
                        let errorAlert = UIAlertController(title: "Network error", message: "Encountered an error when trying to retrieve the sections for \(selectedText). Check your internet connection.", preferredStyle: .alert)
                        
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.hideLoading()
                        self.present(errorAlert, animated: true)
                    }
                    return
                }

                // ensure there is data returned from this HTTP response
                guard let content = data else {
                    print("No data")
                    DispatchQueue.main.async {
                        let noDataAlert = UIAlertController(title: "Error", message: "No data was received when trying to retrieve sections for \(selectedText)", preferredStyle: .alert)
                        
                        noDataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.hideLoading()
                        self.present(noDataAlert, animated: true)
                    }
                    return
                }
                
                let decoder = JSONDecoder()

                do {
                    let sectionsForCourse = try decoder.decode(GetSectionsResponse.self, from: content)
                    
                    var lectureDropdownOptions: [String] = []
                    var lectureDropdownIds: [Section] = []
                    var labDiscDropdownOptions: [String] = []
                    var labDiscDropdownIds: [Section?] = []
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    sectionsForCourse.ssrGetClassesResp.searchResult.subjects.subject.classesSummary.classSummary.forEach{ section in
                        let classMeeting = section.classesMeetingPatterns.classMeetingPattern
                        let classDaysTimesSeparatorIndex = classMeeting.ssrMtgSchedLong?.firstIndex(of: " ") ?? String.Index(utf16Offset: 0, in: classMeeting.ssrMtgSchedLong!)
                        if (section.ssrComponent == "LEC" || section.ssrComponent == "ACT") {
                            lectureDropdownOptions.append("\(section.classSection): \(classMeeting.ssrMtgSchedLong!)")
                            
                            lectureDropdownIds.append(
                                Section(
                                    courseID: section.crseID,
                                    courseOfferNumber: section.crseOfferNbr,
                                    subject: section.subject,
                                    catalogNumber: section.catalogNbr,
                                    courseName: section.crseIDLovDescr,
                                    sectionType: section.ssrComponent!,
                                    location: classMeeting.facilityIDLovDescr!,
                                    startDate: dateFormatter.date(from: classMeeting.startDt)!,
                                    endDate: dateFormatter.date(from: classMeeting.endDt)!,
                                    meetingPattern: classMeeting.stndMtgPat ?? "",
                                    meetingTime: String(classMeeting.ssrMtgSchedLong!.suffix(from: classDaysTimesSeparatorIndex)),
                                    isMeetingWeekday: [
                                        classMeeting.sun == "Y",
                                        classMeeting.mon == "Y",
                                        classMeeting.tues == "Y",
                                        classMeeting.wed == "Y",
                                        classMeeting.thurs == "Y",
                                        classMeeting.fri == "Y",
                                        classMeeting.sat == "Y"]
                                )
                            )
                        }
                        else {
                            labDiscDropdownOptions.append("\(section.classSection): \(section.classesMeetingPatterns.classMeetingPattern.ssrMtgSchedLong!)")
                            labDiscDropdownIds.append(
                                Section(
                                    courseID: section.crseID,
                                    courseOfferNumber: section.crseOfferNbr,
                                    subject: section.subject,
                                    catalogNumber: section.catalogNbr,
                                    courseName: section.crseIDLovDescr,
                                    sectionType: section.ssrComponent!,
                                    location: classMeeting.facilityIDLovDescr!,
                                    startDate: dateFormatter.date(from: classMeeting.startDt)!,
                                    endDate: dateFormatter.date(from: classMeeting.endDt)!,
                                    meetingPattern: classMeeting.stndMtgPat ?? "", meetingTime: String(classMeeting.ssrMtgSchedLong!.suffix(from: classDaysTimesSeparatorIndex)),
                                    isMeetingWeekday: [
                                        classMeeting.sun == "Y",
                                        classMeeting.mon == "Y",
                                        classMeeting.tues == "Y",
                                        classMeeting.wed == "Y",
                                        classMeeting.thurs == "Y",
                                        classMeeting.fri == "Y",
                                        classMeeting.sat == "Y"]
                                )
                            )
                        }
                    }
                    labDiscDropdownOptions.insert("None", at: 0)
                    labDiscDropdownIds.insert(nil, at: 0)
                    self.lectureDropdown.optionArray = lectureDropdownOptions
                    self.labDiscDropdown.optionArray = labDiscDropdownOptions
                    self.lectureDropdown.optionIds = lectureDropdownIds
                    self.labDiscDropdown.optionIds = labDiscDropdownIds
                
                    DispatchQueue.main.async {
                        if (self.lectureDropdown.isHidden) {
                            self.lectureDropdown.isHidden = false
                        }
                        if (labDiscDropdownOptions.count > 1 && self.labDiscDropdown.isHidden) {
                            self.labDiscDropdown.isHidden = false
                        }
                        self.hideLoading()
                    }
                } catch {
                    print("JSON Decode error")
                    DispatchQueue.main.async {
                        let invalidResponseAlert = UIAlertController(title: "Invalid response", message: "Error: Received an invalid response from API. Check that you've correctly inputted a course that you will be taking in Spring 2021", preferredStyle: .alert)
                        
                        invalidResponseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            self.courseDropdown.selectedIndex = -1
                            self.courseDropdown.text = ""
                        }))
                        
                        self.hideLoading()
                        self.present(invalidResponseAlert, animated: true)
                    }
                }
            }
            task.resume()
        }
        
        self.lectureDropdown.didSelect{(selectedText, index, id) in
            if (self.labDiscDropdown.optionArray.count == 1) {
                // No lab/discussion sections associated with the class
                DispatchQueue.main.async {
                    if (self.addCoursesButton.isHidden) {
                        self.addCoursesButton.isHidden = false
                    }
                }
            }
        }
        
        self.labDiscDropdown.didSelect{(selectedText, index, id) in
            if (self.lectureDropdown.selectedIndex != nil) {
                DispatchQueue.main.async {
                    if (self.addCoursesButton.isHidden) {
                        self.addCoursesButton.isHidden = false
                    }
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func prepareCourseForCoreData(newCourse: NSManagedObject, newEvents: [NSManagedObject], newCategory: NSManagedObject?, sectionInfo: Section, color: String) {
        newCourse.setValue(sectionInfo.catalogNumber, forKey: "catalogNumber")
        newCourse.setValue(sectionInfo.courseID, forKey: "courseId")
        newCourse.setValue(sectionInfo.courseName, forKey: "courseName")
        newCourse.setValue(sectionInfo.location, forKey: "location")
        newCourse.setValue(sectionInfo.meetingPattern, forKey: "meetingPattern")
        newCourse.setValue(sectionInfo.meetingTime, forKey: "meetingTime")
        newCourse.setValue(sectionInfo.courseOfferNumber, forKey: "offerNumber")
        newCourse.setValue(sectionInfo.sectionType, forKey: "sectionType")
        newCourse.setValue(sectionInfo.subject, forKey: "subject")
        newCourse.setValue(color, forKey: "color")
        
        // Adding events associated with newCourse (will be removed from CoreData if course is removed from My Courses table)
        newCourse.setValue(NSSet(array: newEvents), forKey: "courseEvents")
        // Adding category associated with newCourse (will be removed from CoreData if course is removed from My Courses table)
        if newCategory != nil {
            // in case of lab/disc
            newCourse.setValue(newCategory, forKey: "courseCategory")
        }
    }
    
    func prepareEventForCoreData(newEvent: NSManagedObject, start: Date, end: Date, desc: String, title: String, color: String) {
        newEvent.setValue(title, forKey: "title")
        newEvent.setValue(desc, forKey: "desc")
        newEvent.setValue(start, forKey: "start")
        newEvent.setValue(end, forKey: "end")
        newEvent.setValue(color, forKey: "color")
    }
    
    func prepareCategoryForCoreData(newCategory: NSManagedObject, name: String, color: String) {
        newCategory.setValue(name, forKey: "name")
        newCategory.setValue(color, forKey: "color")
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        view.willRemoveSubview(activityIndicator)
    }
}
