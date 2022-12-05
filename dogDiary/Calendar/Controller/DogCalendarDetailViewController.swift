//
//  DogCalendarDetailViewController.swift
//  dogDiary
//
//  Created by najin on 2020/11/20.
//

import UIKit

class DogCalendarDetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    
    var seletedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //날짜 셋팅하기
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "yyyy.M.d(eee)"
        let dateString = dateFormatter.string(from: seletedDate!)
        dateLabel.text = dateString
    }
}
