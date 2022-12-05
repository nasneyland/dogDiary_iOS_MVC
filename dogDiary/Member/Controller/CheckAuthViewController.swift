//
//  CheckAuthViewController.swift
//  dogDiary
//
//  Created by najin on 2020/12/09.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

//회원가입-이용약관동의후 회원가입
class CheckAuthViewController: UIViewController {

    //MARK:- 선언 및 초기화
    //MARK: 프로퍼티 선언
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var checkAuth1View: UIView!
    @IBOutlet weak var checkAuth2View: UIView!
    @IBOutlet weak var checkAuth1Button: UIButton!
    @IBOutlet weak var checkAuth2Button: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var indicatorView: UIView!
    
    var indicator: NVActivityIndicatorView!
    var checkAuth1 = false
    var checkAuth2 = false
    var phoneNumber: String?
    var mail: String?
    
    //MARK: 초기화
    override func viewDidLoad() {
        super.viewDidLoad()

        backView.layer.cornerRadius = 30
        checkAuth1View.layer.cornerRadius = 10
        checkAuth2View.layer.cornerRadius = 20
        Common().buttonDisableStyle(button: joinButton)
        
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true
    }
    
    //MARK: 체크 확인 함수
    func checkAuth() {
        if checkAuth1 && checkAuth2 {
            Common().buttonEnableStyle(button: joinButton)
        } else {
            Common().buttonDisableStyle(button: joinButton)
        }
    }
    
    @IBAction func authCheck1ButtonClick(_ sender: UIButton) {
        checkAuth1 = !checkAuth1
        let uncheckImage = UIImage(systemName: "squareshape")
        let checkImage = UIImage(systemName: "checkmark.square")
            
        if checkAuth1 {
            checkAuth1Button.setImage(checkImage, for: .normal)
            checkAuth1 = true
        } else {
            checkAuth1Button.setImage(uncheckImage, for: .normal)
            checkAuth1 = false
        }
        checkAuth()
    }
    
    @IBAction func authCheck2ButtonClick(_ sender: UIButton) {
        checkAuth2 = !checkAuth2
        let uncheckImage = UIImage(systemName: "squareshape")
        let checkImage = UIImage(systemName: "checkmark.square")
        
        if checkAuth2 {
            checkAuth2Button.setImage(checkImage, for: .normal)
            checkAuth2 = true
        } else {
            checkAuth2Button.setImage(uncheckImage, for: .normal)
            checkAuth2 = false
        }
        checkAuth()
    }
    
    //MARK:- 가입하기 버튼 클릭
    @IBAction func joinButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        let URL = Common().baseURL+"/diary/member"
        let alamo: DataRequest!
        if self.phoneNumber != nil {
            alamo = AF.request(URL, method: .post, parameters: ["phone": self.phoneNumber], encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        } else {
            alamo = AF.request(URL, method: .post, parameters: ["mail": self.mail], encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        }
        alamo.responseDecodable(of: MemberVO.self) { (response) in
            guard let member = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                return
            }
            
            UserDefaults.standard.set(member.id, forKey: "id")
            MemberVO.shared.id = member.id
            MemberVO.shared.phone = member.phone
            MemberVO.shared.mail = member.mail
            MemberVO.shared.grade = member.grade
            MemberVO.shared.dogList = member.dogList
            
            //메인페이지로 이동
            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController")
            self.navigationController?.pushViewController(nextView!, animated: false)
        }
    }
}
