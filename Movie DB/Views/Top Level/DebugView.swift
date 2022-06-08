//
//  DebugView.swift
//  Movie DB
//
//  Created by Jonas Frey on 28.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData
import CloudKit

struct DebugView: View {
    let context = PersistenceController.viewContext
    
    @State private var mediaCount = (0, 0)
    @State private var mediaICloud = 0
    @State private var genreCount = (0, 0)
    @State private var genreICloud = 0
    @State private var tagCount = (0, 0)
    @State private var tagICloud = 0
    @State private var pcCount = (0, 0)
    @State private var pcICloud = 0
    @State private var videoCount = (0, 0)
    @State private var videoICloud = 0
    @State private var seasonCount = (0, 0)
    @State private var seasonICloud = 0
    @State private var castCount = (0, 0)
    @State private var castICloud = 0
    
    var body: some View {
        NavigationView {
            List {
                Section("Core Data") {
                    describe(mediaCount, mediaICloud, label: "Medias")
                    describe(genreCount, genreICloud, label: "Genres")
                    describe(tagCount, tagICloud, label: "Tags")
                    describe(pcCount, pcICloud, label: "PCs")
                    describe(videoCount, videoICloud, label: "Videos")
                    describe(seasonCount, seasonICloud, label: "Seasons")
                    describe(castCount, castICloud, label: "Cast Members")
                }
            }
            .onAppear(perform: update)
            .refreshable {
                self.update()
            }
            .navigationTitle("Debug")
        }
    }
    
    func update() {
        // Set all iCloud values to -1 so its clear when loading finished
        self.mediaICloud = -1
        self.genreICloud = -1
        self.tagICloud = -1
        self.pcICloud = -1
        self.videoICloud = -1
        self.seasonICloud = -1
        self.castICloud = -1
        
        self.mediaCount = count(\Media.id)
        countiCloud("Media", store: $mediaICloud)
        self.genreCount = count(\Genre.id)
        countiCloud("Genre", store: $genreICloud, predicate: NSPredicate(format: "CD_id > 0"))
        self.tagCount = count(\Tag.id)
        countiCloud("Tag", store: $tagICloud)
        self.pcCount = count(\ProductionCompany.id)
        countiCloud("ProductionCompany", store: $pcICloud, predicate: NSPredicate(format: "CD_id > 0"))
        self.videoCount = count(\Video.key)
        countiCloud("Video", store: $videoICloud, predicate: NSPredicate(format: "CD_key != ''"))
        self.seasonCount = count(\Season.id)
        countiCloud("Season", store: $seasonICloud, predicate: NSPredicate(format: "CD_id > 0"))
        self.castCount = {
            let cast: [CastMember] = (try? context.fetch(CastMember.fetchRequest())) ?? []
            let unique = Set(cast.map(\.id)).count
            return (cast.count, unique)
        }()
        countiCloud("CastMember", store: $castICloud, predicate: NSPredicate(format: "CD_id > 0"))
    }
    
    func countiCloud(_ entity: String, store: Binding<Int>, predicate: NSPredicate = .init(format: "CD_id != ''")) {
        let query = CKQuery(recordType: CKRecord.RecordType("CD_\(entity)"), predicate: predicate)
        let db = CKContainer(identifier: "iCloud.de.JonasFrey.MovieDB").privateCloudDatabase
        db.fetch(withQuery: query) { result in
            // swiftlint:disable:next force_try
            let r = try! result.get()
            let count = r.matchResults.count
            if let cursor = r.queryCursor {
                recursiveRequest(cursor) { c in
                    DispatchQueue.main.async {
                        store.wrappedValue = count + c
                    }
                }
            } else {
                DispatchQueue.main.async {
                    store.wrappedValue = count
                }
            }
        }
    }
    
    private func recursiveRequest(_ cursor: CKQueryOperation.Cursor, completion: @escaping (Int) -> Void) {
        let db = CKContainer(identifier: "iCloud.de.JonasFrey.MovieDB").privateCloudDatabase
        db.fetch(withCursor: cursor) { result in
            // swiftlint:disable:next force_try
            let r = try! result.get()
            if let cursor = r.queryCursor {
                recursiveRequest(cursor) { c in
                    completion(r.matchResults.count + c)
                }
            } else {
                completion(r.matchResults.count)
            }
        }
    }
    
    func describe(_ count: (Int, Int), _ iCloud: Int, label: String) -> Text {
        let unique: String = count.0 == count.1 ? "all" : "\(count.1)"
        let icloud: String = count.0 == iCloud ? "all" : "\(iCloud)"
        return Text("\(count.0) \(label) (\(unique) unique, \(icloud) in iCloud)")
    }
    
    func count<T: NSManagedObject, Value: Hashable>(_ keyPath: KeyPath<T, Value>) -> (count: Int, unique: Int) {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entity().name!)
        let objects: [T] = (try? context.fetch(request)) ?? []
        return (objects.count, objects.uniqued(on: { $0[keyPath: keyPath] }).count)
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
