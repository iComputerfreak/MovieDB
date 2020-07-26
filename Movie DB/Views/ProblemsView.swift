//
//  ProblemsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.06.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProblemsView: View {
    
    @ObservedObject private var library = MediaLibrary.shared
    
    var body: some View {
        NavigationView {
            if library.problems.isEmpty && library.duplicates.isEmpty {
                Text("There are no problems in your library.")
                    .navigationBarTitle("Problems")
            } else {
                List {
                    if !library.problems.isEmpty {
                        self.incompleteSection()
                    }
                    if !library.duplicates.isEmpty {
                        self.duplicateSection()
                    }
                }
                .navigationBarTitle("Problems")
            }
        }
        .navigationBarItems(trailing: Button(action: {
            self.library.objectWillChange.send()
        }, label: { Text("Refresh") }))
    }
    
    func incompleteSection() -> some View {
        print("Problems: \(library.problems)")
        return Section(header: Text("Missing Information")) {
            ForEach(library.problems.map(\.key)) { mediaObject in
                ProblemsLibraryRow(content: Text("Missing: \(mediaObject.missingInformation.map(\.rawValue).joined(separator: ", "))").italic())
                    // For the environment object, get the reference to the real object
                    .environmentObject(library.mediaList.first(where: { $0.id == mediaObject.id }) ?? mediaObject)
            }
            .onDelete { indexSet in
                for offset in indexSet {
                    let id = library.problems.map(\.key)[offset].id
                    self.library.remove(id: id)
                }
            }
        }
    }
    
    func duplicateSection() -> some View {
        return Section(header: Text("Duplicate Entries")) {
            ForEach(self.library.duplicates.flatMap(\.value)) { mediaObject in
                ProblemsLibraryRow(content: Text("Duplicate").italic())
                    // For the environment object, get the reference to the real object
                    .environmentObject(library.mediaList.first(where: { $0.id == mediaObject.id }) ?? mediaObject)
            }
            .onDelete { indexSet in
                for offset in indexSet {
                    // Using the ID here is okay, because we checked for duplicate tmdbIDs, not library IDs
                    let id = library.duplicates.flatMap(\.value)[offset].id
                    self.library.remove(id: id)
                }
            }
        }
    }
}

struct ProblemsView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemsView()
    }
}
