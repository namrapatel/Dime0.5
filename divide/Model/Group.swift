//
//  Group.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-04.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import Foundation

class Group {
    private var _groupTitle: String
    private var _key: String
    private var _memberCount: Int
    private var _members: [String]
    var groupTitle: String {
        return _groupTitle
    }
    
    var key: String {
        return _key
    }
    
    var memberCount: Int {
        return _memberCount
    }
    
    var members: [String] {
        return _members
    }
    
    
    init(title: String, key: String, members: [String], memberCount: Int) {
        self._groupTitle = title
        self._key = key
        self._members = members
        self._memberCount = memberCount
    }
}
