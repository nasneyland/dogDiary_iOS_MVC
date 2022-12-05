//
//  MyDogCollectionViewCell.swift
//  dogDiary
//
//  Created by najin on 2020/12/09.
//

import UIKit

class MyDogCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var myDogView: UIView!
    @IBOutlet weak var myDogImageOuterView: UIView!
    @IBOutlet weak var myDogImageView: UIImageView!
    @IBOutlet weak var myDogName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
