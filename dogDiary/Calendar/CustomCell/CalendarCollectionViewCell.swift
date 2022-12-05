//
//  CalendarCollectionViewCell.swift
//  dogDiary
//
//  Created by najin on 2020/11/19.
//

import UIKit
import FSCalendar

class CalendarCollectionViewCell: FSCalendarCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var birthImageView: UIImageView!
    
    @IBOutlet weak var listView1: UIView!
    @IBOutlet weak var listView2: UIView!
    @IBOutlet weak var listView3: UIView!
    @IBOutlet weak var listView4: UIView!
    @IBOutlet weak var listView5: UIView!
    @IBOutlet weak var listView6: UIView!
    
    @IBOutlet weak var listLabel1: UILabel!
    @IBOutlet weak var listLabel2: UILabel!
    @IBOutlet weak var listLabel3: UILabel!
    @IBOutlet weak var listLabel4: UILabel!
    @IBOutlet weak var listLabel5: UILabel!
    @IBOutlet weak var listLabel6: UILabel!
    
    @IBOutlet weak var addListLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
