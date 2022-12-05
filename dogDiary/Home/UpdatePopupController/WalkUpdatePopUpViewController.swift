//
//  WalkUpdatePopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2021/02/19.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class WalkUpdatePopUpViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var updateButton: UIButton!
    //날짜 입력
    @IBOutlet weak var datePopOuterView: UIView!
    @IBOutlet weak var datePopUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var dateCancelButton: UIButton!
    //산책시작시간
    @IBOutlet weak var startTimePopOuterView: UIView!
    @IBOutlet weak var startTimePopUpView: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePickerView: UIDatePicker!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var startTimeCancelButton: UIButton!
    //산책시간
    @IBOutlet weak var timePopOuterView: UIView!
    @IBOutlet weak var timePopUpView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePickerView: UIDatePicker!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var timeCancelButton: UIButton!
    //산책거리
    @IBOutlet weak var checkDistanceLabel: UILabel!
    @IBOutlet weak var distanceTextField: UITextField!
    
    var indicator: NVActivityIndicatorView!
    
    var selectedWalk: WalkVO!
    var type: Int!
    var date: String!
    var dateString: String?
    var viewHeight: CGFloat?
    
    var startTime = ""
    var walkTime = 0
    var distance = "0.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceTextField.delegate = self
        scrollView.delegate = self

        //indicator 셋팅
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true
        
        //수정,삭제 구분하기
        if type == 1 {
            typeLabel.text = "산책정보 복사하기"
            updateButton.setTitle("등록하기", for: .normal)
        } else {
            typeLabel.text = "산책정보 수정하기"
            updateButton.setTitle("수정하기", for: .normal)
        }
        
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
        
        //starttime 프로퍼티 셋팅
        startTimePopOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        startTimePopOuterView.isHidden = true
        startTimePopUpView.layer.cornerRadius = 10
        startTimeCancelButton.layer.cornerRadius = 5
        startTimeButton.layer.cornerRadius = 5
        startTimeButton.backgroundColor = Common().mint
        startTimeButton.setTitleColor(.white, for: .normal)
        startTime = selectedWalk.time!
        startTimeLabel.text = startTime
        startTimePickerView.setDate(Common().timeDateFormatter(date: "\(startTime)"), animated: false)
        
        //time 프로퍼티 셋팅
        timePopOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        timePopOuterView.isHidden = true
        timePopUpView.layer.cornerRadius = 10
        timeCancelButton.layer.cornerRadius = 5
        timeButton.layer.cornerRadius = 5
        timeButton.backgroundColor = Common().mint
        timeButton.setTitleColor(.white, for: .normal)
        walkTime = selectedWalk.minutes!
        let hour = walkTime / 60
        let minutes = walkTime % 60
        if hour == 0 {
            timeLabel.text = "\(minutes)분"
        } else {
            if minutes == 0 {
                timeLabel.text = "\(hour)시간"
            } else {
                timeLabel.text = "\(hour)시간 \(minutes)분"
            }
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "h:m"
        timePickerView.setDate(formatter.date(from: "\(hour):\(minutes)")!, animated: false)
        
        //distance 프로퍼티 셋팅
        distance = selectedWalk!.distance!
        distanceTextField.text = distance
        checkDistanceLabel.isHidden = true
        distanceTextField.attributedPlaceholder = NSAttributedString(string: "산책 거리", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        viewHeight = view.frame.size.height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //keyboard 반응형
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.size.height = viewHeight! - keyboardSize.height
        }
        self.view.layoutIfNeeded()
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.size.height = viewHeight!
        self.view.layoutIfNeeded()
    }
    @IBAction func tabView(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
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
    
    //MARK: 산책 시작시간 입력
    @IBAction func startTimeSelectClick(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        startTimePopOuterView.isHidden = false
    }
    @IBAction func startTimeButtonClick(_ sender: UIButton) {
        startTimePopOuterView.isHidden = true
        
        startTime = Common().timeFormatter(date: startTimePickerView.date)
        startTimeLabel.text = "\(startTime)"
        
//        startTimePickerView.setDate(Common().timeDateFormatter(date: timeString), animated: <#T##Bool#>)
    }
    @IBAction func startTimeCancelClick(_ sender: UIButton) {
        startTimePopOuterView.isHidden = true
    }
    
    //MARK: 산책시간 입력
    @IBAction func timeSelectClick(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        timePopOuterView.isHidden = false
    }
    @IBAction func timeButtonClick(_ sender: UIButton) {
        timePopOuterView.isHidden = true
        
        walkTime = (Int(timePickerView.countDownDuration) / 60)
        let hours = (walkTime / 60)
        let minutes = (walkTime % 60)

        if hours == 0 {
            timeLabel.text = "\(minutes)분"
        } else {
            if minutes == 0 {
                timeLabel.text = "\(hours)시간"
            } else {
                timeLabel.text = "\(hours)시간 \(minutes)분"
            }
        }
    }
    @IBAction func timeCancelClick(_ sender: UIButton) {
        timePopOuterView.isHidden = true
    }
    
    //MARK: 산책거리 입력
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkDistanceLabel.isHidden = true
        
        let distanceFloat = Float(textField.text ?? "") ?? 0
        distance = String(format: "%.1f", distanceFloat)
    }

    //MARK: 취소버튼 눌렀을 때
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.view.endEditing(true)
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: 등록버튼 눌렀을 때
    @IBAction func updateButtonClick(_ sender: UIButton) {
        if distanceTextField.text == "" || distance == "0.0" {
            checkDistanceLabel.isHidden = false
        } else {
            indicatorView.isHidden = false
            indicator.startAnimating()
            if type == 1 {
                walkDirectInsert()
            } else {
                walkDirectUpdate()
            }
        }
    }
    
    func walkDirectInsert() {
        //alamofire 산책정보 입력하기
        let URL = Common().baseURL+"/diary/walk"
        let walk = WalkVO()
        walk.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
        walk.date = date
        walk.time = startTime
        walk.minutes = walkTime
        walk.distance = distance
        let alamo = AF.request(URL, method: .post, parameters: walk, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.responseDecodable(of: HomeVO.self) { (response) in
            guard let home = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                return
            }
            HomeVO.shared.walkList = home.walkList
            self.dismiss(animated: false, completion: nil)
        }
    }
    func walkDirectUpdate() {
        //alamofire 산책정보 입력하기
        let URL = Common().baseURL+"/diary/walk/\(selectedWalk.id!)"
        let walk = WalkVO()
        walk.date = date
        walk.time = startTime
        walk.minutes = walkTime
        walk.distance = distance
        let alamo = AF.request(URL, method: .put, parameters: walk, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.response { response in
            switch response.result {
            case .success(_):
                self.loadHomeData()
            case .failure(_):
                self.present(Common().errorAlert(), animated: false, completion: nil)
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
            }
        }
    }
    
    //MARK:- 데이터 셋팅
    func loadHomeData() {
        //alamofire - home data 받아오기, homeVO 셋팅
        let URL2 = Common().baseURL+"/diary/home/"+UserDefaults.standard.string(forKey: "dog_id")!
        let alamo2 = AF.request(URL2, method: .get).validate(statusCode: 200..<300)
        alamo2.responseDecodable(of: HomeVO.self) { (response) in
            guard let home = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                return
            }
            HomeVO.shared.dog = home.dog
            HomeVO.shared.lastWashDay = home.lastWashDay
            HomeVO.shared.lastWeightDay = home.lastWeightDay
            HomeVO.shared.lastWeight = home.lastWeight
            HomeVO.shared.lastHeartDay = home.lastHeartDay
            HomeVO.shared.totalMoney = home.totalMoney
            HomeVO.shared.walkList = home.walkList
            HomeVO.shared.weightChart = home.weightChart
            HomeVO.shared.moneyList = home.moneyList
            
            self.dismiss(animated: false, completion: nil)
        }
    }
}
