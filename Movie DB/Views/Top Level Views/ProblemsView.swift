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
    
    @State private var problems: [Media: Set<Media.MediaInformation>] = [:]
    @State private var duplicates: [Int?: [Media]] = [:]
        
    var body: some View {
        let refreshButton = Button(action: updateProblems, label: { Text("Refresh") })
        NavigationView {
            if problems.isEmpty && duplicates.isEmpty {
                Text("There are no problems in your library.")
                    .onAppear(perform: updateProblems)
                    .navigationBarTitle("Problems")
                    .navigationBarItems(trailing: refreshButton)
            } else {
                List {
                    if !problems.isEmpty {
                        self.incompleteSection()
                    }
                    if !duplicates.isEmpty {
                        self.duplicateSection()
                    }
                }
                .onAppear(perform: updateProblems)
                .navigationBarTitle("Problems")
                .navigationBarItems(trailing: refreshButton)
            }
        }
    }
    
    func updateProblems() {
        // Every time the view is rendered, we update the problems
        DispatchQueue.global(qos: .userInteractive).async {
            let problems = library.problems()
            let duplicates = library.duplicates()
            DispatchQueue.main.async {
                self.problems = problems
                self.duplicates = duplicates
            }
        }
    }
    
    func incompleteSection() -> some View {
        return Section(header: Text("Missing Information")) {
            ForEach(problems.map(\.key)) { mediaObject in
                ProblemsLibraryRow(content: Text("Missing: \(mediaObject.missingInformation().map(\.rawValue).joined(separator: ", "))").italic())
                    // For the environment object, get the reference to the real object
                    .environmentObject(library.mediaList.first(where: { $0.id == mediaObject.id }) ?? mediaObject)
            }
        }
    }
    
    func duplicateSection() -> some View {
        return Section(header: Text("Duplicate Entries")) {
            ForEach(duplicates.flatMap(\.value)) { mediaObject in
                ProblemsLibraryRow(content: Text("Duplicate").italic())
                    // For the environment object, get the reference to the real object
                    .environmentObject(library.mediaList.first(where: { $0.id == mediaObject.id }) ?? mediaObject)
            }
        }
    }
}

struct ProblemsView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemsView()
    }
}
