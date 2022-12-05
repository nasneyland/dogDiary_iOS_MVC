//
//  UpdateDogViewController.swift
//  dogDiary
//
//  Created by najin on 2020/12/12.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class UpdateDogViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- 선언 및 초기화
    //MARK: 프로퍼티 선언
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var nameCheckLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageOuterView: UIView!
    
    @IBOutlet weak var birthPopOuterView: UIView!
    @IBOutlet weak var birthPopUpView: UIView!
    @IBOutlet weak var birthButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var indicatorView: UIView!
    
    var beforeId: Int?
    var beforeImage: String?
    var beforeName: String?
    var beforeGender: Int?
    var beforeBirth: String?
    
    var indicator: NVActivityIndicatorView!
    var viewHeight: CGFloat?
    let imagePickerController = UIImagePickerController()
    var updateProfile = false
    var profileMode: Bool!
    var gender: Int?
    var birth: String?
    
    //MARK: 성별 버튼 활성화 함수
    func buttonEnableBorderStyle(button: UIButton){
        button.backgroundColor = .white
        button.setTitleColor(Common().blue, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 2
        button.layer.borderColor = CGColor(red: 69/255, green: 117/255, blue: 180/255, alpha: 1)
    }
    
    //MARK: 성별 버튼 비활성화 함수
    func buttonDisableBorderStyle(button: UIButton){
        button.backgroundColor = .white
        button.setTitleColor(#colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        imagePickerController.delegate = self
        
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true
        
        //전달받은 기존 정보 셋팅
        nameTextField.text = beforeName
        birthLabel.text = beforeBirth
        birth = beforeBirth
        if beforeGender == 1 {
            buttonEnableBorderStyle(button: maleButton)
            buttonDisableBorderStyle(button: femaleButton)
            gender = 1
        } else {
            buttonEnableBorderStyle(button: femaleButton)
            buttonDisableBorderStyle(button: maleButton)
            gender = 2
        }
        //강아지 프로필 셋팅
        if beforeImage != "" {
            guard let url = URL(string: "\(Common().baseURL)/media/\(beforeImage ?? "")") else {
                return
            }
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    profileImageView.image = image
                }
            }
        }
        
        //join 프로퍼티 셋팅
        backView.layer.cornerRadius = 30
        nameCheckLabel.isHidden = true
        Common().buttonEnableStyle(button: nextButton)

        //birth 프로퍼티 셋팅
        birthPopOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        birthPopUpView.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 5
        birthButton.layer.cornerRadius = 5
        birthButton.backgroundColor = Common().mint
        birthButton.setTitleColor(.white, for: .normal)
        birthPopOuterView.isHidden = true
        birthDatePicker.maximumDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: birth!) {
            birthDatePicker.setDate(date, animated: false)
        }
        
        //강아지 프로필 셋팅
        imageOuterView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        imageOuterView.layer.cornerRadius = 15
        imageOuterView.layer.shadowColor = UIColor.gray.cgColor
        imageOuterView.layer.shadowOpacity = 1.0
        imageOuterView.layer.shadowOffset = CGSize.zero
        imageOuterView.layer.shadowRadius = 6
        imageOuterView.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
        cameraImageView.layer.cornerRadius = cameraImageView.frame.height / 2
        
        //프로필 이미지 셋팅
        profileImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView(_:)))
        self.profileImageView.addGestureRecognizer(tap)
        
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
    
    //MARK:- 프로필 사진 선택
    //MARK: 이미지 선택
    @objc func tapImageView(_ tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
        let alert =  UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let library =  UIAlertAction(title: "앨범에서 사진 선택", style: .default) { (action) in
            self.openLibrary()
        }
        let basicProfile =  UIAlertAction(title: "기본이미지 선택", style: .default) { (action) in
            self.selectBasicProfile()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library)
        alert.addAction(basicProfile)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: 앨범에서 사진 선택
    func openLibrary(){
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: false, completion: nil)
    }
    
    //MARK: 기본이미지로 선택
    func selectBasicProfile(){
        profileImageView.image = UIImage(named: "dog_profile")
        updateProfile = true
        profileMode = false
    }
    
    //선택한 이미지 지정
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImageView.image = originalImage
            profileImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            updateProfile = true
            profileMode = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: 이름 입력
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if nameTextField.text!.count > 8 {
            nameCheckLabel.isHidden = false
            nameCheckLabel.text = "이름을 1~8자로 설정해주세요"
            Common().buttonDisableStyle(button: nextButton)
        } else if nameTextField.text!.count < 1 {
            Common().buttonDisableStyle(button: nextButton)
        } else {
            nameCheckLabel.isHidden = true
            Common().buttonEnableStyle(button: nextButton)
        }
    }
    
    //MARK: 성별 입력
    @IBAction func femaleButtonClick(_ sender: UIButton) {
        self.view.endEditing(true)
        buttonEnableBorderStyle(button: femaleButton)
        buttonDisableBorderStyle(button: maleButton)
        gender = 2
    }
    
    @IBAction func maleButtonClick(_ sender: UIButton) {
        self.view.endEditing(true)
        buttonEnableBorderStyle(button: maleButton)
        buttonDisableBorderStyle(button: femaleButton)
        gender = 1
    }
    
    //MARK: 생일 입력
    @IBAction func birthSelectClick(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        birthPopOuterView.isHidden = false
    }
    
    @IBAction func birthButtonClick(_ sender: UIButton) {
        let dateString = Common().dateFormatter.string(from: birthDatePicker.date)
        birth = dateString
        birthLabel.text = dateString
        birthPopOuterView.isHidden = true
    }
    
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        self.birthPopOuterView.isHidden = true
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK:- 완료버튼 누른 후
    @IBAction func nextButtonClick(_ sender: UIButton) {
        //이름 유효성검사
        if self.nameTextField.text!.range(of: "^[a-zA-Z가-힣0-9]*$", options: .regularExpression) == nil {
            nameCheckLabel.text = "한글,영문,숫자만 입력해주세요"
            nameCheckLabel.isHidden = false
            Common().buttonDisableStyle(button: self.nextButton)
        } else {
            indicatorView.isHidden = false
            indicator.startAnimating()

            //서버에 강아지 정보 전송
            let dog = DogVO()
            dog.name = self.nameTextField.text!
            dog.gender = gender
            dog.birth = birth

            let URL1 = Common().baseURL+"/diary/dog/\(String(beforeId!))"
            let alamo1 = AF.request(URL1, method: .put, parameters: dog, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)

            alamo1.response { response in
                switch response.result {
                case .success(_):
                    if !self.updateProfile {
                        //프로필을 수정하지 않았으면
                        self.loadHomeData()
                    } else if self.beforeImage == "" && self.profileMode {
                        //프로필 추가
                        let headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
                        let URL2 = Common().baseURL+"/diary/dog/profile/\(String(self.beforeId!))"
                        let image = self.profileImageView.image
                        let imageData = image?.resize(500, 500)!.jpegData(compressionQuality: 1)
                        AF.upload(multipartFormData: { multipartFormData in
                            multipartFormData.append(imageData!, withName: "profile", fileName: "\(String(self.beforeId!)).jpg", mimeType: "image/jpg")

                        }, to: URL2, method: .post, headers: headers).responseJSON { response in
                            switch response.result {
                            case .success(_):
                                self.loadHomeData()
                            case .failure(_):
                                self.present(Common().errorAlert(), animated: false, completion: nil)
                            }
                        }
                    } else if self.beforeImage != "" && self.profileMode {
                        //프로필 수정
                        let URL1 = Common().baseURL+"/diary/dog/profile/delete/\(String(self.beforeId!))"
                        let alamo1 = AF.request(URL1, method: .delete).validate(statusCode: 200..<300)
                        alamo1.response { (response) in
                            switch response.result {
                            case .success(_):
                                let headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
                                let URL2 = Common().baseURL+"/diary/dog/profile/\(String(self.beforeId!))"
                                let image = self.profileImageView.image
                                let imageData = image?.resize(500, 500)!.jpegData(compressionQuality: 1)
                                AF.upload(multipartFormData: { multipartFormData in
                                    multipartFormData.append(imageData!, withName: "profile", fileName: "\(String(self.beforeId!)).jpg", mimeType: "image/jpg")

                                }, to: URL2, method: .post, headers: headers).responseJSON { response in
                                    switch response.result {
                                    case .success(_):
                                        self.loadHomeData()
                                    case .failure(_):
                                        self.present(Common().errorAlert(), animated: false, completion: nil)
                                    }
                                }
                            case .failure(_):
                                self.present(Common().errorAlert(), animated: false, completion: nil)
                            }
                        }
                    } else if self.beforeImage != "" && !self.profileMode {
                        //프로필 삭제
                        let URL1 = Common().baseURL+"/diary/dog/profile/delete/\(String(self.beforeId!))"
                        let alamo1 = AF.request(URL1, method: .delete).validate(statusCode: 200..<300)
                        alamo1.response { (response) in
                            switch response.result {
                            case .success(_):
                                self.loadHomeData()
                            case .failure(_):
                                self.present(Common().errorAlert(), animated: false, completion: nil)
                            }
                        }
                    } else {
                        self.loadHomeData()
                    }
                case .failure(_):
                    self.present(Common().errorAlert(), animated: false, completion: nil)
                    self.indicatorView.isHidden = true
                    self.indicator.stopAnimating()
                }
            }
        }
    }
    
    func loadHomeData() {
        indicatorView.isHidden = false
        indicator.startAnimating()
        //alamofire - member data 받아오기, memberVO 셋팅
        let URL1 = Common().baseURL+"/diary/member/"+UserDefaults.standard.string(forKey: "id")!
        let alamo1 = AF.request(URL1, method: .get).validate(statusCode: 200..<300)
        alamo1.responseDecodable(of: MemberVO.self) { (response) in
            guard let member = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                return
            }
            MemberVO.shared.dogList = member.dogList
            
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
            
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                
                //메인페이지로 이동
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
