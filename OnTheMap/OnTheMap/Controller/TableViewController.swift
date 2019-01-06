//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/6/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {
    var students = [Student]()
    var skip: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UdacityClient.getStudentLocations(completion: self.handleStudentLocationResponse(students:error:))
    }
    
    func handleStudentLocationResponse(students: [Student], error: Error?){
        self.students = students
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    /*
     * Return table cell
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = self.students[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableCell", for: indexPath) as! StudentTableCell
        
        cell.studentName?.text = "\(student.firstName) \(student.lastName)"
        
        return cell
    }

    
    /*
     * Display preview controller by clicking on cell
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[(indexPath as NSIndexPath).row]
        if let url = URL(string: student.mediaURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                showFailure(message: "\(student.mediaURL) is not a valid URL")
            }
        }
    }
    
    @IBAction func reloadData(_ sender: Any) {
        UdacityClient.getStudentLocations(completion: self.handleStudentLocationResponse(students:error:))
    }
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Invalid URL", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        //alertVC.show(alertVC, sender: nil)
        self.present(alertVC, animated: true, completion: nil)
    }
}
