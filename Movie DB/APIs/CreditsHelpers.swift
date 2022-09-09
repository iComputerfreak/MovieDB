//
//  CreditsHelpers.swift
//  Movie DB
//
//  Created by Jonas Frey on 28.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

struct CreditsWrapper: Decodable {
    let id: Int
    let cast: [CastMemberDummy]
}

struct AggregateCreditsWrapper: Decodable {
    let id: Int
    let cast: [AggregateCastMember]
}
