//
//  JoinViewController.swift
//  dogDiary
//
//  Created by najin on 2020/10/28.
//

import UIKit

class JoinViewController: UIViewController {

    //MARK:- 선언 및 초기화
    //MARK: 프로퍼티 선언
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var nameCheckLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: 버튼 활성화 함수
    func buttonEnableStyle(button: UIButton){
        button.backgroundColor = #colorLiteral(red: 0.05781326443, green: 0.4195952713, blue: 0.6786671877, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = true
        button.layer.cornerRadius = 5
    }
    
    //MARK: 버튼 비활성화 함수
    func buttonDisableStyle(button: UIButton){
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 5
    }
    
    //MARK: 키보드 없애기
    @IBAction func tapView(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        nickTextField.delegate = self
//        print(MemberVO.shared.phone)
        
        buttonDisableStyle(button: nextButton)
    }
    
    //MARK:- 완료버튼 누른 후
    
    @IBAction func nextButtonClick(_ sender: UIButton) {
//        if nickTextField.text!.count > 8 || nickTextField.text!.count < 2 {
//            nickCheckLabel.text = "사용하실 닉네임을 2~8자로 설정해주세요"
//            nickCheck = false
//            buttonDisableStyle(button: nextButton)
//        }else {
//            let nickname = Nick(nick: self.nickTextField.text!)
//            if self.nickTextField.text!.range(of: "^[a-zA-Z가-힣0-9]*$", options: .regularExpression) == nil {
//                nickCheckLabel.text = "한글,영문,숫자만 입력해주세요"
//                self.buttonDisableStyle(button: self.nextButton)
//            } else {
//                //백으로 전송
//            }
//        }
    }
}
