//
//  Media+Repairable.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//
import Foundation

enum RepairProblems {
    case none
    case some(fixed: Int, notFixed: Int)
    
    static func + (lhs: RepairProblems, rhs: RepairProblems) -> RepairProblems {
        var fixed = 0
        var notFixed = 0
        switch lhs {
            case let .some(f, nf):
                fixed += f
                notFixed += nf
                break
            default:
                break
        }
        switch rhs {
            case let .some(f, nf):
                fixed += f
                notFixed += nf
                break
            default:
                break
        }
        
        if fixed == 0 && notFixed == 0 {
            return .none
        } else {
            return .some(fixed: fixed, notFixed: notFixed)
        }
    }
}

protocol Repairable {
    func repair() -> RepairProblems
}


extension Media: Repairable {
    func repair() -> RepairProblems {
        let group = DispatchGroup()
        var fixed = 0
        var notFixed = 0
        // If we have no TMDBData, we have no tmdbID and therefore no possibility to reload the data.
        guard let tmdbData = self.tmdbData else {
            print("[Verify] Media \(self.id) is missing the tmdbData. Not fixable.")
            return .some(fixed: 0, notFixed: 1)
        }
        // Thumbnail
        if self.thumbnail == nil && tmdbData.imagePath != nil {
            loadThumbnail()
            fixed += 1
            print("[Verify] '\(tmdbData.title)' (\(id)) is missing the thumbnail. Trying to fix it.")
        }
        // Tags
        for tag in tags {
            // If the tag does not exist, remove it
            if !TagLibrary.shared.tags.map(\.id).contains(tag) {
                DispatchQueue.main.async {
                    self.tags.removeFirst(tag)
                    fixed += 1
                    print("[Verify] '\(tmdbData.title)' (\(self.id)) has invalid tags. Removed the invalid tags.")
                }
            }
        }
        // Cast
        if cast.isEmpty {
            group.enter()
            TMDBAPI.shared.getCast(by: tmdbData.id, type: type) { (wrapper) in
                if let wrapper = wrapper {
                    DispatchQueue.main.async {
                        // If the cast is empty, there was no problem in the first place
                        guard !wrapper.cast.isEmpty else {
                            return
                        }
                        self.cast = wrapper.cast
                        fixed += 1
                        print("[Verify] '\(tmdbData.title)' (\(self.id)) is missing the cast. Cast re-downloaded.")
                    }
                } else {
                    notFixed += 1
                    print("[Verify] '\(tmdbData.title)' (\(self.id)) is missing the cast. Cast could not be re-downloaded.")
                }
                group.leave()
            }
        }
        group.wait()
        if fixed == 0 && notFixed == 0 {
            return .none
        } else {
            return .some(fixed: fixed, notFixed: notFixed)
        }
    }
}
