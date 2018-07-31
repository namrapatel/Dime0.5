//
//  DataService.swift
//  Funder
//
//  Created by Namra Patel on 2017-11-25.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_TRANSACTIONS = DB_BASE.child("transactions")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    var REF_TRANSACTIONS: DatabaseReference {
        return _REF_TRANSACTIONS
    }
    
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func getEmail (forSearchQuery query: String, handler: @escaping (_ email: String) -> ()) {
        var matchEmail: String = ""
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let userEmail = user.childSnapshot(forPath: "email").value as! String
                if userEmail == query && userEmail != Auth.auth().currentUser?.email {
                    matchEmail = userEmail
                    handler(matchEmail)
                }
            }
        }
    }
    
    func addFriend (byEmail email: String, handler: @escaping (_ added: Bool) -> ()) {
        var friendsArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                if user.key == Auth.auth().currentUser?.uid {
                    if (user.hasChild("friends")) {
                        friendsArray = user.childSnapshot(forPath: "friends").value as! [String]
                    }
                    if (!friendsArray.contains(email)) {
                            friendsArray.append(email)
                        self.REF_USERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["friends": friendsArray])
                    }
                    handler(true)
                }
            }
        }
    }
    
    func getFriends (forSearchQuery query: String, handler: @escaping (_ friends: [String]) -> ()) {
        var matchArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                if user.key == Auth.auth().currentUser?.uid {
                    if (user.hasChild("friends")) {
                        let friendsArray = user.childSnapshot(forPath: "friends").value as! [String]
                        for friend in friendsArray {
                            if friend.hasPrefix(query) {
                                matchArray.append(friend)
                            }
                        }
                        handler(matchArray)
                    }
                    }
                }
            }
        
    }
    
    func getName (handler: @escaping (_ name: String) -> ()) {
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let userName = user.childSnapshot(forPath: "name").value as! String
                let userEmail = user.childSnapshot(forPath: "email").value as! String
                if userEmail == Auth.auth().currentUser?.email {
                    handler(userName)
                }
            }
        }
    }
    
    func getName (forEmail email: String, handler: @escaping (_ name: String) -> ()) {
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let userName = user.childSnapshot(forPath: "name").value as! String
                let userEmail = user.childSnapshot(forPath: "email").value as! String
                if userEmail == email {
                    handler(userName)
                }
            }
        }
    }
    
    func getEmails (forGroupKey key: String, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        
        getGroupMemberIds(forGroupKey: key) { (groupMemberIds) in
            self.REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
                guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
                for user in userSnapshot {
                    if groupMemberIds.contains(user.key) {
                        let email = user.childSnapshot(forPath: "email").value as! String
                        emailArray.append(email)
                    }
                }
                handler(emailArray)
            }
        }
    }
    
    func getNames (forGroupKey key: String, handler: @escaping (_ emailArray: [String]) -> ()) {
        var nameArray = [String]()
        nameArray.append("You")
        
        getGroupMemberIds(forGroupKey: key) { (groupMembers) in
            self.REF_USERS.observe(.value) { (userSnapshot) in
                guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
                for user in userSnapshot {
                    if groupMembers.contains(user.key) && user.key != Auth.auth().currentUser?.uid {
                        let name = user.childSnapshot(forPath: "name").value as! String
                        nameArray.append(name)
                    }
                }
                handler(nameArray)
            }
        }
    }
    
    func getGroupNames (forSearchQuery query: String, handler: @escaping (_ groupArray: [Group]) -> ()) {
        var groupArray = [Group]()
        REF_USERS.child((Auth.auth().currentUser?.uid)!).child("groups").observe(.value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                let groupName = group.childSnapshot(forPath: "title").value as! String
                let members = group.childSnapshot(forPath: "members").value as! [String]
                let lowercasedName = groupName.lowercased()
                if lowercasedName.hasPrefix(query.lowercased()) {
                    groupArray.append(Group(title: groupName, key: group.key, members: members, memberCount: members.count))
                }
            }
            handler(groupArray)
        }
    }
    
    func getGroupArray (forUserId key: String, handler: @escaping (_ groupArray: [String]) -> ()) {
        var groupArray = [String]()
        REF_USERS.child(key).child("groups").observe(.value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                let groupName = group.childSnapshot(forPath: "title").value as! String
                let lowercasedName = groupName.lowercased()
            }
            handler(groupArray)
        }
    }
    
    func getGroupMemberIds (forGroup groupName: String, handler: @escaping (_ groupMembers: [String]) -> ()) {
        var groupMemberIdsArray = [String]()
        REF_USERS.child((Auth.auth().currentUser?.uid)!).child("groups").observe(.value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                let groupTitle = group.childSnapshot(forPath: "title").value as! String
                let groupMemberIds = group.childSnapshot(forPath: "members").value as! [String]
                if groupTitle == groupName {
                    groupMemberIdsArray = groupMemberIds
                    
                }
            }
            handler(groupMemberIdsArray)
        }
    }
    
    func getGroupMemberIds (forGroupKey key: String, handler: @escaping (_ groupMembers: [String]) -> ()) {
        var groupMemberIdsArray = [String]()
        REF_GROUPS.observe(.value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                let groupMemberIds = group.childSnapshot(forPath: "members").value as! [String]
                if group.key == key {
                    groupMemberIdsArray = groupMemberIds
                    
                }
            }
            handler(groupMemberIdsArray)
        }
    }
    
    func getUsername(forUid uid: String, handler: @escaping(_ username: String) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if user.key == uid {
                    handler(email)
                }
            }
        }
    }
    
    func getIds(forEmails emails: [String], handler: @escaping (_ uidArray: [String]) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            var idArray = [String]()
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let userEmail = user.childSnapshot(forPath: "email").value as! String
                if emails.contains(userEmail) {
                    idArray.append(user.key)
                }
            }
            handler(idArray)
        }
    }
    
    func getId(forEmail email: String, handler: @escaping (_ id: String) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            var id = ""
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let userEmail = user.childSnapshot(forPath: "email").value as! String
                if email == userEmail {
                    id = user.key
                }
            }
            handler(id)
        }
    }
    
    func getGroupIdArray(forUid uid: String, handler: @escaping(_ groupsArray: [String]) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            var groupsArray = [String]()
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                if user.key == uid {
                    if (user.hasChild("groups_array")) {
                        groupsArray = user.childSnapshot(forPath: "groups_array").value as! [String]
                    }
                    handler(groupsArray)
                }
            }
        }
    }
    
    func createGroup (withTitle title: String, ids: [String], handler: @escaping (_ groupCreated: Bool) -> ()) {
        let groupRef = REF_GROUPS.childByAutoId()
        groupRef.updateChildValues(["title": title, "members": ids])
        for userId in ids {
            REF_USERS.child(userId).child("groups").child(groupRef.key).updateChildValues(["title": title, "members": ids])
        
            getGroupIdArray(forUid: userId, handler: { (currentGroupArray) in
                var groupArray = currentGroupArray
                groupArray.append(groupRef.key)
                self.REF_USERS.child(userId).updateChildValues(["groups_array": groupArray])
            })
        }
        handler(true)
    }
    
    func createTransaction(groupKey: String, groupTitle: String, description: String, payees: [String], payer: String, date: String, amount: Float, settled: [String], handler: @escaping (_ transactionCreated: Bool) -> ()) {
        let transactionsRef = REF_TRANSACTIONS.childByAutoId()
        transactionsRef.updateChildValues(["description": description, "groupTitle": groupTitle, "groupKey": groupKey, "payees": payees, "payer": payer, "date": date, "amount": amount, "settled": [payer]])
            getIds(forEmails: payees, handler: { (payeeIds) in
                for payeeId in payeeIds {
                    self.REF_USERS.observeSingleEvent(of: .value, with: { (userSnapshot) in
                        guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
                        for user in userSnapshot {
                            if payeeId == user.key {
                                let owingValue = (user.childSnapshot(forPath: "owing").value as! NSString).floatValue + amount / Float(payees.count + 1)
                                self.REF_USERS.child(payeeId).updateChildValues(["owing": String(format: "%.2f", owingValue)])
                                self.REF_TRANSACTIONS.child(transactionsRef.key).child(payeeId).updateChildValues(["owing": String(format: "%.2f", amount / Float(payees.count + 1))])
                            
                            }
                        }
                    })
                }
            })
        getIds(forEmails: [payer], handler: { (userIds) in
            for userId in userIds {
                self.REF_USERS.observeSingleEvent(of: .value, with: { (userSnapshot) in
                    guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
                    for user in userSnapshot {
                        if user.key == userId {
                            let owedValue = (user.childSnapshot(forPath: "owed").value as! NSString).floatValue + Float(payees.count) * (amount / Float(payees.count + 1))
                            self.REF_USERS.child(userId).updateChildValues(["owed": String(format: "%.2f", owedValue)])
                            self.REF_TRANSACTIONS.child(transactionsRef.key).child(userId).updateChildValues(["owed": String(format: "%.2f", Float(payees.count) * (amount / Float(payees.count + 1)))])
                        }
                    }
                })
            }
        })
        handler(true)
    }
    
    func settleTransaction (transaction: Transaction, handler: @escaping (_ transactionSettled:Bool) -> ()) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let result = formatter.string(from: date)
        var settled  = transaction.settled
        settled.append((Auth.auth().currentUser?.email)!)
        REF_TRANSACTIONS.child(transaction.key).updateChildValues(["settled": settled])
        getIds(forEmails: [(Auth.auth().currentUser?.email)!], handler: { (payeeIds) in
            for payeeId in payeeIds {
                self.REF_USERS.observeSingleEvent(of: .value, with: { (userSnapshot) in
                    guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
                    for user in userSnapshot {
                        if payeeId == user.key {
                            let owingValue = (user.childSnapshot(forPath: "owing").value as! NSString).floatValue - (transaction.amount / Float(transaction.payees.count + 1))
                            self.REF_USERS.child(payeeId).updateChildValues(["owing": String(format: "%.2f", owingValue).replacingOccurrences(of: "-", with: "")])
                            self.REF_TRANSACTIONS.child(transaction.key).child(payeeId).updateChildValues(["owing": String(format: "%.2f", 0)])
                            self.REF_TRANSACTIONS.child(transaction.key).child(payeeId).updateChildValues(["paid": String(format: "%.2f", (transaction.amount / Float(transaction.payees.count + 1)))])
                            self.REF_TRANSACTIONS.child(transaction.key).child(payeeId).updateChildValues(["settled": result])
                            
                        }
                    }
                })
            }
        })
        getIds(forEmails: [transaction.payer], handler: { (userIds) in
            for userId in userIds {
                self.REF_USERS.observeSingleEvent(of: .value, with: { (userSnapshot) in
                    guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
                    for user in userSnapshot {
                        if user.key == userId {
                            let owedValue = (user.childSnapshot(forPath: "owed").value as! NSString).floatValue - (transaction.amount / Float(transaction.payees.count + 1))
                            
                           self.REF_USERS.child(userId).updateChildValues(["owed": String(format: "%.2f", owedValue).replacingOccurrences(of: "-", with: "")])
                            var transactionOwedValue: Float = 0.0
                             self.REF_TRANSACTIONS.child(transaction.key).observeSingleEvent(of: .value, with: { (transactionSnapshot) in
                                guard let transactionSnapshot = transactionSnapshot.children.allObjects as? [DataSnapshot] else {return}
                                for user in transactionSnapshot {
                                    if user.key == userId {
                                        transactionOwedValue = (user.childSnapshot(forPath: "owed").value as! NSString).floatValue - (transaction.amount / Float(transaction.payees.count + 1))
                                        self.REF_TRANSACTIONS.child(transaction.key).child(userId).updateChildValues(["owed": String(format: "%.2f", transactionOwedValue)])
                                    }
                                }
                            })
                            
                        }
                    }
                })
            }
        })

        
        handler(true)
    }
    
    func getOwing (userKey: String, handler: @escaping (_ owingAmount: Float) -> ()) {
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                if user.key == userKey {
                    handler((user.childSnapshot(forPath: "owing").value as! NSString).floatValue)
                }
            }
        }
    }
    
    func getOwed (userKey: String, handler: @escaping (_ owedAmount: Float) -> ()) {
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                if user.key == userKey{
                    handler((user.childSnapshot(forPath: "owed").value as! NSString).floatValue)
                }
            }
        }
    }
    
    func getAllTransactions (handler: @escaping (_ transactionArray: [Transaction]) -> ()) {
        var transactionArray = [Transaction]()
        
        REF_TRANSACTIONS.observeSingleEvent(of: .value) { (transactionSnapshot) in
            guard let transactionSnapshot = transactionSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for transaction in transactionSnapshot {
                let payer = transaction.childSnapshot(forPath: "payer").value as! String
                let payees = transaction.childSnapshot(forPath: "payees").value as! [String]
                let settled = transaction.childSnapshot(forPath: "settled").value as! [String]
                if Auth.auth().currentUser != nil {
                if payer == (Auth.auth().currentUser?.email)! || payees.contains((Auth.auth().currentUser?.email)!){
                    if (payer == (Auth.auth().currentUser?.email)! && (settled.count - 1) != payees.count) || !settled.contains((Auth.auth().currentUser?.email)!) {
                        let groupName = transaction.childSnapshot(forPath: "groupTitle").value as! String
                        let groupKey = transaction.childSnapshot(forPath: "groupKey").value as! String
                        let date = transaction.childSnapshot(forPath: "date").value as! String
                        let description = transaction.childSnapshot(forPath: "description").value as! String
                        let amount = transaction.childSnapshot(forPath: "amount").value as! Float
                    
                        let transactionFound = Transaction(groupKey: groupKey, groupTitle: groupName, key: transaction.key, payees: payees, payer: payer, date: date, description: description, amount: amount, settled: settled)
                        transactionArray.append(transactionFound)
                        }
                    }
                }
            }
            handler(transactionArray)
        }
    }
    
    func getAllTransactions (forGroup group: Group, handler: @escaping (_ transactionArray: [Transaction]) -> ()) {
        var groupTransactionArray = [Transaction]()
        REF_TRANSACTIONS.observe(.value) { (transactionSnapshot) in
            guard let transactionSnapshot = transactionSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for transaction in transactionSnapshot {
                let payer = transaction.childSnapshot(forPath: "payer").value as! String
                let payees = transaction.childSnapshot(forPath: "payees").value as! [String]
                let settled = transaction.childSnapshot(forPath: "settled").value as! [String]
                if Auth.auth().currentUser != nil {
                    if (payer == (Auth.auth().currentUser?.email)! && (settled.count - 1) != payees.count) || (payees.contains((Auth.auth().currentUser?.email)!) && !settled.contains((Auth.auth().currentUser?.email)!)) {
                            let groupName = transaction.childSnapshot(forPath: "groupTitle").value as! String
                            let groupKey = transaction.childSnapshot(forPath: "groupKey").value as! String
                            let date = transaction.childSnapshot(forPath: "date").value as! String
                            let description = transaction.childSnapshot(forPath: "description").value as! String
                            let amount = transaction.childSnapshot(forPath: "amount").value as! Float
                            if groupKey == group.key {
                                let transactionFound = Transaction(groupKey: groupKey, groupTitle: groupName, key: transaction.key, payees: payees, payer: payer, date: date, description: description, amount: amount, settled: settled)
                            groupTransactionArray.append(transactionFound)
                        }
                    }
                }
            }
            handler(groupTransactionArray)
        }
    }
    
    func getAllTransactions (forGroup group: Group, andUser key: String, handler: @escaping (_ transactionArray: [Transaction]) -> ()) {
        var userEmail = ""
        getUsername(forUid: key) { (email) in
            userEmail = email
        }
        var groupTransactionArray = [Transaction]()
        REF_TRANSACTIONS.observe(.value) { (transactionSnapshot) in
            guard let transactionSnapshot = transactionSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for transaction in transactionSnapshot {
                let payer = transaction.childSnapshot(forPath: "payer").value as! String
                let payees = transaction.childSnapshot(forPath: "payees").value as! [String]
                let settled = transaction.childSnapshot(forPath: "settled").value as! [String]
                    if (payer == userEmail || payees.contains(userEmail)) {
                        let groupName = transaction.childSnapshot(forPath: "groupTitle").value as! String
                        let groupKey = transaction.childSnapshot(forPath: "groupTitle").value as! String
                        let date = transaction.childSnapshot(forPath: "date").value as! String
                        let description = transaction.childSnapshot(forPath: "description").value as! String
                        let amount = transaction.childSnapshot(forPath: "amount").value as! Float
                        if groupKey == group.key {
                            let transactionFound = Transaction(groupKey: groupKey, groupTitle: groupName, key: transaction.key, payees: payees, payer: payer, date: date, description: description, amount: amount, settled: settled)
                            groupTransactionArray.append(transactionFound)
                        }
                    }
            }
            handler(groupTransactionArray)
        }
    }
    
    func getAllSettledTransactions (handler: @escaping (_ transactionArray: [Transaction]) -> ()) {
        var transactionArray = [Transaction]()
        REF_TRANSACTIONS.observe(.value) { (transactionSnapshot) in
            guard let transactionSnapshot = transactionSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for transaction in transactionSnapshot {
                let payer = transaction.childSnapshot(forPath: "payer").value as! String
                let payees = transaction.childSnapshot(forPath: "payees").value as! [String]
                let settled = transaction.childSnapshot(forPath: "settled").value as! [String]
                let groupName = transaction.childSnapshot(forPath: "groupTitle").value as! String
                let groupKey = transaction.childSnapshot(forPath: "groupKey").value as! String
                let description = transaction.childSnapshot(forPath: "description").value as! String
                var amount: Float = 0.0
                var date = transaction.childSnapshot(forPath: "date").value as! String
                self.REF_TRANSACTIONS.child(transaction.key).observe(.value) { (userSnapshot) in
                    guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
                    for user in userSnapshot {
                        if user.key == Auth.auth().currentUser?.uid && user.hasChild("settled"){
                            if payees.contains((Auth.auth().currentUser?.email)!) {
                                amount = (user.childSnapshot(forPath: "owing").value as! NSString).floatValue
                            } else if payer == (Auth.auth().currentUser?.email)! {
                                amount = (user.childSnapshot(forPath: "owed").value as! NSString).floatValue
                            }
                                date = user.childSnapshot(forPath: "settled").value as! String
                            let transactionFound = Transaction(groupKey: groupKey, groupTitle: groupName, key: transaction.key, payees: payees, payer: payer, date: date, description: description, amount: amount, settled: settled)
                            transactionArray.append(transactionFound)
                            handler(transactionArray)
                        }
                    }
                }
                
            }
        }
    }
    
    func getGroups (forGroupIdArray ids: [String], handler: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
            self.REF_GROUPS.observe(.value) { (groupSnapshot) in
                guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
                for group in groupSnapshot {
                    if ids.contains(group.key) {
                        let title = group.childSnapshot(forPath: "title").value as! String
                        let members = group.childSnapshot(forPath: "members").value as! [String]
                        groupsArray.append(Group(title: title, key: group.key, members: members, memberCount: members.count))
                    }
                }
                handler(groupsArray)
            }
    }
    
    func getGroup (forGroupId id: String, handler: @escaping (_ group: Group) -> ()) {
        self.REF_GROUPS.observe(.value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                if id == group.key {
                    let title = group.childSnapshot(forPath: "title").value as! String
                    let members = group.childSnapshot(forPath: "members").value as! [String]
                    handler(Group(title: title, key: group.key, members: members, memberCount: members.count))
                }
            }
            
        }
    }
    
    func getAllGroups (handler: @escaping (_ groupsArray: [Group]) -> ()) -> Void {
        var groupsArray = [Group]()
        getGroupIdArray(forUid: (Auth.auth().currentUser?.uid)!) { (groupIdArray) in
            self.getGroups(forGroupIdArray: groupIdArray, handler: { (groups) in
                handler(groups)
            })
        }
    }
    
    func getNumTransactions(inGroup key: String, handler: @escaping (_ canDelete: Bool) -> ()) {
        var groupName = ""
        var groupMemberCount = 0
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                if group.key == key {
                    groupName = group.childSnapshot(forPath: "title").value as! String
                    groupMemberCount = (group.childSnapshot(forPath: "members").value as! [String]).count
                }
            }
        }
        
        var numTransactions = 0
        REF_TRANSACTIONS.observeSingleEvent(of: .value) { (transactionSnapshot) in
            guard let transactionSnapshot = transactionSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for transaction in transactionSnapshot {
                let groupTitle = transaction.childSnapshot(forPath: "groupTitle").value as! String
                let settled = transaction.childSnapshot(forPath: "settled").value as! [String]
                if groupTitle == groupName && !(settled.count == groupMemberCount){
                    numTransactions += 1
                }
            }
            if numTransactions == 0 {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
    
    func deleteGroup (key: String, handler: @escaping (_ groupDeleted: Bool) -> ()) {
        var groupName = ""
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                if group.key == key {
                    groupName = group.childSnapshot(forPath: "title").value as! String
                }
            }
        }
            var members = [String]()
            REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
                guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
                for group in groupSnapshot {
                    if group.key == key {
                        members = group.childSnapshot(forPath: "members").value as! [String]
                        for userId in members {
                            self.REF_USERS.child(userId).child("groups").child(key).removeValue()
                        }
                    }
                }
            }
            
            REF_TRANSACTIONS.observeSingleEvent(of: .value) { (transactionSnapshot) in
                guard let transactionSnapshot = transactionSnapshot.children.allObjects as? [DataSnapshot] else {return}
                for transaction in transactionSnapshot {
                    let groupTitle = transaction.childSnapshot(forPath: "groupTitle").value as! String
                    if groupTitle == groupName {
                        self.REF_TRANSACTIONS.child(transaction.key).removeValue()
                    }
                    for userId in members {
                        self.REF_USERS.child(userId).child("transactions").child(transaction.key).removeValue()
                    }
                }
            }
            REF_GROUPS.child(key).removeValue()
            handler(true)
    }
    
    func getGroupName (forId key: String, handler: @escaping (_ name: String) -> ()) {
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                if group.key == key {
                    let groupName = group.childSnapshot(forPath: "title").value as! String
                    handler(groupName)
                }
            }
        }
    }
    
    func addMember (toGroup key: String, membersToAdd: [String], handler: @escaping (_ addedMember: Bool) -> ()) {
        var groupMembers  = [String]()
        
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                if group.key == key {
                    let currentMembers = group.childSnapshot(forPath: "members").value as! [String]
                    groupMembers = currentMembers + membersToAdd
                    self.REF_GROUPS.child(key).updateChildValues(["members": groupMembers])
                }
            }
        }
        handler(true)
    }
    
    func removeMember (fromGroup key: String, memberToDelete: String, groupName: String, handler: @escaping (_ removedMember: Bool) -> ()) {
        var groupMembers = [String]()
        
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groupSnapshot {
                if group.key == key {
                    let currentMembers = group.childSnapshot(forPath: "members").value as! [String]
                    groupMembers = currentMembers.filter { $0 != memberToDelete }
                    self.REF_USERS.child(memberToDelete).child("groups").child(key).removeValue()
                    self.REF_GROUPS.child(key).updateChildValues(["members": groupMembers])
                    handler(true)
                }
            }
        }
    }
    
    func getAmountForEmail (email: String, key: String, handler: @escaping () -> ()) {
        
    }
}
