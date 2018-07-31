//
//  AddMemberVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-09.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import Firebase

class EditMembersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var deleteUserButton: RoundedButton!
    @IBOutlet weak var doneBtn: RoundedButton!
    
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var addBtn: RoundedButton!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var membersTextField: InsetTextField!
    
    @IBOutlet weak var usersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chosenUsersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chosenUsersTableView: UITableView!
    
    @IBOutlet weak var bgView: UIView!
    var chosenUsers = [String]()
    var membersArray = [String]()
    var currentUsers = [String]()
    var group: Group?
    var groupKey: String?
    func initData (group: Group, groupKey: String) {
        DataService.instance.getEmails(forGroupKey: groupKey) { (returnedEmails) in
            self.currentUsers = returnedEmails
        }
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLbl.isHidden = true
        membersTextField.delegate = self
        membersTextField.addTarget(self, action: #selector(membersFieldDidChange), for: .editingChanged)
        
        chosenUsersTableView.delegate = self
        chosenUsersTableView.dataSource = self
        self.chosenUsersTableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenUsersTableView.rowHeight
        chosenUsersTableView.reloadData()
        chosenUsersTableView.isHidden = false
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.isHidden = true
        usersTableView.layer.cornerRadius = 20
        usersTableView.layer.masksToBounds = true
        usersTableView.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
        usersTableView.layer.borderWidth = 1.0
        
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(EditMembersVC.closeTap(_:)))
            
        bgView.addGestureRecognizer(closeTouch)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        membersTextField.becomeFirstResponder()
    }
    
    
    @IBAction func cancelAddUser(_ sender: UIButton) {
        let point = chosenUsersTableView.convert(CGPoint.zero, from: sender)
        if let indexPath = chosenUsersTableView.indexPathForRow(at: point) {
            print(self.chosenUsers)
            self.chosenUsers = self.chosenUsers.filter { $0 != self.chosenUsers[indexPath.row]}
            print(chosenUsers)
            print(indexPath.row)
            print(chosenUsers.count)
        }
        self.chosenUsersTableView.reloadData()
        self.chosenUsersTableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenUsersTableView.rowHeight
    }
    
    
    @objc func membersFieldDidChange () {
        if membersTextField.text == "" {
            self.usersTableView.isHidden = true
            membersArray = []
            usersTableView.reloadData()
            self.chosenUsersTableView.isHidden = false
            errorLbl.isHidden = true
        } else {
            if chosenUsers.count == 0 {
                self.chosenUsersTableView.isHidden = true
            }
            self.errorLbl.isHidden = true
            DataService.instance.getFriends(forSearchQuery: membersTextField.text!, handler: { (friendsArray) in
                self.usersTableView.isHidden = false
                self.membersArray = friendsArray.filter { !self.chosenUsers.contains($0) && !self.currentUsers.contains($0) }
                self.usersTableViewHeightConstraint.constant = CGFloat(self.membersArray.count * 40)
                self.usersTableView.reloadData()
            })
        }
    }

    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: Any) {
        var addedMembers = chosenUsers.filter { !self.currentUsers.contains($0) }
        var memberIds = [String]()
        DataService.instance.getIds(forEmails: addedMembers) { (ids) in
            memberIds = ids
            DataService.instance.addMember(toGroup: (self.group?.key)!, membersToAdd: memberIds) { (membersAdded) in
                if membersAdded {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func addPressed(_ sender: Any) {
        if membersTextField.text! == "" {
            chosenUsersTableView.reloadData()
            errorLbl.isHidden = true
        } else if chosenUsers.contains(membersTextField.text!) {
            chosenUsersTableView.reloadData()
            errorLbl.isHidden = false
            errorLbl.text = "This user has already been chosen."
        } else if membersTextField.text! == Auth.auth().currentUser?.email {
            errorLbl.isHidden = false
            errorLbl.text = "You're already part of the group!"
        } else if currentUsers.contains(membersTextField.text!){
            errorLbl.isHidden = false
            errorLbl.text = "This user is already part of the group."
        }  else {
            chosenUsersTableView.isHidden = false
            usersTableView.isHidden = true
            DataService.instance.getEmail(forSearchQuery: membersTextField.text!, handler: { (returnedEmail) in
                DataService.instance.addFriend(byEmail: returnedEmail, handler: { (added) in
                    if added {
                        self.chosenUsers.append(returnedEmail)
                        self.doneBtn.isHidden = false
                        self.chosenUsersTableView.reloadData()
                        self.membersTextField.text = ""
                        self.chosenUsersTableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenUsersTableView.rowHeight
                    }
                })
                
            })
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if tableView == chosenUsersTableView {
            numberOfRows = chosenUsers.count
        } else if tableView == usersTableView {
            numberOfRows = membersArray.count
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        if tableView == chosenUsersTableView {
            guard let addUserCell = tableView.dequeueReusableCell(withIdentifier: "addUserCell", for: indexPath) as? AddUserCell else {return UITableViewCell()}
            DataService.instance.getName(forEmail: self.chosenUsers[indexPath.row], handler: { (name) in
                addUserCell.configureCell(email: self.chosenUsers[indexPath.row], name: name, sender: "addMember")
            })
            cell = addUserCell
        } else if tableView == usersTableView {
            if membersArray.count != 0 {
                guard let searchUserCell = tableView.dequeueReusableCell(withIdentifier: "searchUserCell") as? SearchUserCell else {return UITableViewCell()}
                searchUserCell.configureCell(email: membersArray[indexPath.row], sender: "addMember")
                cell = searchUserCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == usersTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? SearchUserCell else {return}
            if !chosenUsers.contains(cell.friendEmailLblFromGroup.text!) {
                chosenUsers.append(cell.friendEmailLblFromGroup.text!)
            }
            self.usersTableView.isHidden = true
            self.chosenUsersTableView.isHidden = false
            self.chosenUsersTableView.reloadData()
            self.chosenUsersTableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenUsersTableView.rowHeight
            self.membersTextField.text = ""
        }
    }
}



extension EditMembersVC: UITextFieldDelegate {
    
}
