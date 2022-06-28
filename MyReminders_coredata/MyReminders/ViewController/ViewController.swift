//
//  ViewController.swift
//  MyReminders
//
//  Created by Siddharth Gupta on 19/06/22.
//
// required for notifications like schedule notification, authorisation to give notifications, etc

import UserNotifications
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    var fortable = [ReminderItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        FetchReminder()
    }
    
    
    func FetchReminder() {
        // fetch reminder from the core data to display in the table view
        do {
            self.fortable = try context.fetch(ReminderItem.fetchRequest())
            fortable.sort() { $0.date! < $1.date! }
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        catch {
        }
    }
    
    
    @IBAction func didTapAdd() {
//        show add viewcontrollere
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date in
            DispatchQueue.main.async { [self] in
                self.navigationController?.popToRootViewController(animated: true)
                
                let new = ReminderItem(context: self.context)
                new.title = title
                new.body = body
                new.date = date
                
                self.fortable.append(new)
                do {
                    try context.save()
                } catch {
                }
                fortable.sort() { $0.date! < $1.date! }
                self.table.reloadData()
                GetNotification(item: new)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    
    @IBAction func didTapTest() {
//        fire test notification
        // first request permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success {
//                schdule text
                self.scheduleTest()
            }
            else if error != nil {
                print("Error occured")
            }
        })
    }
    
    
    func scheduleTest() {
//        notification has 3 main pieces
//        1. request - send to the user notification centre
//        2 content parameter - body, title, sound, etc
//        3. trigger - here, date
        let content = UNMutableNotificationContent()
        content.title = "Hello! Notification works"
        content.sound = .default
        content.body = "MyReminders can successful send reminder! WORKS"
        
        let targetDate = Date().addingTimeInterval(10)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                                  from: targetDate),
                                                    repeats: false)
        
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if error != nil {
                print("Something went wrong")
            }
        })
        
    }
    

    func deleteItem(item: ReminderItem) {
        context.delete(item)
        do {
            try context.save()
        }
        catch {
        }
    }

    
    func GetNotification(item: ReminderItem) {
        let content = UNMutableNotificationContent()
        content.title = item.title!
        content.sound = .default
        content.body = item.body!
        
        let targetDate = item.date!
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                                                                  from: targetDate),
                                                    repeats: false)
        
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if error != nil {
                print("Something went wrong")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.fortable[indexPath.row]
        let date = fortable[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY hh:mm a "
        let str = (item.body)! + "\n" + formatter.string(from: date!)
        let sheet = UIAlertController(title: item.title, message: str, preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "Okay", style: .default))
        present(sheet, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // to show message when the table is empty
        if fortable.count == 0 {
        tableView.setEmptyView(title: "You do not have any reminder.", message: "Tap '+' to add reminder")
        }
        else {
        tableView.restore()
        }
        return fortable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fortable[indexPath.row].title
        let date = fortable[indexPath.row].date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY hh:mm a "
        cell.detailTextLabel?.text = formatter.string(from: date!)
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { action, indexPath in
            let item = self.fortable[indexPath.row]
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "edit") as? EditViewController {
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.title = "Edit Reminder"
                vc.title_table = item.title!
                vc.body_table = item.body!
                vc.date_table = item.date!
                
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.completion = {title, body, date in
                    DispatchQueue.main.async { [self] in
                        self.navigationController?.popToRootViewController(animated: true)
                        
                        let new = self.fortable[indexPath.row]
                        new.title = title
                        new.body = body
                        new.date = date
                        do {
                            try context.save()
                        } catch {
                        }
                        // sort table
                        fortable.sort() { $0.date! < $1.date! }
                        self.table.reloadData()
                        GetNotification(item: new)
                    }
                }
            }
        }
        editAction.backgroundColor = .systemOrange
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            // Delete warning
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes",
                                                  style: UIAlertAction.Style.destructive,
                                                  handler: {(_: UIAlertAction!) in
                        self.deleteItem(item: self.fortable[indexPath.row])
                        self.fortable.remove(at: indexPath.row)
                        self.table.deleteRows(at: [indexPath], with: .automatic)
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { _ in
                                    //Cancel Action
                    }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: false, completion: nil)
                    }
        }
        return [deleteAction, editAction]
    }
    
}


extension UITableView {
//    Sets the message when there are no active reminders
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
