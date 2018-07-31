//
//  CreateGroupVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-11-27.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, IconDelegate {
    func iconChanged(icon: UIImage) {
        self.groupImageView.image = icon
    }

    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var groupNameField: InsetTextField!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var membersField: InsetTextField!
    @IBOutlet weak var chosenUsersTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var usersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var addBtn: RoundedButton!
    
    var matchEmail: String = ""
    var chosenUsers = [String]()
    var membersArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLbl.isHidden = true
        chosenUsersTableView.delegate = self
        chosenUsersTableView.dataSource = self
        membersField.delegate = self
        self.tableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenUsersTableView.rowHeight
        chosenUsersTableView.isHidden = false
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        membersField.addTarget(self, action: #selector(membersFieldDidChange), for: .editingChanged)
        usersTableView.isHidden = true
        usersTableView.layer.cornerRadius = 20
        usersTableView.layer.masksToBounds = true
        usersTableView.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
        usersTableView.layer.borderWidth = 1.0
        groupImageView.image = UIImage(named: "friends.png")!
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        groupImageView.isUserInteractionEnabled = true
        groupImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        guard let chooseGroupIconVC = storyboard?.instantiateViewController(withIdentifier: "chooseGroupIconVC") as? ChooseGroupIconVC else {return}
        chooseGroupIconVC.delegate = self
        present(chooseGroupIconVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupNameField.becomeFirstResponder()
    }
    
    @objc func membersFieldDidChange () {
        if membersField.text == "" {
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
            DataService.instance.getFriends(forSearchQuery: membersField.text!, handler: { (friendsArray) in
                self.usersTableView.isHidden = false
                self.membersArray = friendsArray.filter { !self.chosenUsers.contains($0) }
                self.usersTableViewHeightConstraint.constant = CGFloat(self.membersArray.count * 40)
                self.usersTableView.reloadData()
            })
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addPressed(_ sender: Any) {
        if membersField.text! == "" {
            chosenUsersTableView.reloadData()
            errorLbl.isHidden = true
        } else if chosenUsers.contains(membersField.text!) {
            chosenUsersTableView.reloadData()
            errorLbl.isHidden = false
            errorLbl.text = "This user has already been chosen."
        } else if membersField.text! == Auth.auth().currentUser?.email {
            errorLbl.isHidden = false
            errorLbl.text = "That's your email! You'll be added to the group too!"
        } else {
            chosenUsersTableView.isHidden = false
            usersTableView.isHidden = true
            DataService.instance.getEmail(forSearchQuery: membersField.text!, handler: { (returnedEmail) in
                if returnedEmail != nil {
                DataService.instance.addFriend(byEmail: returnedEmail, handler: { (added) in
                    if added {
                        self.chosenUsers.append(returnedEmail)
                        self.doneBtn.isHidden = false
                        self.chosenUsersTableView.reloadData()
                        self.membersField.text = ""
                        self.tableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenUsersTableView.rowHeight
                    }
                })
                } else {
                        self.errorLbl.isHidden = false
                        self.errorLbl.text = "This user does not have a Funder account."
                }
            })
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if groupNameField.text != "" && chosenUsers.count != 0 {
            DataService.instance.getIds(forEmails: chosenUsers, handler: { (idsArray) in
                var userIds = idsArray
                userIds.append((Auth.auth().currentUser?.uid)!)
                DataService.instance.createGroup(withTitle: self.groupNameField.text!, ids: userIds, handler: { (groupCreated) in
                    if groupCreated {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("Group could not be created.")
                    }
                })
            })
        }
    }
    

    @IBAction func deletePressed(_ sender: UIButton) {
         let point = chosenUsersTableView.convert(CGPoint.zero, from: sender)
        if let indexPath = chosenUsersTableView.indexPathForRow(at: point) {
            chosenUsers = chosenUsers.filter { $0 != chosenUsers[indexPath.row]}
        }
        chosenUsersTableView.reloadData()
        self.tableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenUsersTableView.rowHeight
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
            DataService.instance.getName(forEmail: chosenUsers[indexPath.row], handler: { (name) in
                addUserCell.configureCell(email: self.chosenUsers[indexPath.row], name: name, sender: "group")
            })
            
            cell = addUserCell
        } else if tableView == usersTableView {
            if membersArray.count != 0 {
                guard let searchUserCell = tableView.dequeueReusableCell(withIdentifier: "searchUserCell") as? SearchUserCell else {return UITableViewCell()}
                searchUserCell.configureCell(email: membersArray[indexPath.row], sender: "group")
                cell = searchUserCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == usersTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? SearchUserCell else {return}
            if !chosenUsers.contains(cell.friendEmailLbl.text!) {
                chosenUsers.append(cell.friendEmailLbl.text!)
            }
            self.usersTableView.isHidden = true
            self.chosenUsersTableView.isHidden = false
            self.chosenUsersTableView.reloadData()
            self.tableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenUsersTableView.rowHeight
            self.membersField.text = ""
        }
    }
}

extension CreateGroupVC: UITextFieldDelegate {
    
}
