//
//  AddViewController.swift
//  MyReminders
//
//  Created by Siddharth Gupta on 19/06/22.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {

    // creating 3 fields for adding a new reminder in the application
    // title field lets you create a title for the reminder, body field lets you give description to the reminder and date picker allows you to choose a date for the reminder
    @IBOutlet var titleField: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    

    // handback the information
    public var completion: ((String, String, Date) -> Void)?
    
    public func getItem() {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date() //set mininum date as current day
        titleField.delegate = self
        bodyField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            completion?(titleText, bodyText, targetDate)
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }}
