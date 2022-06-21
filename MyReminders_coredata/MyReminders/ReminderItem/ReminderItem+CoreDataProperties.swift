//
//  ReminderItem+CoreDataProperties.swift
//  MyReminders
//
//  Created by Siddharth Gupta on 20/06/22.
//
//

import Foundation
import CoreData


extension ReminderItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReminderItem> {
        return NSFetchRequest<ReminderItem>(entityName: "ReminderItem")
    }
// what is NSManged? intermediary between saved data and app
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var date: Date?

}

extension ReminderItem : Identifiable {

}
