//
//  DailyViewController.swift
//  dogDiary
//
//  Created by najin on 2020/10/30.
//

import UIKit
import Alamofire

class DailyViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var dailyView: UIView!
    @IBOutlet weak var dailyTextLenLabel: UILabel!
    @IBOutlet weak var dailyTextView: UITextView!
    
    let imagePickerController = UIImagePickerController()
    var addImage = false
    var addLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        dailyTextView.delegate = self
        
        //네비게이션 바 설정
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem

        //날짜 label 셋팅
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "yyyy년 M월 d일 (eee)"
        let dateString = dateFormatter.string(from: today)
        todayLabel.text = dateString
        
        //아이콘뷰 클릭 이벤트 셋팅
        let tapIconView = UITapGestureRecognizer(target: self, action: #selector(self.tapIconView(_:)))
        self.iconView.addGestureRecognizer(tapIconView)
        
        //장소뷰 클릭 이벤트 셋팅
        let tapLocationView = UITapGestureRecognizer(target: self, action: #selector(self.tapLocationView(_:)))
        self.locationView.addGestureRecognizer(tapLocationView)
        
        //사진뷰 클릭 이벤트 셋팅
        photoImageView.isUserInteractionEnabled = true
        let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView(_:)))
        self.photoImageView.addGestureRecognizer(tapPhoto)
        
        //텍스트뷰 셋팅
        dailyView.layer.borderWidth = 1
        dailyView.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
    
    //MARK: 아이콘 뷰 클릭
    @objc func tapIconView(_ tap: UITapGestureRecognizer) {
        print("iconnn")
    }
    
    //MARK: 지도 뷰 클릭
    @objc func tapLocationView(_ tap: UITapGestureRecognizer) {
//        let vc = self.storyboard!.instantiateViewController(withIdentifier: "searchMapView") as! SearchMapViewController
//        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK: 이미지 뷰 클릭
    @objc func tapImageView(_ tap: UITapGestureRecognizer) {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: false, completion: nil)
    }
    
    //선택한 이미지 지정
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.photoImageView.image = originalImage
            addImage = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //텍스트뷰 글자수 라벨
    func textViewDidChange(_ textView: UITextView) {
        dailyTextLenLabel.text = "\(dailyTextView.text.count)/100"
    }
    
    //텍스트뷰 글자수 제한하기
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //최대 100문자만 입력가능하도록 설정 (100자가 넘었어도 지우기는 가능해야한다)
        guard let textFieldText = dailyTextView.text, let rangeOfTextToReplce = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplce]
        let count = textFieldText.count - substringToReplace.count + text.count
        
        return count <= 100
    }
    
    @IBAction func insertButtonClick(_ sender: UIButton) {
        //오늘 날짜와 회원 id 셋팅
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: today)
        let mid = UserDefaults.standard.string(forKey: "id")!
        
        //서버에 강아지 정보 전송
        let daily = DailyVO()
        daily.mid = Int(mid)
        daily.content = self.dailyTextView.text
        daily.icon = self.iconLabel.text!
        daily.date = dateString
        
        if self.addLocation {
            daily.mapx = "1"
            daily.mapy = "1"
        }
        
        let URL = Common().baseURL+"/diary/daily"
        let alamo = AF.request(URL, method: .post, parameters: daily, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)

        alamo.responseDecodable(of: DailyVO.self) { (response) in
            guard let daily = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                return
            }
            if self.addImage {
                print("2222222")
                //이미지 서버에 저장
                let headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
                let URL2 = Common().baseURL+"/diary/daily/photo/\(String(describing: daily.id!))"
                let image = self.photoImageView.image
                let imageData = image?.resize(500, 500)!.jpegData(compressionQuality: 1)
                AF.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData!, withName: "photo", fileName: "\(mid)-\(dateString).jpg", mimeType: "image/jpg")

                }, to: URL2, headers: headers).responseJSON { response in
                    switch response.result {
                    case .success(_):
                        print("ssss")
                    case .failure(_):
                        print("fffffff")
                    }
                }
            }
        }
    }
}
