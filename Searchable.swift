//
//  Searchable.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import Foundation


protocol SearchableRecord {
    func matchesSearchTerm(searchTerm: String)-> Bool
}
