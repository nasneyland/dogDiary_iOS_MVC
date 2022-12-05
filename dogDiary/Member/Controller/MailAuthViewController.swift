//
//  MailAuthViewController.swift
//  dogDiary
//
//  Created by najin on 2020/11/08.
//

import UIKit
import Alamofire

class MailAuthViewController: UIViewController, UITextFieldDelegate {

    //MARK:- 선언 및 초기화
    //MARK: 프로퍼티 선언
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var sendMailButton: UIButton!
    @IBOutlet weak var mailCheckLabel: UILabel!
    @IBOutlet weak var authNumberTextField: UITextField!
    @IBOutlet weak var authCheckLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backView: UIView!
    
    let tapLabelGestureRecognizer = UITapGestureRecognizer()
    var mail = ""
    var authNumber = 135792468
    var authCount = 0
    var memberId = 0
    var timer: Timer?
    var timeLeft = 300
    
    //MARK: 타이머 함수
    @objc func onTimerUpdate() {
        timeLeft = timeLeft - 1
        
        if timeLeft == 0 {
            timer?.invalidate()
        }
        
        let minutes = (timeLeft % 3600) / 60
        let seconds = (timeLeft % 3600) % 60
        
        if seconds >= 10 {
            sendMailButton.setTitle("재전송 \(minutes):\(seconds)", for: .normal)
        } else {
            sendMailButton.setTitle("재전송 \(minutes):0\(seconds)", for: .normal)
        }
        
    }
    
    //MARK: 초기화
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailTextField.delegate = self
        authNumberTextField.delegate = self
        
        Common().buttonDisableStyle(button: sendMailButton)
        Common().buttonDisableStyle(button: nextButton)
        backView.layer.cornerRadius = 30
        nextButton.isHidden = true
        authNumberTextField.isHidden = true
        authCheckLabel.isHidden = true
        mailCheckLabel.isHidden = true
    }
    
    //MARK: 키보드 없애기
    @IBAction func tabView(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: 메일 인증 유효성검사
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //메일 유효성 검사
        if mailTextField.text!.contains("@") && mailTextField.text!.contains(".") {
            Common().buttonEnableStyle(button: sendMailButton)
        } else {
            Common().buttonDisableStyle(button: sendMailButton)
        }
        
        //인증번호 유효성 검사
        if authNumberTextField.text?.count == 0 {
            Common().buttonDisableStyle(button: nextButton)
        } else {
            Common().buttonEnableStyle(button: nextButton)
        }
    }
    
    //MARK:- 전송버튼 누른 후
    @IBAction func sendSMSButtonClick(_ sender: UIButton) {
        self.mailCheckLabel.isHidden = true
        self.sendMailButton.setTitle("전송중", for: .normal)
        self.sendMailButton.isEnabled = false
        let URL = Common().baseURL+"/diary/member/mail-auth"
        mail = self.mailTextField.text!
        let alamo = AF.request(URL, method: .post, parameters: ["mail": mail], encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        
        alamo.responseDecodable(of: Auth.self) { (response) in
            guard let auth = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                return
            }
            
            //프로퍼티 상태 변경
            self.sendMailButton.setTitle("재전송 5:00", for: .normal)
            self.sendMailButton.isEnabled = true
            self.mail = self.mailTextField.text!
            self.authNumberTextField.isHidden = false
            self.nextButton.isHidden = false
            self.authNumberTextField.text = ""
            self.mailCheckLabel.isHidden = true

            //타이머 시작
            self.timeLeft = 300
            self.timer?.invalidate()
            self.timer = nil
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.onTimerUpdate), userInfo: nil, repeats: true)

            self.authNumber = auth.authNumber
            self.memberId = auth.id
        }
    }
    
    //MARK:- 확인 버튼 눌렀을 때
    @IBAction func nextButtonClick(_ sender: UIButton) {
        if authNumberTextField.text == String(authNumber) {
            //인증번호 맞았을 때
            if timeLeft == 0 {
                authCheckLabel.isHidden = false
                authCheckLabel.text = "인증번호 입력시간이 초과되었습니다."
            } else {
                if memberId == 0 {
                    //회원이 아니므로 회원가입 페이지로 이동
                    let nextView = self.storyboard?.instantiateViewController(withIdentifier: "checkAuthViewController") as! CheckAuthViewController
                    nextView.mail = mail
                    self.navigationController?.pushViewController(nextView, animated: false)
                } else {
                    //회원인 경우 로그인처리
                    UserDefaults.standard.set(memberId, forKey: "id")
                    loadHomeData()
                }
            }
        } else {
            //인증번호 틀렸을 때
            authCheckLabel.isHidden = false
            if authCount >= 5 {
                authNumber = 135792468
                authCheckLabel.text = "인증번호 입력횟수가 초과되었습니다."
                Common().buttonDisableStyle(button: nextButton)
                Common().buttonDisableStyle(button: sendMailButton)
                timer?.invalidate()
                sendMailButton.setTitle("입력횟수 초과", for: .normal)
            } else {
                authCount += 1
                authCheckLabel.text = "인증번호가 틀렸습니다(\(authCount)/5)"
            }
        }
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK:- 데이터 셋팅
    func loadHomeData() {
        //alamofire - member data 받아오기, memberVO 셋팅
        let URL1 = Common().baseURL+"/diary/member/"+UserDefaults.standard.string(forKey: "id")!
        let alamo1 = AF.request(URL1, method: .get).validate(statusCode: 200..<300)
        alamo1.responseDecodable(of: MemberVO.self) { (response) in
            guard let member = response.value else {
                let alert = UIAlertController(title: "서버 접속 실패", message: "인터넷 연결 상태를 확인해주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default)
                alert.addAction(action)
                self.present(alert, animated: false, completion: nil)
                return
            }
            //회원정보 셋팅
            MemberVO.shared.id = member.id
            MemberVO.shared.phone = member.phone
            MemberVO.shared.mail = member.mail
            MemberVO.shared.grade = member.grade
            MemberVO.shared.dogList = member.dogList
        
            if member.dogList?.count != 0 {
                //등록된 강아지가 있을 때
                //alamofire - home data 받아오기, homeVO 셋팅
                if UserDefaults.standard.string(forKey: "dog_id") == nil {
                    UserDefaults.standard.setValue(member.dogList![0].id, forKey: "dog_id")
                }
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
                    
                    //메인페이지로 이동
                    let nextView = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController")
                    self.navigationController?.pushViewController(nextView!, animated: false)
                }
            } else {
                //등록된 강아지가 없을 때
                //메인페이지로 이동
                let nextView = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController")
                self.navigationController?.pushViewController(nextView!, animated: false)
            }
        }
    }
}
