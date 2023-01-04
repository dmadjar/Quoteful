//
//  QuoteEntity+CoreDataProperties.swift
//  Quote
//
//  Created by Daniel Madjar on 1/2/23.
//
//

import Foundation
import CoreData


extension QuoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuoteEntity> {
        return NSFetchRequest<QuoteEntity>(entityName: "QuoteEntity")
    }

    @NSManaged public var string: String?
    @NSManaged public var book: BookEntity?
    
    public var wrappedString : String {
        string ?? "No String"
    }
}

extension QuoteEntity : Identifiable {

}
