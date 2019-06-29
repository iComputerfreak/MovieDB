//
//  TestingUtils.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct TestingUtils {
    static func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
        let data: Data
        
        guard let file = Bundle(for: Movie_DBTests.self).url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}

