//
//  GroupsVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-11-26.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

class GroupsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    var groupsArray = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
            DataService.instance.getAllGroups { (returnedGroupsArray) in
                self.groupsArray = returnedGroupsArray
                self.tableView.reloadData()
                self.tableViewHeightConstraint.constant = min(CGFloat(self.groupsArray.count) * self.tableView.rowHeight, self.view.frame.maxY - self.tableView.frame.minY)
            }
        }
        
    }
}

extension GroupsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as? GroupCell else {return UITableViewCell()}
        let group = groupsArray[indexPath.row]
        cell.configureCell(groupName: group.groupTitle, memberCount: group.memberCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let groupTransactionVC = storyboard?.instantiateViewController(withIdentifier: "GroupTransactionsVC") as? GroupTransactionsVC else {return}
        groupTransactionVC.initData(forGroup: groupsArray[indexPath.row])
        presentDetail(groupTransactionVC)
        
    }
}
