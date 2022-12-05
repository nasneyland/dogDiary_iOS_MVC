//
//  WeightUpdateViewController.swift
//  dogDiary
//
//  Created by najin on 2021/02/19.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class WeightUpdateViewController: UIViewController, UITextFieldDelegate {
    
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
    //몸무게 입력
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var checkWeightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    var indicator: NVActivityIndicatorView!
    
    var viewHeight: CGFloat?
    var selectedWeight: WeightVO!
    var weight: Float = 0.0
    var date: String!
    var dateString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weightTextField.delegate = self

        //indicator 셋팅
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true
                
        viewHeight = view.frame.size.height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        
        //몸무게 셋팅
        checkWeightLabel.isHidden = true
        weight = Float(selectedWeight.kg!)!
        weightTextField.text = "\(weight)"
        weightLabel.text = "\(weight)kg"
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
    
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: 몸무게 날짜 입력
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
    
    //MARK: 몸무게
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkWeightLabel.isHidden = true
        
        let floatWeight = Float(weightTextField.text ?? "") ?? 0
        weight = floor(floatWeight * 10) / 10
        weightLabel.text = "\(weight)kg"
    }
    
    //MARK:- 등록버튼 눌렀을 때
    @IBAction func updateButtonClick(_ sender: UIButton) {
        weightUpdate()
    }
    
    func weightUpdate() {
        if weight > 0.00 {
            let URL = Common().baseURL+"/diary/weight/\(selectedWeight.id!)"
            let weightVO = WeightVO()
            weightVO.date = date!
            weightVO.kg = "\(weight)"

            let alamo = AF.request(URL, method: .put, parameters: weightVO, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
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
        } else {
            checkWeightLabel.isHidden = false
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
