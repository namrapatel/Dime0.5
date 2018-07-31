//
//  GroupDetailsVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-12.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

class GroupDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var groupNameField: InsetTextField!
    
    @IBOutlet weak var groupsTableView: UITableView!
    
    @IBOutlet weak var payerTableView: UITableView!
    
    @IBOutlet weak var chosenPayeesTableView: UITableView!
    
    @IBOutlet weak var payeeTableView: UITableView!
    
    @IBOutlet weak var chosenPayeeTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var payeeTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var payeeField: InsetTextField!
    @IBOutlet weak var payerField: InsetTextField!
    
    @IBOutlet weak var groupsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var payerTableViewHeightConstraint: NSLayoutConstraint!
    var groupDict = [[String: String]]()
    var groupArray = [Group]()
    var payer: String = ""
    var payerArray = [String]()
    var payeeArray = [String]()
    var chosenUsers = [String]()
    var suggestedPayeeArray = [String]()
    var chosenGroup: String = ""
    var chosenGroupKey: String = ""
    var billDescription: String?
    var amount: Float?
    var date: String?
    
    func initData (billDescription: String, amount: Float, date: String) {
        self.billDescription = billDescription
        self.amount = amount
        self.date = date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        groupNameField.delegate = self
        groupNameField.addTarget(self, action: #selector(groupTextFieldDidChange), for: .editingChanged)
        groupsTableView.isHidden = true
        groupsTableView.layer.cornerRadius = 20
        groupsTableView.layer.masksToBounds = true
        groupsTableView.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
        groupsTableView.layer.borderWidth = 3.0
        
        payerTableView.delegate = self
        payerTableView.dataSource = self
        payerField.delegate = self
        payerField.addTarget(self, action: #selector(payerFieldTapped), for: .touchDown)
        payerTableView.isHidden = true
        payerTableView.layer.cornerRadius = 20
        payerTableView.layer.masksToBounds = true
        payerTableView.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
        payerTableView.layer.borderWidth = 1.0
        
        payeeTableView.delegate = self
        payeeTableView.dataSource = self
        payeeField.delegate = self
        payeeField.addTarget(self, action: #selector(payeeFieldTapped), for: .touchDown)
        payeeTableView.isHidden = true
        payeeTableView.layer.cornerRadius = 20
        payeeTableView.layer.masksToBounds = true
        payeeTableView.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
        payeeTableView.layer.borderWidth = 1.0
        
        chosenPayeesTableView.delegate = self
        chosenPayeesTableView.dataSource = self
        self.chosenPayeeTableViewHeightConstraint.constant = CGFloat(self.payeeArray.count) * self.chosenPayeesTableView.rowHeight
        chosenPayeesTableView.isHidden = false
        
        errorLbl.isHidden = true
        
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(EditMembersVC.closeTap(_:)))
        
        bgView.addGestureRecognizer(closeTouch)
    }
    
    @IBAction func deletePayeePressed(_ sender: UIButton) {
        let point = chosenPayeesTableView.convert(CGPoint.zero, from: sender)
        if let indexPath = chosenPayeesTableView.indexPathForRow(at: point) {
            chosenUsers = chosenUsers.filter { $0 != chosenUsers[indexPath.row]}
        }
        chosenPayeesTableView.reloadData()
        self.chosenPayeeTableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenPayeesTableView.rowHeight
    }
    
    
    @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
        payeeTableView.isHidden = true
        payerTableView.isHidden = true
        groupsTableView.isHidden = true
        errorLbl.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupNameField.becomeFirstResponder()
    }
    
    @objc func payerFieldTapped () {
        if payerField.layer.borderColor == #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1) {
            payerField.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
            let placeholder = NSAttributedString(string: payerField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)])
            payerField.attributedPlaceholder = placeholder
        }
        if chosenGroup != "" {
            self.payerTableView.isHidden = false
            self.payeeTableView.isHidden = true
            payerArray = []
            DataService.instance.getGroupMemberIds(forGroup: groupNameField.text!, handler: { (groupMemberIds) in
            for id in groupMemberIds {
                DataService.instance.getUsername(forUid: id, handler: { (email) in
                    if email != self.payer {
                        self.payerArray.append(email)
                        self.payerTableView.reloadData()
                        self.payerTableViewHeightConstraint.constant = CGFloat(self.payerArray.count * 40)
                    }
                })
            }
        })
        } else {
            self.payerTableView.isHidden = true
            errorLbl.isHidden = false
        }
    }

    
    @objc func payeeFieldTapped () {
        if payeeField.layer.borderColor == #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1) {
            payeeField.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
            let placeholder = NSAttributedString(string: payeeField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)])
            payeeField.attributedPlaceholder = placeholder
        }
        if chosenGroup != "" {
            self.payeeTableView.isHidden = false
            self.payerTableView.isHidden = true
            suggestedPayeeArray = []
            DataService.instance.getGroupMemberIds(forGroup: groupNameField.text!, handler: { (groupMemberIds) in
            for id in groupMemberIds {
                DataService.instance.getUsername(forUid: id, handler: { (email) in
                    if email != self.payer && !self.chosenUsers.contains(email){
                        self.suggestedPayeeArray.append(email)
                        if self.suggestedPayeeArray.count == 0 {
                            self.payeeTableView.isHidden = true
                        }
                        self.payeeTableView.reloadData()
                        self.payeeTableViewHeightConstraint.constant = CGFloat(self.suggestedPayeeArray.count * 40)
                    }
                })
            }
        })
        } else {
            self.payeeTableView.isHidden = true
            errorLbl.isHidden = false
        }
    }
    
    @objc func groupTextFieldDidChange () {
        if groupNameField.layer.borderColor == #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1) {
            groupNameField.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
            let placeholder = NSAttributedString(string: groupNameField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)])
            groupNameField.attributedPlaceholder = placeholder
        }
        if groupNameField.text == "" {
            self.groupsTableView.isHidden = true
            groupArray = []
        } else {
            self.groupsTableView.isHidden = false
            self.payeeTableView.isHidden = true
            self.payerTableView.isHidden = true
            DataService.instance.getGroupNames(forSearchQuery: groupNameField.text!, handler: { (groupArray) in
                self.groupArray = groupArray
                self.groupsTableViewHeightConstraint.constant = CGFloat(self.groupArray.count * 40)
                self.groupsTableView.reloadData()
            })
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if (groupNameField.text == "") {
            groupNameField.layer.borderColor = #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)
            let placeholder = NSAttributedString(string: groupNameField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)])
            groupNameField.attributedPlaceholder = placeholder
        }
        
        if (payerField.text == "") {
            payerField.layer.borderColor = #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)
            let placeholder = NSAttributedString(string: payerField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)])
            payerField.attributedPlaceholder = placeholder
        }
        
        if (chosenUsers.count == 0) {
            payeeField.layer.borderColor = #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)
            let placeholder = NSAttributedString(string: payeeField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)])
            payeeField.attributedPlaceholder = placeholder
        }
        
        
        let tabBar = storyboard?.instantiateViewController(withIdentifier: "MainTabBar")
        let payeesArray = payerArray.filter({ $0 != payer })
        if groupNameField.text != "" && payerField.text != "" && chosenUsers.count != 0 {
            DataService.instance.createTransaction(groupKey: chosenGroupKey, groupTitle: groupNameField.text!, description: billDescription!, payees: chosenUsers, payer: payerField.text!, date: date!, amount: amount!, settled: payeesArray, handler: { (transactionCreated) in
                if transactionCreated {
                    self.presentDetail(tabBar!)
                } else {
                    print("Transaction could not be created")
                }
            })
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismissDetail()
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if tableView == groupsTableView {
            numberOfRows = groupArray.count
        } else if tableView == payerTableView {
            numberOfRows = payerArray.count
        } else if tableView == payeeTableView {
            numberOfRows = suggestedPayeeArray.count
        } else if tableView == chosenPayeesTableView {
            numberOfRows = chosenUsers.count
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if tableView == groupsTableView {
            guard let groupCell = tableView.dequeueReusableCell(withIdentifier: "searchGroupCell") as? SearchGroupCell else {return UITableViewCell()}
            groupCell.configureCell(groupName: groupArray[indexPath.row].groupTitle)
            cell = groupCell
        } else if tableView == payerTableView {
            guard let userCell = tableView.dequeueReusableCell(withIdentifier: "searchUserCell") as? SearchUserCell else {return UITableViewCell()}
            userCell.configureCell(email: payerArray[indexPath.row], sender: "transaction")
            cell = userCell
        } else if tableView == payeeTableView {
            guard let payeeCell = tableView.dequeueReusableCell(withIdentifier: "searchUserCell") as? SearchUserCell else {return UITableViewCell()}
            payeeCell.configureCell(email: suggestedPayeeArray[indexPath.row], sender: "payee")
            cell = payeeCell
        } else if tableView == chosenPayeesTableView {
            guard let chosenPayeesCell = tableView.dequeueReusableCell(withIdentifier: "addUserCell") as? AddUserCell else {return UITableViewCell()}
            DataService.instance.getName(forEmail: chosenUsers[indexPath.row], handler: { (name) in
                chosenPayeesCell.configureCell(email: self.chosenUsers[indexPath.row], name: name, sender: "groupDetails")
            })
            
            cell = chosenPayeesCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == groupsTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? SearchGroupCell else {return}
            chosenGroup = cell.groupNameLbl.text!
            chosenGroupKey = groupArray[indexPath.row].key
            self.groupNameField.text = chosenGroup
            self.groupsTableView.isHidden = true
            errorLbl.isHidden = true
        } else if tableView == payerTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? SearchUserCell else {return}
            payer = cell.userEmailLbl.text!
            if chosenUsers.contains(payer) {
                chosenUsers = chosenUsers.filter { $0 != payer }
                chosenPayeesTableView.reloadData()
            }
            self.payerField.text = payer
            self.payerTableView.isHidden = true
        } else if tableView == payeeTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? SearchUserCell else {return}
            if !chosenUsers.contains(cell.payeeEmailLbl.text!) {
                chosenUsers.append(cell.payeeEmailLbl.text!)
            }
            self.payeeTableView.isHidden = true
            self.chosenPayeesTableView.isHidden = false
            self.chosenPayeesTableView.reloadData()
            self.chosenPayeeTableViewHeightConstraint.constant = CGFloat(self.chosenUsers.count) * self.chosenPayeesTableView.rowHeight
            self.payeeField.text = ""
        }
    }

}

extension GroupDetailsVC: UITextFieldDelegate {
    
}
