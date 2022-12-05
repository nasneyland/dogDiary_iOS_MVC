//
//  OverPopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2020/11/05.
//

import UIKit

class OverPopUpViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popOuterView: UIView!
    @IBOutlet weak var insertButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 10
        popUpView.layer.borderWidth = 1
        popOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        Common().buttonEnableStyle(button: insertButton)
    }
    
    //MARK: 모달 끄기
    @IBAction func tapView(_ sender: UIGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }

    //MARK:- 확인버튼 눌렀을 때
    @IBAction func insertButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}
