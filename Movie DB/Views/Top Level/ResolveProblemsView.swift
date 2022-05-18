//
//  ResolveProblemsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ResolveProblemsView: View {
    @Binding var problems: [Problem]
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        NavigationView {
            List {
                ForEach(problems) { problem in
                    Section(problem.type.localized) {
                        Text(problem.type.recovery)
                        ForEach(problem.associatedMedias) { media in
                            LibraryRow()
                            .environmentObject(media)
                            .fixHighlighting()
                        }
                        .onDelete { indexSet in
                            for offset in indexSet {
                                let media = problem.associatedMedias[offset]
                                problems.removeAll(where: { $0.id == problem.id })
                                self.managedObjectContext.delete(media)
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(
                localized: "resolveProblems.navBar.title",
                comment: "The navigation bar title for the language chooser view"
            ))
        }
    }
}

struct ResolveProblemsView_Previews: PreviewProvider {
    static var previews: some View {
        ResolveProblemsView(problems: .constant([]))
    }
}
