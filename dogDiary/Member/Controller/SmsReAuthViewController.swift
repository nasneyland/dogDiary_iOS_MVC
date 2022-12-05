import UIKit
import Alamofire

//로그인,회원가입-회원 핸드폰번호 인증 컨트롤러
class SmsReAuthViewController: UIViewController, UITextFieldDelegate {
    
    //MARK:- 선언 및 초기화
    //MARK: 프로퍼티 선언
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var sendSMSButton: UIButton!
    @IBOutlet weak var authNumberTextField: UITextField!
    @IBOutlet weak var phoneCheckLabel: UILabel!
    @IBOutlet weak var authCheckLabel: UILabel!
    @IBOutlet weak var authCountLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var sendSMSmessageLabel: UILabel!
    
    let tapLabelGestureRecognizer = UITapGestureRecognizer()
    var phoneNumber = ""
    var authNumber = 135792468
    var authCount = 0
    var timer: Timer?
    var timeLeft = 300
    var memberId: Int!
    
    //MARK: 타이머 함수
    @objc func onTimerUpdate() {
        timeLeft = timeLeft - 1
        
        if timeLeft == 0 {
            timer?.invalidate()
        }
        if timeLeft == 297 {
            //팝업 없애기
            UIView.animate(withDuration: 0.5) {
                self.popUpView.transform = CGAffineTransform(translationX: 0, y: -200)
            }
        }
        if timeLeft == 285 {
            self.sendSMSButton.isEnabled = true
        }
        
        let minutes = (timeLeft % 3600) / 60
        let seconds = (timeLeft % 3600) % 60
        
        if seconds >= 10 {
            sendSMSButton.setTitle("재전송 \(minutes):\(seconds)", for: .normal)
        } else {
            sendSMSButton.setTitle("재전송 \(minutes):0\(seconds)", for: .normal)
        }
        
    }
    
    //MARK: 초기화
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.delegate = self
        authNumberTextField.delegate = self
        
        Common().buttonDisableStyle(button: sendSMSButton)
        Common().buttonDisableStyle(button: nextButton)
        backView.layer.cornerRadius = 30
        nextButton.isHidden = true
        authNumberTextField.isHidden = true
        authCheckLabel.isHidden = true
        self.phoneCheckLabel.isHidden = true
        
