//
//  Team.swift
//  LazyMan-iOS
//
//  Created by Nick Thompson on 2/21/18.
//  Copyright © 2018 Nick Thompson. All rights reserved.
//

import UIKit

enum League: String {
    case NHL, MLB
}

extension League {
    var favorites: [Team]? {
        return nil
    }
}

struct Team {
    var location: String
    var shortName: String
    var abbreviation: String
    var logo: UIImage
    var name: String {
        return "\(self.location) \(self.shortName)"
    }
    var league: League
    var isFavorite: Bool {
        return self.league.favorites?.contains(self) ?? false
    }
}

extension Team: Comparable {
    static func < (lhs: Team, rhs: Team) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func ==(lhs: Team, rhs: Team) -> Bool {
        return lhs.name == rhs.name
    }
}
