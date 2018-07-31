//
//  HomeVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-11-26.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var filterTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterView: RoundedModalView!
    @IBOutlet weak var settledTableView: UITableView!
    
    @IBOutlet weak var owedView: RoundedView!
    
    @IBOutlet weak var owingView: RoundedView!
    
    @IBOutlet weak var youAreOwedLbl: UILabel!
    @IBOutlet weak var youOweLbl: UILabel!
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var transactionStatusLbl: UILabel!
    @IBOutlet weak var settledTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var totalOwingLabel: UILabel!
    @IBOutlet weak var totalOwedLabel: UILabel!

    @IBOutlet weak var pendingTableView: UITableView!
    var owing: Float = 0.0
    var owed: Float = 0.0
    var transactionType = TransactionType.pending
    var sortOptions = ["Newest", "Oldest"]
    var filterOptions = ["Owed", "Owing", "None"]
    enum FilterType {
        case owing
        case owed
        case none
        
    }
    var filterType = FilterType.none
    @IBOutlet weak var pendingTableViewHeightConstraint: NSLayoutConstraint!
    
    var transactionsArray = [Transaction]()
    var settledArray = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilterView()
        setupSegmentControl()
        
        pendingTableView.delegate = self
        pendingTableView.dataSource = self
        pendingTableView.reloadData()
        
        settledTableView.isHidden = true
        pendingTableView.isHidden = false
        settledTableView.delegate = self
        settledTableView.dataSource = self
        settledTableView.reloadData()
        self.settledTableViewHeightConstraint.constant = min(CGFloat(self.settledArray.count) * self.settledTableView.rowHeight, self.view.frame.maxY - self.settledTableView.frame.minY)
        self.pendingTableViewHeightConstraint.constant = min(CGFloat(self.transactionsArray.count) * self.pendingTableView.rowHeight, self.view.frame.maxY - self.pendingTableView.frame.minY)
        self.transactionStatusLbl.isHidden = true
       
    }
    
    func setupSegmentControl () {
        self.segmentControl.layer.cornerRadius = 20
        self.segmentControl.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
        self.segmentControl.layer.borderWidth = 1
        self.segmentControl.layer.masksToBounds = true
        let font = UIFont(name: "AvenirNext-Regular", size: 15)
        segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: font],
                                              for: .normal)
    }
    
    func setupFilterView () {
        filterView.isHidden = true
        filterView.layer.borderWidth = 1.0
        filterView.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
        filterTableView.layer.cornerRadius = 20
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableViewHeightConstraint.constant = CGFloat(self.sortOptions.count) * self.filterTableView.rowHeight
        filterTableView.layer.masksToBounds = true
        filterTableView.reloadData()
        filterView.layer.shadowOpacity = 0.75
        filterView.layer.shadowRadius = 3
        filterView.layer.shadowOffset = CGSize.zero
        filterView.layer.shadowColor = UIColor.black.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch: UITouch? = touches.first
        if touch?.view != filterView{
            filterView.isHidden = true
        }
        
        if touch?.view == owingView && filterType != .owing {
            if transactionType == .pending {
                if filterType == .owed {
                    owedView.layer.borderWidth = 0.0
                }
                filterByOwing()
            }
        } else if touch?.view == owingView && filterType == .owing {
            getPendingTransactions()
            owingView.layer.borderWidth = 0.0
            filterType = .none
        } else if touch?.view == owedView && filterType != .owed {
            if transactionType == .pending {
                if filterType == .owing {
                    owingView.layer.borderWidth = 0.0
                }
                filterByOwed()
            }
        } else if touch?.view == owedView && filterType == .owed {
            getPendingTransactions()
            owedView.layer.borderWidth = 0.0
            filterType = .none
        }
    }
    
    func filterByOwed () {
        if filterType == .owing {
            getPendingTransactions()
        }
        filterType = .owed
        owedView.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
        owedView.layer.borderWidth = 2.0
        transactionsArray = transactionsArray.filter ( { !$0.payees.contains((Auth.auth().currentUser?.email)!) } )
        pendingTableView.reloadData()
        self.pendingTableViewHeightConstraint.constant = min(CGFloat(self.transactionsArray.count) * self.pendingTableView.rowHeight, self.view.frame.maxY - self.pendingTableView.frame.minY)
    }
    
    func filterByOwing () {
        owingView.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
        owingView.layer.borderWidth = 2.0
        if filterType == .owed {
            getPendingTransactions()
        }
        filterType = .owing
        transactionsArray = transactionsArray.filter ( { $0.payees.contains((Auth.auth().currentUser?.email)!) } )
        pendingTableView.reloadData()
        self.pendingTableViewHeightConstraint.constant = min(CGFloat(self.transactionsArray.count) * self.pendingTableView.rowHeight, self.view.frame.maxY - self.pendingTableView.frame.minY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
        DataService.instance.getOwed(userKey: (Auth.auth().currentUser?.uid)!) { (owed) in
            self.owed = owed
            self.totalOwedLabel.text = String(format: "$%.2f", owed)
        }
        DataService.instance.getOwing(userKey: (Auth.auth().currentUser?.uid)!) { (owing) in
            self.owing = owing
            self.totalOwingLabel.text = String(format: "$%.2f", owing)
        }
            getPendingTransactions()
            
            //filterTransactions(filterType: "Newest", transactionType: .pending)
        }
    }
    
    func getPendingTransactions () {
        DataService.instance.getAllTransactions { (returnedTransactionArray) in
            self.transactionsArray = returnedTransactionArray
            if self.transactionsArray.count == 0 && self.segmentControl.titleForSegment(at: self.segmentControl.selectedSegmentIndex) == "Pending" {
                self.transactionStatusLbl.text = "You have no pending transactions."
                self.transactionStatusLbl.isHidden = false
            } else {
                self.transactionStatusLbl.isHidden = true
            }
            self.pendingTableView.reloadData()
            self.pendingTableViewHeightConstraint.constant = min(CGFloat(self.transactionsArray.count) * self.pendingTableView.rowHeight, self.view.frame.maxY - self.pendingTableView.frame.minY)
        }
        self.pendingTableView.reloadData()
        
    }
    
    func getSettledTransactions () {
        DataService.instance.getAllSettledTransactions{ (settledTransactions) in
            self.settledArray = settledTransactions
            self.transactionStatusLbl.isHidden = true
            self.settledTableView.reloadData()
            self.settledTableViewHeightConstraint.constant = min(CGFloat(self.settledArray.count) * self.settledTableView.rowHeight, self.view.frame.maxY - self.settledTableView.frame.minY)
            
        }
        self.settledTableView.reloadData()
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            transactionType = .pending
            if self.transactionsArray.count == 0 {
                self.transactionStatusLbl.text = "You have no pending transactions."
                self.transactionStatusLbl.isHidden = false
            } else {
                self.transactionStatusLbl.isHidden = true
            }
            settledTableView.isHidden = true
            pendingTableView.isHidden = false
            pendingTableView.reloadData()
            
        } else {
            transactionType = .settled
            pendingTableView.isHidden = true
            settledTableView.isHidden = false
            if self.settledArray.count == 0 {
                self.transactionStatusLbl.text = "You have no settled transactions."
                self.transactionStatusLbl.isHidden = false
            } else {
                self.transactionStatusLbl.isHidden = true
            }
            getSettledTransactions()
            
        }
    }
    
    
    @IBAction func filterPressed(_ sender: Any) {
        if filterView.isHidden == true {
            filterView.isHidden = false
            
        } else {
            filterView.isHidden = true
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        if tableView == pendingTableView {
            numRows = transactionsArray.count
        } else if tableView == settledTableView {
            numRows = settledArray.count
        } else if tableView == filterTableView {
            numRows = sortOptions.count
        }
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        var transaction : Transaction
        var description = ""
        var owing = false
        var date = ""
        var groupName = ""
        var amount: Float = 0.0
        if tableView == pendingTableView {
            transaction = transactionsArray[indexPath.row]
            description = transaction.description
            owing = transaction.payees.contains((Auth.auth().currentUser?.email)!)
            date = transaction.date
            groupName = transaction.groupTitle
            
            if owing {
                amount = transaction.amount / Float(transaction.payees.count + 1)
            } else {
                amount = Float(transaction.payees.count - (transaction.settled.count - 1)) * (transaction.amount / Float(transaction.payees.count + 1))
            }
        } else if tableView == settledTableView {
            transaction = settledArray[indexPath.row]
            description = transaction.description
            owing = transaction.payees.contains((Auth.auth().currentUser?.email)!)
            date = transaction.date
            groupName = transaction.groupTitle
            
            if owing {
                amount = transaction.amount / Float(transaction.payees.count + 1)
            } else {
                amount = Float(transaction.payees.count - (transaction.settled.count - 1)) * (transaction.amount / Float(transaction.payees.count + 1))
            }
        }
        
        if transactionType == .pending {
            guard let pendingCell = pendingTableView.dequeueReusableCell(withIdentifier: "transactionCell") as? TransactionCell else {return UITableViewCell()}
            pendingCell.configureCell(description: description, owing: owing, date: date, amount: Float(amount), groupName: groupName, type: transactionType)
            cell = pendingCell
        } else if transactionType == .settled {
            guard let settledCell = settledTableView.dequeueReusableCell(withIdentifier: "settledCell") as? TransactionCell else {return UITableViewCell()}
            settledCell.configureCell(description: description, owing: owing, date: date, amount: Float(amount), groupName: groupName, type: transactionType)
            cell = settledCell
        }
        
        if tableView == filterTableView {
            guard let filterCell = filterTableView.dequeueReusableCell(withIdentifier: "filterCell") as? FilterCell else {return UITableViewCell()}
            filterCell.configureCell(type: sortOptions[indexPath.row])
            cell = filterCell
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let transactionVC = storyboard?.instantiateViewController(withIdentifier: "TransactionVC") as? TransactionVC else {return}
        if tableView == pendingTableView {
            if filterView.isHidden  {
                transactionVC.initData(forTransaction: transactionsArray[indexPath.row], type: .pending)
                presentDetail(transactionVC)
            }
        } else if tableView == settledTableView {
            if filterView.isHidden {
                transactionVC.initData(forTransaction: settledArray[indexPath.row], type: .settled)
                presentDetail(transactionVC)
            }
        } else if tableView == filterTableView {
            filterTransactions(filterType: sortOptions[indexPath.row], transactionType: transactionType)
            filterView.isHidden = true
        }
        
        
    }
    
    func filterTransactions (filterType: String, transactionType: TransactionType) {
        print(filterType)
        print(transactionType)
        var datesArrayString = [String]()
        var datesArray = [Date]()
        var amountArray = [Float]()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        if filterType == "Newest" && transactionType == .pending {
            for transaction in transactionsArray {
                datesArrayString.append(transaction.date)
            }
            for dat in datesArrayString {
                let date = dateFormatter.date(from: dat)
                if let date = date {
                    datesArray.append(date)
                }
            }
            let combined = zip(datesArray, transactionsArray).sorted(by: { $0.0.compare($1.0) == .orderedDescending })
            transactionsArray = combined.map {$0.1}
            pendingTableView.reloadData()
        } else if filterType == "Oldest" && transactionType == .pending {
            for transaction in transactionsArray {
                datesArrayString.append(transaction.date)
            }
            for dat in datesArrayString {
                let date = dateFormatter.date(from: dat)
                if let date = date {
                    datesArray.append(date)
                }
            }
            let combined = zip(datesArray, transactionsArray).sorted(by: { $0.0.compare($1.0) == .orderedAscending })
            transactionsArray = combined.map {$0.1}
            pendingTableView.reloadData()
        } else if filterType == "Newest" && transactionType == .settled {
            for transaction in settledArray {
                datesArrayString.append(transaction.date)
            }
            for dat in datesArrayString {
                let date = dateFormatter.date(from: dat)
                if let date = date {
                    datesArray.append(date)
                }
            }
            let combined = zip(datesArray, settledArray).sorted(by: { $0.0.compare($1.0) == .orderedDescending })
            settledArray = combined.map {$0.1}
            settledTableView.reloadData()
        } else if filterType == "Oldest" && transactionType == .settled {
            for transaction in settledArray {
                datesArrayString.append(transaction.date)
            }
            for dat in datesArrayString {
                let date = dateFormatter.date(from: dat)
                if let date = date {
                    datesArray.append(date)
                }
            }
            let combined = zip(datesArray, settledArray).sorted(by: { $0.0.compare($1.0) == .orderedAscending })
            settledArray = combined.map {$0.1}
            settledTableView.reloadData()
        }
    }
    
}
