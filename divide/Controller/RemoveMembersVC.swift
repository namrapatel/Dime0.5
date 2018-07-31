//
//  RemoveMembersVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-15.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import Firebase
class RemoveMembersVC: UIViewController {

    var users = [String]()
    var group: Group?
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var chosenUsersTableViewHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var chosenUsersTableView: UITableView!
    
    func initData (chosenGroup: Group) {
        self.group = chosenGroup
        DataService.instance.getEmails(forGroupKey: (group?.key)!) { (returnedEmails) in
            self.users = returnedEmails.filter { $0 != Auth.auth().currentUser?.email }
            self.chosenUsersTableView.reloadData()
            self.chosenUsersTableViewHeightConstrain.constant = CGFloat(self.users.count) * self.chosenUsersTableView.rowHeight
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chosenUsersTableView.delegate = self
        self.chosenUsersTableView.dataSource = self
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(RemoveMembersVC.closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func deleteMember (userEmail: String) {
        DataService.instance.getId(forEmail: userEmail) { (id) in
            DataService.instance.removeMember(fromGroup: (self.group?.key)!, memberToDelete: id, groupName: (self.group?.groupTitle)!) { (memberRemoved) in
            }
        }
        
    }
    
    @IBAction func deleteUserPressed(_ sender: UIButton) {
        var currentMembers = [String]()
        let point = chosenUsersTableView.convert(CGPoint.zero, from: sender)
        if let indexPath = chosenUsersTableView.indexPathForRow(at: point) {
            if let groupName = self.group?.groupTitle {
                let alert = UIAlertController(title: "Remove member from group", message: "Are you sure you want to remove \(self.users[indexPath.row]) from \(groupName)?", preferredStyle: .alert)
                let removeAction = UIAlertAction(title: "Yes", style: .default) { (buttonPressed) in
                    self.deleteMember(userEmail: self.users[indexPath.row])
                    self.users = self.users.filter { $0 != self.users[indexPath.row]}
                    self.chosenUsersTableView.reloadData()
                    self.chosenUsersTableViewHeightConstrain.constant = CGFloat(self.users.count) * self.chosenUsersTableView.rowHeight
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(removeAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension RemoveMembersVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addUserCell") as? AddUserCell else {return UITableViewCell()}
        let email = users[indexPath.row]
        DataService.instance.getName(forEmail: email) { (name) in
            cell.configureCell(email: email, name: name, sender: "removeMember")
        }
        return cell
    }
}
