//
//  WeightPopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2020/10/30.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import GoogleMobileAds

class WeightPopUpViewController: UIViewController, UITextFieldDelegate, GADInterstitialDelegate {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightInfoLabel: UILabel!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    //calculator view
    @IBOutlet weak var calculatorView: UIView!
    @IBOutlet weak var totalWeightTextField: UITextField!
    @IBOutlet weak var removeWeightTextField: UITextField!
    //direct view
    @IBOutlet weak var directView: UIView!
    @IBOutlet weak var weightTextField: UITextField!
    
    var indicator: NVActivityIndicatorView!
    var interstitial: GADInterstitial!
    
    var viewHeight: CGFloat?
    var weight: Float = 0.0
    var date: String!
    var dateString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeWeightTextField.delegate = self
        totalWeightTextField.delegate = self
        weightTextField.delegate = self
        
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

        //날짜 셋팅
        if date == Common().dateFormatter.string(from: Date()) {
            dateLabel.text = "오늘"
        } else {
            dateLabel.text = dateString
        }
        
//        popUpView.layer.cornerRadius = 20
        calculatorView.isHidden = false
        directView.isHidden = true
        weightInfoLabel.text = ""
                
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

    //MARK: 키보드 없애기
    @IBAction func tabView(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK:- 몸무게입력 모드 변경
    @IBAction func segmentedValueChanged(_ sender:UISegmentedControl!) {
        weightTextField.text = ""
        totalWeightTextField.text = ""
        removeWeightTextField.text = ""
        weightInfoLabel.text = ""
        weightLabel.text = "0.0kg"
        if sender.selectedSegmentIndex == 0 {
            //calculator 모드
            calculatorView.isHidden = false
            directView.isHidden = true
        } else {
            //direct 모드
            calculatorView.isHidden = true
            directView.isHidden = false
        }
    }
    
    //MARK: 몸무게
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let floatTotalWeight = Float(totalWeightTextField.text ?? "") ?? 0
        let floatRemoveWeight = Float(removeWeightTextField.text ?? "") ?? 0
        let floatWeight = Float(weightTextField.text ?? "") ?? 0
        let floatPreWeight = Float(HomeVO.shared.lastWeight ?? "") ?? 0

        let totalWeight = floor(floatTotalWeight * 10) / 10 //전체 몸무게
        let removeWeight = floor(floatRemoveWeight * 10) / 10 //뺄 몸무게
        let dogWeight = floor(floatWeight * 10) / 10 //직접입력 몸무게
        let preWeight = floor(floatPreWeight * 10) / 10 //이전 몸무게
        
        //몸무게 라벨
        if modeSegmentedControl.selectedSegmentIndex == 0 {
            weight = totalWeight - removeWeight
            weightLabel.text = String(format: "%.1f", weight as CVarArg) + "kg"
        } else {
            weight = dogWeight
            weightLabel.text = String(format: "%.1f",  weight as CVarArg) + "kg"
        }

        //몸무게 변화 라벨
        if HomeVO.shared.lastWeight != nil && self.dateLabel.text == "오늘" {
            self.weightInfoLabel.textColor = Common().darkMint
            let weightFloat = Float(String(format: "%.1f", weight as CVarArg))!
            let diffWeight = round((preWeight - weightFloat) * 100) / 100
            let diff = floor(diffWeight * 10) / 10
            if weightFloat <= 0.0 {
                self.weightInfoLabel.text = "몸무게를 정확히 입력해주세요."
            } else if diff > 0.0 {
                self.weightInfoLabel.text = "\(HomeVO.shared.lastWeightDay!)일 전보다 \(diff.magnitude)키로 감소했습니다."
            } else if diff < 0.0 {
                self.weightInfoLabel.text = "\(HomeVO.shared.lastWeightDay!)일 전보다 \(diff.magnitude)키로 증가했습니다."
            } else {
                self.weightInfoLabel.text = "\(HomeVO.shared.lastWeightDay!)일 전과 몸무게가 동일합니다."
            }
        } else {
            if weight <= 0.0 {
                self.weightInfoLabel.text = "몸무게를 정확히 입력해주세요."
            } else {
                self.weightInfoLabel.text = ""
            }
        }
    }

    @IBAction func cancelButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK:- 등록버튼 눌렀을 때
    @IBAction func insertButtonClick(_ sender: UIButton) {
        if weight > 0.00 {
            indicatorView.isHidden = false
            indicator.startAnimating()
            if MemberVO.shared.grade! == 1 {
                if interstitial.isReady {
                    interstitial.present(fromRootViewController: self)
                } else {
                    weightInsert()
                }
            } else {
                weightInsert()
            }
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        weightInsert()
    }
    
    func weightInsert() {
        let URL = Common().baseURL+"/diary/weight"
        let weightVO = WeightVO()
        weightVO.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
        weightVO.date = self.date
        weightVO.kg = String(format: "%.1f", weight as CVarArg)
        
        let alamo = AF.request(URL, method: .post, parameters: weightVO, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.responseDecodable(of: HomeVO.self) { (response) in
            guard let home = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                return
            }
            HomeVO.shared.lastWeight = home.lastWeight
            HomeVO.shared.lastWeightDay = home.lastWeightDay
            HomeVO.shared.weightChart = home.weightChart
            self.dismiss(animated: false, completion: nil)
        }
    }
}
