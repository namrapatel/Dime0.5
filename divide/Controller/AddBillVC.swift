//
//  AddBillVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-03.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

class AddBillVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    

    @IBOutlet weak var billDescriptionField: InsetTextField!
    @IBOutlet weak var amountField: InsetTextField!
    @IBOutlet weak var paidByField: InsetTextField!
    @IBOutlet weak var dateField: InsetTextField!
    @IBOutlet weak var cycleTextField: InsetTextField!
    @IBOutlet weak var durationTextField: InsetTextField!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var nextBtn: UIButton!
    
    var groupArray = [String]()
    var payer: String = ""
    var payerArray = [String]()
    var chosenGroup: String = ""
    var date: String?
    var amount: String?
    
    let cycleOptions = [["Every"],["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"],["Day(s)","Week(s)","Month(s)","Year(s)"]]
    
    let durationOptions = [["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"],["Day(s)","Week(s)","Month(s)","Year(s)"]]
    
    let picker = UIDatePicker()
    let cyclePickerView = UIPickerView()
    let durationPickerView = UIPickerView()
    
    func initData (scannedDate: String, amount: String) {
        self.date = scannedDate
        self.amount = amount
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        billDescriptionField.delegate = self
        billDescriptionField.addTarget(self, action: #selector(descFieldChanged), for: .editingChanged)
        dateField.delegate = self
        amountField.delegate = self
        amountField.addTarget(self, action: #selector(amountFieldChanged), for: .editingChanged)
        createDatePicker()
        if date != nil {
            dateField.text = date
        }
        if amount != nil {
            amountField.text = amount?.currencyInputFormatting()
        }
        self.segmentControl.layer.cornerRadius = 20
        self.segmentControl.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
        self.segmentControl.layer.borderWidth = 1
        self.segmentControl.layer.masksToBounds = true
        let font = UIFont(name: "AvenirNext-Regular", size: 15)
        segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: font],
                                              for: .normal)
        cycleTextField.delegate = self
        
        cyclePickerView.delegate = self
        cyclePickerView.tag = 1
        
        let cycleToolbar = UIToolbar()
        cycleToolbar.sizeToFit()
        
        let doneCycle = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneCyclePressed))
        cycleToolbar.setItems([doneCycle], animated: false)
        cycleTextField.inputAccessoryView = cycleToolbar
        cycleTextField.inputView = cyclePickerView
        cyclePickerView.selectRow(0, inComponent: 0, animated: true)
        cyclePickerView.selectRow(0, inComponent: 1, animated: true)
        cyclePickerView.selectRow(2, inComponent: 2, animated: true)
        
        
        durationTextField.delegate = self
        
        durationPickerView.delegate = self
        durationPickerView.tag = 2
        durationPickerView.selectRow(0, inComponent: 0, animated: true)
        durationPickerView.selectRow(3, inComponent: 1, animated: true)
        let durationToolbar = UIToolbar()
        durationToolbar.sizeToFit()
        let doneDuration = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneDurationPressed))
        durationToolbar.setItems([doneDuration], animated: false)
        durationTextField.inputAccessoryView = durationToolbar
        durationTextField.inputView = durationPickerView
        
        cycleTextField.isHidden = true
        durationTextField.isHidden = true
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            cycleTextField.isHidden = true
            durationTextField.isHidden = true
        } else {
            cycleTextField.isHidden = false
            durationTextField.isHidden = false
        }
    }
    
    @objc func descFieldChanged () {
        if billDescriptionField.layer.borderColor == #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1) {
            billDescriptionField.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
            let placeholder = NSAttributedString(string: billDescriptionField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)])
            billDescriptionField.attributedPlaceholder = placeholder
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        billDescriptionField.becomeFirstResponder()
    }
    
    
    
    
    @objc func doneCyclePressed () {
        let every = cycleOptions[0][cyclePickerView.selectedRow(inComponent: 0)]
        let number = cycleOptions[1][cyclePickerView.selectedRow(inComponent: 1)]
        let dates = cycleOptions[2][cyclePickerView.selectedRow(inComponent: 2)]
        if number == "1" {
            let end = dates.index(of: "(")!
            cycleTextField.text = every + " " + dates[..<end].lowercased()
        } else {
            let end = dates.index(of: "(")!
            cycleTextField.text = every + " " + number + " " + dates[..<end].lowercased() + "s"
        }
        view.endEditing(true)
    }
    
    @objc func doneDurationPressed () {
        let number = durationOptions[0][durationPickerView.selectedRow(inComponent: 0)]
        let dates = durationOptions[1][durationPickerView.selectedRow(inComponent: 1)]
        if number == "1" {
            let end = dates.index(of: "(")!
            durationTextField.text = number + " " + dates[..<end].lowercased()
        } else {
            let end = dates.index(of: "(")!
            durationTextField.text = number + " " + dates[..<end].lowercased() + "s"
        }
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1 {
            return cycleOptions.count
        } else if pickerView.tag == 2 {
            return durationOptions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return cycleOptions[component].count
        } else if pickerView.tag == 2 {
            return durationOptions[component].count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return cycleOptions[component][row]
        } else if pickerView.tag == 2 {
            return durationOptions[component][row]
        }
        return ""
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if pickerView.tag == 1 {
//            let every = cycleOptions[0][pickerView.selectedRow(inComponent: 0)]
//            let number = cycleOptions[1][pickerView.selectedRow(inComponent: 1)]
//            let dates = cycleOptions[2][pickerView.selectedRow(inComponent: 2)]
//            if number == "1" {
//                let end = dates.index(of: "(")!
//                cycleTextField.text = every + " " + dates[..<end].lowercased()
//            } else {
//                let end = dates.index(of: "(")!
//                cycleTextField.text = every + " " + number + " " + dates[..<end].lowercased() + "s"
//            }
//        } else if pickerView.tag == 2  {
//            let number = durationOptions[0][pickerView.selectedRow(inComponent: 0)]
//            let dates = durationOptions[1][pickerView.selectedRow(inComponent: 1)]
//            if number == "1" {
//                let end = dates.index(of: "(")!
//                durationTextField.text = number + " " + dates[..<end].lowercased()
//            } else {
//                let end = dates.index(of: "(")!
//                durationTextField.text = number + " " + dates[..<end].lowercased() + "s"
//            }
//        }
//    }
    
    
    func createDatePicker () {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        dateField.inputAccessoryView = toolbar
        dateField.inputView = picker
        if date != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            picker.date = formatter.date(from: date!)!
        }
        picker.datePickerMode = .date
    }
    
    @objc func donePressed() {
        if dateField.layer.borderColor == #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1) {
            dateField.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
            let placeholder = NSAttributedString(string: dateField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)])
            dateField.attributedPlaceholder = placeholder
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let result = formatter.string(from: picker.date)
        date = result
        dateField.text = "\(result)"
        self.view.endEditing(true)
    }
    
    @objc func amountFieldChanged () {
        if amountField.layer.borderColor == #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1) {
            amountField.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
            let placeholder = NSAttributedString(string: amountField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)])
            amountField.attributedPlaceholder = placeholder
        }
        amountField.text = amountField.text?.currencyInputFormatting()
    }

    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {
        
        if (billDescriptionField.text == "") {
            billDescriptionField.layer.borderColor = #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)
            let placeholder = NSAttributedString(string: billDescriptionField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)])
            billDescriptionField.attributedPlaceholder = placeholder
        }
        
        if amountField.text == "" {
            amountField.layer.borderColor = #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)
            let placeholder = NSAttributedString(string: amountField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)])
            amountField.attributedPlaceholder = placeholder
        }
        
        if dateField.text == "" {
            dateField.layer.borderColor = #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)
            let placeholder = NSAttributedString(string: dateField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)])
            dateField.attributedPlaceholder = placeholder
        }
        
        guard let groupDetailsVC = storyboard?.instantiateViewController(withIdentifier: "GroupDetailsVC") as? GroupDetailsVC else {return}
        
        let amountFieldWithoutCurrency = amountField.text?.replacingOccurrences(of: "$", with: "")
        
        if billDescriptionField.text != "" && amountField.text != "" && dateField.text != "" {
            groupDetailsVC.initData(billDescription: billDescriptionField.text!, amount: Float(amountFieldWithoutCurrency!.replacingOccurrences(of: ",", with: ""))!, date: date!)
        presentDetail(groupDetailsVC)
        }
    }
  
}



extension AddBillVC: UITextFieldDelegate {
    
}
