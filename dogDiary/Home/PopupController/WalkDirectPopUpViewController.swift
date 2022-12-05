//
//  WalkDirectPopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2020/12/17.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import GoogleMobileAds

class WalkDirectPopUpViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, GADInterstitialDelegate {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    //산책시작시간
    @IBOutlet weak var startTimePopOuterView: UIView!
    @IBOutlet weak var startTimePopUpView: UIView!
    @IBOutlet weak var checkStartTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePickerView: UIDatePicker!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var startTimeCancelButton: UIButton!
    //산책시간
    @IBOutlet weak var timePopOuterView: UIView!
    @IBOutlet weak var timePopUpView: UIView!
    @IBOutlet weak var checkTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePickerView: UIDatePicker!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var timeCancelButton: UIButton!
    //산책거리
    @IBOutlet weak var checkDistanceLabel: UILabel!
    @IBOutlet weak var distanceTextField: UITextField!
    
    var indicator: NVActivityIndicatorView!
    var interstitial: GADInterstitial!
    
    var date: String!
    var dateString: String?
    var viewHeight: CGFloat?
    
    var checkStartTime = false
    var walkTime = 0
    var distance = "0.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceTextField.delegate = self
        scrollView.delegate = self
        dateLabel.text = dateString
        
        //구글 애드몹 광고
//        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") //test ID
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1025720268361094/2956101136")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)

        //indicator 셋팅
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true
        
        //time 프로퍼티 셋팅
        checkStartTimeLabel.isHidden = true
        startTimePopOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        startTimePopOuterView.isHidden = true
        startTimePopUpView.layer.cornerRadius = 10
        startTimeCancelButton.layer.cornerRadius = 5
        startTimeButton.layer.cornerRadius = 5
        startTimeButton.backgroundColor = Common().mint
        startTimeButton.setTitleColor(.white, for: .normal)
        
        //time 프로퍼티 셋팅
        checkTimeLabel.isHidden = true
        timePopOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        timePopOuterView.isHidden = true
        timePopUpView.layer.cornerRadius = 10
        timeCancelButton.layer.cornerRadius = 5
        timeButton.layer.cornerRadius = 5
        timeButton.backgroundColor = Common().mint
        timeButton.setTitleColor(.white, for: .normal)
        
        //distance 프로퍼티 셋팅
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
    
    //MARK: 시작시간 입력
    @IBAction func startTimeSelectClick(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        startTimePopOuterView.isHidden = false
    }
    
    @IBAction func startTimeButtonClick(_ sender: UIButton) {
        startTimePopOuterView.isHidden = true
        checkStartTimeLabel.isHidden = true
        
        let timeString = Common().timeFormatter(date: startTimePickerView.date)

        checkStartTime = true
        startTimeLabel.text = "\(timeString)"
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
        checkTimeLabel.isHidden = true
        
        walkTime = Int(timePickerView.countDownDuration) / 60
        let hours = walkTime / 60
        let minutes = walkTime % 60
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
    @IBAction func insertButtonClick(_ sender: UIButton) {
        if !checkStartTime {
            checkStartTimeLabel.isHidden = false
        } else if walkTime == 0 {
            checkTimeLabel.isHidden = false
        } else if distanceTextField.text == "" || distance == "0.0" {
            checkDistanceLabel.isHidden = false
        } else {
            indicatorView.isHidden = false
            indicator.startAnimating()
            if MemberVO.shared.grade! == 1 {
                if interstitial.isReady {
                    interstitial.present(fromRootViewController: self)
                } else {
                    walkDirectInsert()
                }
            } else {
                walkDirectInsert()
            }
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        walkDirectInsert()
    }
    
    func walkDirectInsert() {
        //alamofire 산책정보 입력하기
        let URL = Common().baseURL+"/diary/walk"
        let walk = WalkVO()
        walk.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
        walk.date = date!
        walk.time = startTimeLabel.text!
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
}
