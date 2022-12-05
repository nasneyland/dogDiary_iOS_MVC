//
//  MoneyPopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2020/10/30.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import GoogleMobileAds

class MoneyPopUpViewController: UIViewController, UITextFieldDelegate, GADInterstitialDelegate {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var toyButton: UIButton!
    @IBOutlet weak var hospitalButton: UIButton!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var etcButton: UIButton!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var buttonOuterView: UIView!
    
    var indicator: NVActivityIndicatorView!
    var interstitial: GADInterstitial!
    
    var date: String!
    var dateString: String?
    var viewHeight: CGFloat?
    var checkType = false
    var checkItem = false
    var checkPrice = false
    var type = 0
    
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
        
//        popUpView.layer.cornerRadius = 20
        buttonDisableBorderStyle(button: foodButton)
        buttonDisableBorderStyle(button: toyButton)
        buttonDisableBorderStyle(button: hospitalButton)
        buttonDisableBorderStyle(button: beautyButton)
        buttonDisableBorderStyle(button: etcButton)
        typeLabel.isHidden = true
        itemLabel.isHidden = true
        priceLabel.isHidden = true
        
        if date == Common().dateFormatter.string(from: Date()) {
            dateLabel.text = "오늘"
        } else {
            dateLabel.text = dateString
        }
        
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
    
    //MARK: 취소버튼 눌렀을 때
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.view.endEditing(true)
        self.dismiss(animated: false, completion: nil)
    }

    func disableButton() {
        buttonDisableBorderStyle(button: foodButton)
        buttonDisableBorderStyle(button: toyButton)
        buttonDisableBorderStyle(button: hospitalButton)
        buttonDisableBorderStyle(button: beautyButton)
        buttonDisableBorderStyle(button: etcButton)
        typeLabel.isHidden = true
        checkType = true
    }
    
    @IBAction func foodButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: foodButton)
        type = 1
    }
    @IBAction func toyButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: toyButton)
        type = 2
    }
    @IBAction func hospitalButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: hospitalButton)
        type = 3
    }
    @IBAction func beautyButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: beautyButton)
        type = 4
    }
    @IBAction func etcButtonClick(_ sender: UIButton) {
        disableButton()
        buttonEnableBorderStyle(button: etcButton)
        type = 5
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
    
    //MARK: 등록버튼 눌렀을 때
    @IBAction func insertButtonClick(_ sender: UIButton) {
        self.view.endEditing(true)
        let itemText = itemTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if !checkType{
            typeLabel.isHidden = false
            itemLabel.isHidden = true
            priceLabel.isHidden = true
        } else if itemText.count == 0 {
            typeLabel.isHidden = true
            itemLabel.isHidden = false
            priceLabel.isHidden = true
        } else if !checkPrice {
            typeLabel.isHidden = true
            itemLabel.isHidden = true
            priceLabel.isHidden = false
        } else {
            indicatorView.isHidden = false
            indicator.startAnimating()
            if MemberVO.shared.grade! == 1 {
                if interstitial.isReady {
                    interstitial.present(fromRootViewController: self)
                } else {
                    moneyInsert()
                }
            } else {
                moneyInsert()
            }
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        moneyInsert()
    }
    
    func moneyInsert() {
        let URL = Common().baseURL+"/diary/money"
        let money = MoneyVO()
        money.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
        money.type = type
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
}
