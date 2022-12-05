//
//  WalkPopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2020/10/30.
//

import UIKit
import Alamofire

class WalkPopUpViewController: UIViewController, UITextFieldDelegate {

    //MARK:- 프로퍼티 선언 및 초기화
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popOuterView: UIView!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var walkTimeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walkTimeTextField.delegate = self

        popUpView.layer.cornerRadius = 10
        popUpView.layer.borderWidth = 1
        Common().buttonDisableStyle(button: insertButton)
    }
    
    //MARK: 시간 입력값 유효성 검사
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if self.walkTimeTextField.text!.range(of: "^[0-9]*$", options: .regularExpression) == nil || self.walkTimeTextField.text == ""{
        Common().buttonDisableStyle(button: self.insertButton)
        } else {
            Common().buttonEnableStyle(button: self.insertButton)
        }
    }
    
    //MARK: 모달 끄기
    @IBAction func tapView(_ sender: UIGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK:- 등록버튼 눌렀을 때
    @IBAction func insertButtonClick(_ sender: UIButton) {
        let URL = Common().baseURL+"/diary/walk"
        let walk = WalkVO()
        walk.mid = Int(UserDefaults.standard.string(forKey: "id")!)
        walk.minutes = Int(walkTimeTextField.text!)
        let alamo = AF.request(URL, method: .post, parameters: walk, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.response { (response) in
            switch response.result {
            case .success(_):
                self.dismiss(animated: false, completion: nil)
            case .failure(_):
                self.present(Common().errorAlert(), animated: false, completion: nil)
            }
        }
    }
}
