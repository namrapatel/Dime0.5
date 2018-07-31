//
//  Group.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-04.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import Foundation

class Transaction {
    private var _groupTitle: String
    private var _key: String
    private var _payees: [String]
    private var _payer: String
    private var _date: String
    private var _description: String
    private var _settled: [String]
    private var _amount: Float
    private var _groupKey: String
    
    var groupTitle: String {
        return _groupTitle
    }
    
    var key: String {
        return _key
    }
    
    var payees: [String] {
        return _payees
    }
    
    var payer: String {
        return _payer
    }
    
    var date: String {
        return _date
    }
    
    var description: String {
        return _description
    }
    
    var settled: [String] {
        return _settled
    }
    
    var amount: Float {
        return _amount
    }
    
    var groupKey: String {
        return _groupKey
    }
    
    init(groupKey: String, groupTitle: String, key: String, payees: [String], payer: String, date: String, description: String, amount: Float, settled: [String]) {
        self._groupTitle = groupTitle
        self._key = key
        self._payees = payees
        self._payer = payer
        self._date = date
        self._description = description
        self._settled = settled
        self._amount = amount
        self._groupKey = groupKey
    }
}

