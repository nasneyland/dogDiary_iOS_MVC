//
//  WashUpdateViewController.swift
//  dogDiary
//
//  Created by najin on 2021/02/19.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class WashUpdateViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var updateButton: UIButton!
    //날짜 입력
    @IBOutlet weak var datePopOuterView: UIView!
    @IBOutlet weak var datePopUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var dateCancelButton: UIButton!
    
    var date: String!
    var dateString: String?
    var indicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //indicator 셋팅
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true
        
        //산책 날짜 수정
        datePopOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        datePopOuterView.isHidden = true
        datePopUpView.layer.cornerRadius = 10
        dateCancelButton.layer.cornerRadius = 5
        dateButton.layer.cornerRadius = 5
        dateButton.backgroundColor = Common().mint
        dateButton.setTitleColor(.white, for: .normal)
        dateLabel.text = dateString
        datePickerView.maximumDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: "2020-01-01") {
            datePickerView.minimumDate = date
        }
        if let date = dateFormatter.date(from: date!) {
            datePickerView.setDate(date, animated: false)
        }
    }
    
    //MARK: 산책 날짜 입력
    @IBAction func dateSelectClick(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        datePopOuterView.isHidden = false
    }
    @IBAction func dateButtonClick(_ sender: UIButton) {
        date = Common().dateFormatter.string(from: datePickerView.date)
        dateLabel.text = Common().dateStringFormatter.string(from: datePickerView.date)
        datePopOuterView.isHidden = true
    }
    @IBAction func dateCancelButtonClick(_ sender: UIButton) {
        self.datePopOuterView.isHidden = true
    }
    
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK:- 등록버튼 눌렀을 때
    @IBAction func updateButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.washUpdate()
    }
    
    func washUpdate() {
        print("update")
//        let URL = Common().baseURL+"/diary/wash"
//        let wash = WashVO()
//        wash.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
//        wash.date = self.date
//        let alamo = AF.request(URL, method: .post, parameters: wash, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
//        alamo.responseDecodable(of: HomeVO.self) { (response) in
//            guard let home = response.value else {
//                self.present(Common().errorAlert(), animated: false, completion: nil)
//                self.indicatorView.isHidden = true
//                self.indicator.stopAnimating()
//                return
//            }
//            HomeVO.shared.lastWashDay = home.lastWashDay
//            self.dismiss(animated: false, completion: nil)
//        }
    }

}
