//
//  ChooseGroupIconVC.swift
//  Funder
//
//  Created by Namra Patel on 2018-01-24.
//  Copyright © 2018 Namra Patel. All rights reserved.
//

import UIKit

protocol IconDelegate {
    func iconChanged (icon: UIImage)
}

class ChooseGroupIconVC: UIViewController {
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    var imageArray = [UIImage]()
    var delegate : IconDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        imageArray.append(UIImage(named: "friends.png")!)
        imageArray.append(UIImage(named: "buildings.png")!)
        imageArray.append(UIImage(named: "homeIcon.png")!)
        imageArray.append(UIImage(named: "trip.png")!)
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ChooseGroupIconVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupIconCell", for: indexPath) as? GroupIconCell else {return UICollectionViewCell()}
        cell.configureCell(image: imageArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let createGroupVC = storyboard?.instantiateViewController(withIdentifier: "createGroupVC") as? CreateGroupVC else {return}
        if delegate != nil {
            delegate?.iconChanged(icon: imageArray[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ChooseGroupIconVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * 8
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / 4
        let heightPerItem = widthPerItem
        
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
