//
//  GroupTransactionsVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-04.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import Firebase

class GroupTransactionsVC: UIViewController {
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0)

    @IBOutlet weak var memberCollectionView: UICollectionView!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var membersTextView: UITextView!
    var group: Group?
    var groupTransactions = [Transaction]()
    var maxHeight: CGFloat = 0.0
    var groupMembers = [String]()
    var memberCount = 0
    struct GroupMember {
        var name: String
        var email: String
        var amount: Float
        var owing: Bool
    }
    var members = [GroupMember]()
    var memberNames = [String]()
    
    func initData (forGroup group: Group) {
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memberCollectionView.delegate = self
        memberCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        groupNameLbl.text = group?.groupTitle
        DataService.instance.getEmails(forGroupKey: (self.group?.key)!) { (returnedEmails) in
            self.groupMembers = returnedEmails
            self.memberCount = self.groupMembers.count
        }
        DataService.instance.getNames(forGroupKey: (group?.key)!) { (returnedNames) in
            self.memberNames = returnedNames
            for i in 0..<self.memberNames.count {
                if self.memberNames[i] != "You" {
                    self.members.append(GroupMember(name: self.memberNames[i], email: self.groupMembers[i], amount: 0.0, owing: true))
                }
            }
            self.memberCollectionView.reloadData()
        }
        DataService.instance.getAllTransactions(forGroup: group!) { (returnedTransactions) in
            self.groupTransactions = returnedTransactions
            for transaction in self.groupTransactions {
                if transaction.payer == Auth.auth().currentUser?.email {
                    for payee in transaction.payees {
                        for i in 0..<self.members.count {
                            if self.members[i].email == payee {
                                self.members[i].amount += transaction.amount / Float(transaction.payees.count + 1)
                                if self.members[i].amount > 0 {
                                    self.members[i].owing = false
                                }
                            }
                        }
                    }
                } else if transaction.payees.contains((Auth.auth().currentUser?.email)!){
                    for i in 0..<self.members.count {
                        if self.members[i].email == transaction.payer {
                            self.members[i].amount -= transaction.amount / Float(transaction.payees.count + 1)
                            if self.members[i].amount < 0 {
                                self.members[i].owing = true
                            }
                            self.members[i].amount = abs(self.members[i].amount)
                        }
                    }
                }
            }
        self.memberCollectionView.reloadData()
        }
        
    }

    @IBAction func backPressed(_ sender: Any) {
        dismissDetail()
    }
    
    @IBAction func addPressed(_ sender: Any) {
        guard let editMembersVC = storyboard?.instantiateViewController(withIdentifier: "EditMembersVC") as? EditMembersVC else {return}
        editMembersVC.initData(group: group!, groupKey: group!.key)
        editMembersVC.modalPresentationStyle = .custom
        self.present(editMembersVC, animated: true, completion: nil)
    }
    
    @IBAction func removePressed(_ sender: Any) {
            if memberCount > 2 {
                guard let removeMembersVC = self.storyboard?.instantiateViewController(withIdentifier: "RemoveMembersVC") as? RemoveMembersVC else {return}
                removeMembersVC.initData(chosenGroup: self.group!)
                removeMembersVC.modalPresentationStyle = .custom
                self.present(removeMembersVC, animated: true, completion: nil)
            } else {
                let groupName = self.group?.groupTitle
                let alert = UIAlertController(title: "Remove members from \"\(groupName!)\"", message: "You cannot remove members from this group. There are only 2 people in this group.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let groupName = group?.groupTitle
        DataService.instance.getNumTransactions(inGroup: (group?.key)!) { (canDelete) in
            if canDelete {
                let deleteAlert = UIAlertController(title: "Delete \"\(groupName!)\"", message: "Are you sure you want to delete this group?", preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(title: "Delete group", style: .destructive, handler: { (buttonPressed) in
                    DataService.instance.deleteGroup(key: (self.group?.key)!, handler: { (groupDeleted) in
                        if groupDeleted {
                            self.dismissDetail()
                        }
                    })
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
                    deleteAlert.dismiss(animated: true, completion: nil)
                }
                deleteAlert.addAction(deleteAction)
                deleteAlert.addAction(cancelAction)
                self.present(deleteAlert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Delete \"\(groupName!)\"", message: "This group cannot be deleted. There are one or more pending transactions in this group.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
}

extension GroupTransactionsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberBalanceCell", for: indexPath) as? MemberBalanceCell else {return UICollectionViewCell()}
        cell.configureCell(name: members[indexPath.row].name, amount: members[indexPath.row].amount, owing: members[indexPath.row].owing)
        cell.layer.cornerRadius = 30
        return cell
    }
}

extension GroupTransactionsVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * 3
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / 2
        let heightPerItem = CGFloat(225)
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