        popUpView.backgroundColor = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        popUpView.transform = CGAffineTransform(translationX: 0, y: -200)
        popUpView.layer.cornerRadius = 10
    }
    
    //MARK: 키보드 없애기
    @IBAction func tabView(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: 휴대폰번호 길이 유효성검사
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if authCount < 5 {
            if phoneTextField.text?.count ?? 0 > 10 {
                Common().buttonEnableStyle(button: sendSMSButton)
            } else {
                Common().buttonDisableStyle(button: sendSMSButton)
            }
            
            //인증번호 유효성 검사
            if authNumberTextField.text?.count == 0 {
                Common().buttonDisableStyle(button: nextButton)
            } else {
                Common().buttonEnableStyle(button: nextButton)
            }
        }
    }
    
    //MARK: 휴대폰번호 글자 수 유효성검사
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //최대 11문자만 입력가능하도록 설정
        guard let textFieldText = textField.text, let rangeOfTextToReplce = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplce]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        //숫자만 입력가능하도록 설정
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        return count <= 11 && allowedCharacters.isSuperset(of: characterSet)
        
    }
    
    //MARK:- 전송버튼 누른 후
    @IBAction func sendSMSButtonClick(_ sender: UIButton) {
        
        //오늘날짜 구하기
        let dateString = Common().dateFormatter.string(from: Date())
        
        //문자 인증횟수 5회로 제한하기
        if UserDefaults.standard.string(forKey: "authDate") == dateString {
            if UserDefaults.standard.integer(forKey: "authCount") >= 5 {
                Common().buttonDisableStyle(button: self.sendSMSButton)
                self.sendSMSButton.setTitle("하루 인증 가능횟수 초과", for: .normal)
                return
            } else {
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "authCount")+1, forKey: "authCount")
                self.sendSMSmessageLabel.text = "인증번호가 발송되었습니다. 최대 20초 소요"
                self.authCountLabel.text = "(남은 인증횟수 : \(5-UserDefaults.standard.integer(forKey: "authCount"))회)"
            }
        } else {
            UserDefaults.standard.set(dateString, forKey: "authDate")
            UserDefaults.standard.set(0, forKey: "authCount")
            self.sendSMSmessageLabel.text = "인증번호가 발송되었습니다. 최대 20초 소요"
            self.authCountLabel.text = "(남은 인증횟수 : 5회)"
        }
        
        let URL = Common().baseURL+"/diary/member/sms-re-auth"
        phoneNumber = self.phoneTextField.text!
        let alamo = AF.request(URL, method: .post, parameters: ["phone": phoneNumber], encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        
        alamo.responseDecodable(of: Auth.self) { (response) in
            guard let auth = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                return
            }
            if auth.id == 1 {
                self.phoneCheckLabel.isHidden = false
            } else {
                self.phoneCheckLabel.isHidden = true
 
                //팝업 띄우기
                UIView.animate(withDuration: 0.5) {
                    self.popUpView.transform = CGAffineTransform(translationX: 0, y: 0)
                }
                
                self.sendSMSButton.isEnabled = false
                
                //프로퍼티 상태 변경
                self.sendSMSButton.setTitle("재전송 5:00", for: .normal)
                self.authNumberTextField.isHidden = false
                self.nextButton.isHidden = false
                self.authNumberTextField.text = ""
                self.authCheckLabel.isHidden = true
                
                //타이머 시작
                self.timeLeft = 300
                self.timer?.invalidate()
                self.timer = nil
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.onTimerUpdate), userInfo: nil, repeats: true)
                
                self.authNumber = auth.authNumber
            }
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
                //해당 회원의 핸드폰번호 변경
                let URL = Common().baseURL+"/diary/member/\(String(memberId))"
                let alamo = AF.request(URL, method: .put, parameters: ["type": "phone", "phone": phoneNumber], encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
                
                alamo.response { response in
                    switch response.result {
                    case .success(_):
                        //id정보를 등록하고 메인페이지로 이동
                        UserDefaults.standard.set(self.memberId, forKey: "id")
                        self.loadHomeData()
                    case .failure(_):
                        self.present(Common().errorAlert(), animated: false, completion: nil)
                    }
                }
            }
        }else {
            //인증번호 틀렸을 때
            authCheckLabel.isHidden = false
            if authCount >= 5 {
                authNumber = 135792468
                authCheckLabel.text = "인증번호 입력횟수가 초과되었습니다."
                Common().buttonDisableStyle(button: nextButton)
                Common().buttonDisableStyle(button: sendSMSButton)
                timer?.invalidate()
                sendSMSButton.setTitle("입력횟수 초과", for: .normal)
            } else {
                authCount += 1
                authCheckLabel.text = "인증번호가 틀렸습니다(\(authCount)/5)"
            }
        }
    }
    
    //MARK:- 데이터 셋팅
    func loadHomeData() {
        //alamofire - member data 받아오기, memberVO 셋팅
        let URL1 = Common().baseURL+"/diary/member/"+UserDefaults.standard.string(forKey: "id")!
        let alamo1 = AF.request(URL1, method: .get).validate(statusCode: 200..<300)
        alamo1.responseDecodable(of: MemberVO.self) { (response) in
            guard let member = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                return
            }
            //회원정보 셋팅
            MemberVO.shared.id = Int(UserDefaults.standard.string(forKey: "id")!)
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
                //메인페이지로 이동
                let nextView = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController")
                self.navigationController?.pushViewController(nextView!, animated: false)
            }
        }
    }
    
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
}
