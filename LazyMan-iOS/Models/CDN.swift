//
//  CDN.swift
//  LazyMan-iOS
//
//  Created by Nick Thompson on 8/17/18.
//  Copyright © 2018 Nick Thompson. All rights reserved.
//

import Foundation

enum CDN: String, CaseIterable {
    case Akamai = "akc", Level3 = "l3c"
    
    var title: String {
        switch self {
        case .Akamai:
            return "Akamai"
        case .Level3:
            return "Level 3"
        }
    }
}
