//
//  Movie.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

class Movie: Media {
        
    /// Whether the user has watched the media (partly or fully)
    @Published var watched: Bool? = nil {
        didSet {
            if watched == nil {
                self.missingInformation.insert(.watched)
            } else {
                self.missingInformation.remove(.watched)
            }
        }
    }
    
    /// Creates a new `Movie` object
    init() {
        super.init(type: .movie)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        // We have to call super.init BEFORE initializing our own properties, because otherwise the didSet observer will not be called
        // (see the note at https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID262)
        // The only reason this works, is because all properties of this class are optionals
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.watched = try container.decode(Bool?.self, forKey: .watched)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.watched, forKey: .watched)
    }
    
    private enum CodingKeys: CodingKey {
        case watched
    }
    
    // MARK: - Hashable Conformance
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(watched)
    }
    
    // MARK: - Repairable Conformance
    override func repair(progress: Binding<Double>? = nil) -> RepairProblems {
        let problems = super.repair(progress: progress)
        // Sadly, we cannot update the progress correctly this way, but since the action here only takes a quick moment, we will just ignore the overhead
        if self.watched == nil {
            DispatchQueue.main.async {
                self.missingInformation.insert(.watched)
            }
        }
        return problems
    }
}
