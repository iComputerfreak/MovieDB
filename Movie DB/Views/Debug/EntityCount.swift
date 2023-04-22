//
//  EntityCount.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.04.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CloudKit
import CoreData
import Foundation
import SwiftUI

class EntityCount: ObservableObject {
    let entityName: String
    @Published var localCount: Int?
    @Published var uniqueLocalCount: Int?
    @Published var remoteCount: Int?
    
    var localCountDescription: String {
        String(describing: uniqueLocalCount ?? -1)
    }
    
    var uniqueLocalCountDescription: String {
        if localCount == uniqueLocalCount {
            return "all"
        }
        return String(describing: uniqueLocalCount ?? -1)
    }
    
    var remoteCountDescription: String {
        if localCount == remoteCount {
            return "all"
        }
        return String(describing: remoteCount ?? -1)
    }
    
    init(name: String, localCount: Int? = nil, uniqueLocalCount: Int? = nil, remoteCount: Int? = nil) {
        self.entityName = name
        self.localCount = localCount
        self.uniqueLocalCount = uniqueLocalCount
        self.remoteCount = remoteCount
    }
    
    func invalidate() {
        self.localCount = nil
        self.uniqueLocalCount = nil
        self.remoteCount = nil
    }
    
    // Update the counts using the supplied ID keypath
    func update<T: NSManagedObject>(_ keyPath: KeyPath<T, some Hashable>) {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entity().name!)
        let objects: [T] = (try? PersistenceController.viewContext.fetch(request)) ?? []
        self.localCount = objects.count
        self.uniqueLocalCount = objects.uniqued(on: { $0[keyPath: keyPath] }).count
        countiCloud(T.entity().name!, predicate: NSPredicate(value: true)) { result in
            DispatchQueue.main.async {
                self.remoteCount = result
            }
        }
    }
    
    private func countiCloud(_ entity: String, predicate: NSPredicate, completion: @escaping (Int) -> Void) {
        let query = CKQuery(recordType: CKRecord.RecordType("CD_\(entity)"), predicate: predicate)
        let db = CKContainer(identifier: "iCloud.de.JonasFrey.MovieDB").privateCloudDatabase
        db.fetch(withQuery: query) { result in
            // swiftlint:disable:next force_try
            let r = try! result.get()
            let count = r.matchResults.count
            if let cursor = r.queryCursor {
                self.recursiveRequest(cursor) { c in
                    completion(count + c)
                }
            } else {
                completion(count)
            }
        }
    }
    
    private func recursiveRequest(_ cursor: CKQueryOperation.Cursor, completion: @escaping (Int) -> Void) {
        let db = CKContainer(identifier: "iCloud.de.JonasFrey.MovieDB").privateCloudDatabase
        db.fetch(withCursor: cursor) { result in
            // swiftlint:disable:next force_try
            let r = try! result.get()
            if let cursor = r.queryCursor {
                self.recursiveRequest(cursor) { c in
                    completion(r.matchResults.count + c)
                }
            } else {
                completion(r.matchResults.count)
            }
        }
    }
}
