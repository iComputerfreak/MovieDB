//
//  DebugView.swift
//  Movie DB
//
//  Created by Jonas Frey on 28.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData

struct DebugView: View {
    let context = PersistenceController.viewContext
    
    var uniqueGenres: Int {
        let genres = (try? context.fetch(Genre.fetchRequest())) ?? []
        return genres.removingDuplicates(key: \.id).count
    }
    
    var castCount: (Int, Int) {
        let cast: [CastMember] = (try? context.fetch(CastMember.fetchRequest())) ?? []
        let unique = Set(cast.map(\.id)).count
        return (cast.count, unique)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                describe(count(\Media.id), label: "Medias")
                describe(count(\Genre.id), label: "Genres")
                describe(count(\Tag.id), label: "Tags")
                describe(count(\ProductionCompany.id), label: "Production Companies")
                describe(count(\Video.key), label: "Videos")
                describe(count(\Season.id), label: "Seasons")
                describe(castCount, label: "Cast Members")
                Spacer()
            }
            .padding()
            Spacer()
        }
    }
    
    func describe(_ count: (Int, Int), label: String) -> Text {
        let unique: String = count.0 == count.1 ? "all" : "\(count.1)"
        return Text("\(count.0) \(label) (\(unique) unique)")
    }
    
    func count<T: NSManagedObject, Value: Equatable>(_ keyPath: KeyPath<T, Value>) -> (count: Int, unique: Int) {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entity().name!)
        let objects: [T] = (try? context.fetch(request)) ?? []
        return (objects.count, objects.removingDuplicates(key: keyPath).count)
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
