//
//  BookEntity+CoreDataProperties.swift
//  Quote
//
//  Created by Daniel Madjar on 1/2/23.
//
//

import Foundation
import CoreData
import UIKit

extension BookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged public var bookName: String?
    @NSManaged public var coverPhoto: String?
    @NSManaged public var id: UUID?
    @NSManaged public var quotes: NSSet?
    
    public var wrappedBookName: String {
        bookName ?? "No Name"
    }
    
    public var quoteArray: [QuoteEntity] {
        let set = quotes as? Set<QuoteEntity> ?? []
        
        return set.sorted {
            $0.wrappedString < $1.wrappedString
        }
    }
    
    public var coverPhotoWrapped: String {
        coverPhoto ?? ""
    }
    
    public var uiImage: UIImage {
        if !coverPhotoWrapped.isEmpty,
           let image = FileManager().retrieveImage(with: coverPhotoWrapped) {
           return image
        } else {
            return UIImage(systemName: "photo")!
        }
    }
}

// MARK: Generated accessors for quotes
extension BookEntity {

    @objc(addQuotesObject:)
    @NSManaged public func addToQuotes(_ value: QuoteEntity)

    @objc(removeQuotesObject:)
    @NSManaged public func removeFromQuotes(_ value: QuoteEntity)

    @objc(addQuotes:)
    @NSManaged public func addToQuotes(_ values: NSSet)

    @objc(removeQuotes:)
    @NSManaged public func removeFromQuotes(_ values: NSSet)

}

extension BookEntity : Identifiable {

}
