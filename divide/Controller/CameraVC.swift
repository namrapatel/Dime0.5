//
//  CameraVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-11-28.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import AVFoundation
import TesseractOCR

class CameraVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var takePhotoBtn: RoundedButton!

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        takePhotoBtn.setTitle("Take Photo / Upload Image", for: .normal)
    }
    
    func performImageRecognition(_ image: UIImage) {
        var date = Date()
        var amount = ""
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            var fullText = tesseract.recognizedText.lowercased()
            var fullTextArray = fullText.lowercased().components(separatedBy: " ")
            var totalFound = false
            var possibleAmountString: String
            var possibleAmountArray = [Float]()
            for word in fullTextArray {
                    possibleAmountString = word.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
                    let pattern = "\\d+\\.\\d{2}"
                    let amountRegex = try! NSRegularExpression(pattern: pattern, options: [])
                    let matches = amountRegex.matches(in: possibleAmountString, options: [], range: NSMakeRange(0, possibleAmountString.count))
                    print(matches.count)
                    print(possibleAmountString)
                    print("")
                    if matches.count == 1{
                        if let possibleAmount = Float(possibleAmountString){
                            possibleAmountArray.append(possibleAmount)
                        
                        }
                    }
                
            }
            print(possibleAmountArray)
            if possibleAmountArray.count != 0 {
            amount = String(format: "$%.2f", possibleAmountArray.max()!)
            }
            let types: NSTextCheckingResult.CheckingType = [.date ]
            let detector = try? NSDataDetector(types: types.rawValue)
            let result = detector?.firstMatch(in: fullText, range: NSMakeRange(0,fullText.utf16.count))
            if result?.resultType == .date && (result?.date)! <= date {
                date = (result?.date)!
            }
        }
        guard let addBillVC = storyboard?.instantiateViewController(withIdentifier: "AddBillVC") as? AddBillVC else {return}
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let result = formatter.string(from: date)
        addBillVC.initData(scannedDate: result, amount: amount)
        present(addBillVC, animated: true, completion: nil)
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        takePhotoBtn.setTitle("Take Photo / Upload Image", for: .normal)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        presentImagePicker()
    }
    
}

extension CameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentImagePicker() {
        let imagePickerActionSheet = UIAlertController(title: "Take Photo/Upload Image",
                                                       message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }

        let libraryButton = UIAlertAction(title: "Choose from Camera Roll",
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        present(imagePickerActionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let scaledImage = selectedPhoto.scaleImage(640) {
            imageView.image = scaledImage.g8_blackAndWhite()
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            takePhotoBtn.setTitle("", for: .normal)
            dismiss(animated: true, completion: {
                self.performImageRecognition(scaledImage)
            })
        }
    }
}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

