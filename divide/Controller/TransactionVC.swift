//
//  TransactionVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-05.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import Firebase

class TransactionVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var settleBtn: RoundedButton!
    
    var transaction: Transaction?
    var emailArray = [String]()
    var amountArray = [Float]()
    var transactionType = TransactionType.pending


    func initData (forTransaction transaction: Transaction, type: TransactionType) {
        self.transaction = transaction
        self.transactionType = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser?.email == transaction!.payer || transactionType == .settled{
            self.settleBtn.isHidden = true
        }
        tableView.delegate = self
        tableView.dataSource = self
        emailArray.append((transaction?.payer)!)
        amountArray.append((transaction?.amount)!)
        if Auth.auth().currentUser?.email == transaction?.payer {
            for payee in (transaction?.payees)! {
                emailArray.append(payee)
                amountArray.append((transaction?.amount)! / (Float((transaction?.payees.count)!) + 1))
            }
        } else {
            emailArray.append((Auth.auth().currentUser?.email)!)
            amountArray.append((transaction?.amount)! / (Float((transaction?.payees.count)!) + 1))
        }
        
        self.tableViewHeightConstraint.constant = CGFloat(self.emailArray.count) * self.tableView.rowHeight
        descriptionLbl.text = transaction?.description
        groupNameLbl.text = transaction?.groupTitle
        dateLbl.text = transaction?.date
    }

    @IBAction func backPressed(_ sender: Any) {
        dismissDetail()
    }
    

    @IBAction func settlePressed(_ sender: Any) {
        DataService.instance.settleTransaction(transaction: transaction!) { (transactionSettled) in
            if transactionSettled {
                self.dismissDetail()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "balanceUserCell") as? BalanceUserCell else {return UITableViewCell()}
        let email = emailArray[indexPath.row]
        let paid = transaction?.payer == email
        var amount: Float = 0.0
        if transactionType == .pending {
            amount = amountArray[indexPath.row]
        }
        if transactionType == .settled {
            
            settleBtn.isHidden = true
        }
        cell.configureCell(email: email, paid: paid, amount: amount, transaction: transaction!)
        return cell
    }
}
