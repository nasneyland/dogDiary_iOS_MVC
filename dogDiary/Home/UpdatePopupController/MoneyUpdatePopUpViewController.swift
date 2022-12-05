//
//  MoneyUpdatePopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2021/02/19.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class MoneyUpdatePopUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var toyButton: UIButton!
    @IBOutlet weak var hospitalButton: UIButton!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var etcButton: UIButton!
    
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var buttonOuterView: UIView!
    
    //날짜 입력
    @IBOutlet weak var datePopOuterView: UIView!
    @IBOutlet weak var datePopUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var dateCancelButton: UIButton!
    
    var indicator: NVActivityIndicatorView!
    
    var selectedMoney: MoneyVO!
    var type: Int!
    var date: String!
    var dateString: String?
    var viewHeight: CGFloat?
    var checkItem = true
    var checkPrice = true
    var moneyItem = ""
    var moneyPrice = 0
    var moneyType = 0
    
    //MARK: 분류 버튼 활성화 함수
    func buttonEnableBorderStyle(button: UIButton){
        button.backgroundColor = .white
        button.setTitleColor(Common().purple, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 2
        button.layer.borderColor = CGColor(red: 94/255, green: 79/255, blue: 162/255, alpha: 1)
    }
    
    //MARK: 분류 버튼 비활성화 함수
    func buttonDisableBorderStyle(button: UIButton){
        button.backgroundColor = .white
        button.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTextField.delegate = self
        priceTextField.delegate = self

        //indicator 셋팅
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true
        
        //수정,삭제 구분하기
        if type == 1 {
            typeLabel.text = "지출내역 복사하기"
            updateButton.setTitle("등록하기", for: .normal)
        } else {
            typeLabel.text = "지출내역 수정하기"
            updateButton.setTitle("수정하기", for: .normal)
        }
        
        //지출 정보 셋팅하기
        moneyType = selectedMoney.type!
        disableButton()
        switch moneyType {
        case 1:
            buttonEnableBorderStyle(button: foodButton)
        case 2:
            buttonEnableBorderStyle(button: toyButton)
        case 3:
            buttonEnableBorderStyle(button: hospitalButton)
        case 4:
            buttonEnableBorderStyle(button: beautyButton)
        case 5:
            buttonEnableBorderStyle(button: etcButton)
        default:
            print("error")
        }
        
        itemLabel.isHidden = true
        priceLabel.isHidden = true
        moneyItem = selectedMoney.item!
        itemTextField.text = moneyItem
        moneyPrice = selectedMoney.price!
        priceTextField.text = "\(moneyPrice)"
        
        viewHeight = view.frame.size.height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //지출 날짜 수정
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
    
    //MARK: 취소버튼 눌렀을 때
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.view.endEditing(true)
        self.dismiss(animated: false, completion: nil)
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

    func disableButton() {
        buttonDisableBorderStyle(button: foodButton)
        buttonDisableBorderStyle(button: toyButton)
        buttonDisableBorderStyle(button: hospitalButton)
        buttonDisableBorderStyle(button: beautyButton)
        buttonDisableBorderStyle(button: etcButton)
    }
    
    @IBAction func foodButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: foodButton)
        moneyType = 1
    }
    @IBAction func toyButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: toyButton)
        moneyType = 2
    }
    @IBAction func hospitalButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: hospitalButton)
        moneyType = 3
    }
    @IBAction func beautyButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: beautyButton)
        moneyType = 4
    }
    @IBAction func etcButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: etcButton)
        moneyType = 5
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == self.itemTextField {
            itemLabel.isHidden = true
        } else {
            priceLabel.isHidden = true
        }
        if self.priceTextField.text!.range(of: "^[0-9]*$", options: .regularExpression) == nil || priceTextField.text == "" {
            checkPrice = false
        } else {
            checkPrice = true
        }
        
        if itemTextField.text == "" {
            checkItem = false
        } else {
            checkItem = true
        }
    }
    
    //MARK: 수정버튼 눌렀을 때
    @IBAction func updateButtonClick(_ sender: UIButton) {
        self.view.endEditing(true)
        let itemText = itemTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if itemText.count == 0 {
            itemLabel.isHidden = false
            priceLabel.isHidden = true
        } else if !checkPrice {
            itemLabel.isHidden = true
            priceLabel.isHidden = false
        } else {
            indicatorView.isHidden = false
            indicator.startAnimating()
            if type == 1 {
                moneyInsert()
            } else {
                moneyUpdate()
            }
            
        }
    }
    
    func moneyInsert() {
        let URL = Common().baseURL+"/diary/money"
        let money = MoneyVO()
        money.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
        money.type = moneyType
        money.item = itemTextField.text
        money.price = Int(priceTextField.text!)
        money.date = self.date
        let alamo = AF.request(URL, method: .post, parameters: money, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.responseDecodable(of: HomeVO.self) { (response) in
            guard let home = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                return
            }
            HomeVO.shared.totalMoney = home.totalMoney
            HomeVO.shared.moneyList = home.moneyList
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func moneyUpdate() {
        let URL = Common().baseURL+"/diary/money/\(selectedMoney.id!)"
        let money = MoneyVO()
        money.date = date!
        money.type = moneyType
        money.item = itemTextField.text!
        money.price = Int(priceTextField.text!)
        let alamo = AF.request(URL, method: .put, parameters: money, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
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

