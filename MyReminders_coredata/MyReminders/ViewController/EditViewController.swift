//
//  EditViewController.swift
//  MyReminders
//
//  Created by Siddharth Gupta on 21/06/22.
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    public var completion: ((String, String, Date) -> Void)?
    
     
    var title_table: String = ""
    var body_table: String = ""
    var date_table: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title =  "Edit Reminder"
        titleField.text = title_table
        bodyField.text = body_table
        datePicker.minimumDate = Date()
        datePicker.date = date_table
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            completion?(titleText, bodyText, targetDate)
        }
    }
    
    

}
