//
//  BookNum+CoreDataProperties.swift
//  BookSearch
//
//  Created by t2024-m0153 on 8/9/24.
//
//

import Foundation
import CoreData


extension BookNum {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookNum> {
        return NSFetchRequest<BookNum>(entityName: "BookNum")
    }

    @NSManaged public var title: String?
    @NSManaged public var authors: String?
    @NSManaged public var bookPrice: Int64

}

extension BookNum : Identifiable {

}
