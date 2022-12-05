//
//  SettingTableViewController.swift
//  dogDiary
//
//  Created by najin on 2020/12/09.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import MessageUI

class SettingTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, MFMailComposeViewControllerDelegate {

    //멍멍이정보
    @IBOutlet weak var myDogCollectionView: UICollectionView!
//    @IBOutlet weak var pushSwitch: UISwitch!
    //개발정보
    @IBOutlet weak var versionLabel: UILabel!
    //계정관리
    @IBOutlet weak var gradeStatusLabel: UILabel!
    @IBOutlet weak var memberGradeLabel: UILabel!
    @IBOutlet weak var mailStatusLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    
    static let NotificationDone = NSNotification.Name(rawValue: "Done")
    var indicator: NVActivityIndicatorView!
    let indicatorView = UIView()
    var deviceVersion = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myDogCollectionView.delegate = self
        myDogCollectionView.dataSource = self
    
        myDogCollectionView.register(UINib(nibName: "MyDogCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myDogCell")
        
        //인디케이터 셋팅
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 50, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)

        indicatorView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.addSubview(indicatorView)
        
        //버전 정보 셋팅
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String else { return }
    
        versionLabel.text = "v \(version).\(build)"
        deviceVersion = "\(version).\(build)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        myDogCollectionView.reloadData()

        indicatorView.isHidden = true
        mailLabel.text = MemberVO.shared.mail
        if MemberVO.shared.mail == "" {
            mailStatusLabel.text = "이메일 등록"
        } else {
            mailStatusLabel.text = "이메일 변경"
        }
        if MemberVO.shared.grade == 1 {
//            gradeStatusLabel.text = "광고 제거하기"
            memberGradeLabel.text = "일반회원"
        } else {
//            gradeStatusLabel.text = "회원등급"
            memberGradeLabel.text = "VIP회원"
        }
    }
    
    //MARK:- mail 전송
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result) {
            case .cancelled:
                self.dismiss(animated: true, completion: nil)
            case .sent:
                self.dismiss(animated: true, completion: nil)
            case .failed:
                self.dismiss(animated: true, completion: {
                    let sendMailErrorAlert = UIAlertController.init(title: "메일전송 실패",
                                                                    message: "메일을 전송할 수 없습니다.\n아이폰 설정의 메일 계정을 확인해주세요.", preferredStyle: .alert)
                    sendMailErrorAlert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                    self.present(sendMailErrorAlert, animated: true, completion: nil)
                })
            default:
                break;
            }
    }
    
    //MARK:- push 알림 설정
    @IBAction func pushValueChange(_ sender: UISwitch) {
//        let current = UNUserNotificationCenter.current()
//
//        current.getNotificationSettings(completionHandler: { (settings) in
//            if settings.authorizationStatus == .authorized {
//                print("허용")
//            } else {
//                print("1")
//            }
//        })
    }
    
    //MARK:- 내 멍멍이 콜렉션 뷰 셋팅
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (MemberVO.shared.dogList?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myDogCollectionView.dequeueReusableCell(withReuseIdentifier: "myDogCell", for: indexPath) as! MyDogCollectionViewCell
        
        //collection view cell 셋팅
        cell.myDogImageOuterView.layer.cornerRadius = cell.myDogImageOuterView.frame.height / 2
        cell.myDogImageOuterView.layer.shadowColor = UIColor.gray.cgColor
        cell.myDogImageOuterView.layer.shadowOpacity = 1.0
        cell.myDogImageOuterView.layer.shadowOffset = CGSize.zero
        cell.myDogImageOuterView.layer.shadowRadius = 3
        cell.myDogImageOuterView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.myDogImageView.layer.cornerRadius = cell.myDogImageView.frame.height / 2
        cell.myDogImageView.layer.masksToBounds = true
        
        if indexPath.row >= MemberVO.shared.dogList?.count ?? 0 {
            cell.myDogName.isHidden = true
            cell.myDogImageView.isHidden = true
            cell.selectedImageView.isHidden = true
        } else {
            cell.myDogName.text = MemberVO.shared.dogList![indexPath.row].name
            cell.myDogImageView.isHidden = false
            cell.myDogName.isHidden = false
            
            if String(MemberVO.shared.dogList![indexPath.row].id!) == UserDefaults.standard.string(forKey: "dog_id") {
                cell.selectedImageView.isHidden = false
            } else {
                cell.selectedImageView.isHidden = true
            }
            
            //강아지 프로필 셋팅
            if MemberVO.shared.dogList![indexPath.row].image! != "" {
                guard let url = URL(string: "\(Common().baseURL)/media/\(MemberVO.shared.dogList![indexPath.row].image!)") else {
                    return cell
                }
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        cell.myDogImageView.image = image
                    }
                }
            } else {
                if let image = UIImage(named: "app_dog") {
                    cell.myDogImageView.image = image
                }
            }
        }
        return cell
    }
    
    //MARK:- 내 멍멍이 콜렉션 뷰 cell을 클릭했을 때
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= MemberVO.shared.dogList?.count ?? 0 {
            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "joinViewController")
            self.navigationController?.pushViewController(nextView!, animated: false)
        } else if MemberVO.shared.dogList![indexPath.row].id! != Int(UserDefaults.standard.string(forKey: "dog_id")!){
            UserDefaults.standard.set(MemberVO.shared.dogList![indexPath.row].id, forKey: "dog_id")
            self.loadHomeData(toHome: false)
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let editAction = UIAlertAction(title: "정보 수정하기", style: .default) {
                (action) in
                let nextView = self.storyboard?.instantiateViewController(withIdentifier: "updateDogViewController") as! UpdateDogViewController
                nextView.beforeId = MemberVO.shared.dogList![indexPath.row].id
                nextView.beforeName = MemberVO.shared.dogList![indexPath.row].name
                nextView.beforeGender = MemberVO.shared.dogList![indexPath.row].gender
                nextView.beforeBirth = MemberVO.shared.dogList![indexPath.row].birth
                nextView.beforeImage = MemberVO.shared.dogList![indexPath.row].image
                self.navigationController?.pushViewController(nextView, animated: false)
            }
            let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) {
                (action) in
                let alert = UIAlertController(title: "\(MemberVO.shared.dogList![indexPath.row].name!) 삭제", message: "등록하신 정보가 모두 사라집니다.\n 정말 삭제하시겠습니까?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let okAction = UIAlertAction(title: "삭제", style: .destructive) {
                    (action) in
                    let URL = Common().baseURL+"/diary/dog/\(MemberVO.shared.dogList![indexPath.row].id!)"
                    let alamo = AF.request(URL, method: .delete).validate(statusCode: 200..<300)
                    alamo.response { (response) in
                        switch response.result {
                        case .success(_):
                            if MemberVO.shared.dogList!.count == 1 {
                                UserDefaults.standard.removeObject(forKey: "dog_id")
                            } else {
                                if indexPath.row == 1 {
                                    UserDefaults.standard.setValue(MemberVO.shared.dogList![0].id, forKey: "dog_id")
                                } else {
                                    UserDefaults.standard.setValue(MemberVO.shared.dogList![1].id, forKey: "dog_id")
                                }
                            }
                            self.loadHomeData(toHome: false)
                        case .failure(_):
                            self.present(Common().errorAlert(), animated: false, completion: nil)
                            print("error")
                        }
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            alert.addAction(editAction)
            alert.addAction(deleteAction)
            present(alert, animated: true, completion: nil)
        }
       return false
   }
    
    //MARK:- 셋팅 테이블 cell을 클릭했을 때
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        //MARK:- 개발정보
        case 1:
            switch indexPath.row {
            case 0:
                print()
            //MARK: 버그 또는 문의
            case 1:
                let mailView = MFMailComposeViewController()
                //메일 정보 셋팅
                var systemInfo = utsname()
                uname(&systemInfo)
                let machineMirror = Mirror(reflecting: systemInfo.machine)
                let identifier = machineMirror.children.reduce("") { identifier, element in
                    guard let value = element.value as? Int8, value != 0 else { return identifier }
                    return identifier + String(UnicodeScalar(UInt8(value)))
                }
                
                mailView.mailComposeDelegate = self
                mailView.setSubject("버그 또는 문의 보내기")
                mailView.setToRecipients(["najinland@gmail.com"])
                mailView.setMessageBody("<br/><br/><br/>기기 정보 : \(identifier)<br/>OS 버전 : \(UIDevice.current.systemVersion)<br/>앱 버전 : \(deviceVersion)", isHTML: true)
                
                if MFMailComposeViewController.canSendMail() {
                    present(mailView, animated: false, completion: nil)
                } else {
                    let sendMailErrorAlert = UIAlertController.init(title: "메일전송 실패",
                                                                    message: "메일을 전송할 수 없습니다.\n아이폰 설정의 메일 계정을 확인해주세요.", preferredStyle: .alert)
                    sendMailErrorAlert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                    self.present(sendMailErrorAlert, animated: true, completion: nil)
                }

            //MARK: 앱 평가하기
            case 2:
                if let reviewURL = URL(string: "https://itunes.apple.com/app/id1545660854?action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
                    UIApplication.shared.open(reviewURL)
                }
            //MARK: 앱 공유하기
            case 3:
                let textToShare = [ "🐶멍멍한하루🐶\n강아지의 모든 것을 담은 다이어리\n\nhttps://itunes.apple.com/app/id1545660854" ]
                let activityVC = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view // 아이패드에서도 동작하도록 팝오버로 설정
                activityVC.excludedActivityTypes = [ .airDrop ] //airDrop 제외
                self.present(activityVC, animated: true, completion: nil)
            //MARK: FAQ
            case 4:
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "FAQviewController")
                self.navigationController?.pushViewController(vc, animated: false)
            default:
                print("error")
            }
        //MARK:- 약관
        case 2:
            switch indexPath.row {
            //MARK: 서비스 이용약관
            case 0:
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "termsAndUseViewController")
                self.present(vc, animated: true, completion: nil)
            //MARK: 개인정보 보호약관
            case 1:
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "privacyViewController")
                self.present(vc, animated: true, completion: nil)
            //MARK: 위치서비스 이용약관
            case 2:
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "locationUseViewController")
                self.present(vc, animated: true, completion: nil)
            default:
                print("error")
            }
        //MARK:- 계정관리
        case 3:
            switch indexPath.row {
            //MARK: 회원등급확인
            case 0:
                if MemberVO.shared.grade == 1 {
//                    let nextView = self.storyboard?.instantiateViewController(withIdentifier: "removeADViewController")
//                    self.navigationController?.pushViewController(nextView!, animated: false)
                }
            //MARK: 이메일등록
            case 1:
                let nextView = self.storyboard?.instantiateViewController(withIdentifier: "mailViewController")
                self.navigationController?.pushViewController(nextView!, animated: false)
            //MARK: 로그아웃
            case 2:
                let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let okAction = UIAlertAction(title: "로그아웃", style: .destructive) {
                    (action) in
                    UserDefaults.standard.removeObject(forKey: "id")
                    UserDefaults.standard.removeObject(forKey: "dog_id")
                    NotificationCenter.default.post(name: SettingTableViewController.NotificationDone, object: nil)
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            //MARK: 탈퇴
            case 3:
                let alert = UIAlertController(title: "계정삭제", message: "등록하신 정보가 모두 삭제됩니다.\n 정말 탈퇴하시겠습니까?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let okAction = UIAlertAction(title: "탈퇴", style: .destructive) {
                    (action) in
                    let URL = Common().baseURL+"/diary/member/"+UserDefaults.standard.string(forKey: "id")!
                    let alamo = AF.request(URL, method: .delete).validate(statusCode: 200..<300)
                    alamo.response { (response) in
                        switch response.result {
                        case .success(_):
                            UserDefaults.standard.removeObject(forKey: "id")
                            UserDefaults.standard.removeObject(forKey: "dog_id")
                            NotificationCenter.default.post(name: SettingTableViewController.NotificationDone, object: nil)
                        case .failure(_):
                            self.present(Common().errorAlert(), animated: false, completion: nil)
                        }
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            default:
                print("error")
            }
        default:
            print("error")
        }
        
        if let cell = tableView.cellForRow(at: indexPath){
            cell.selectionStyle = .none
       }
    }
    
    func loadHomeData(toHome: Bool) {
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
            
            if UserDefaults.standard.string(forKey: "dog_id") != nil {
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
                    
                    if toHome {
                        self.navigationController?.popViewController(animated: false)
                    } else {
                        self.myDogCollectionView.reloadData()
                    }
                }
            } else {
                HomeVO.shared.dog = nil
                HomeVO.shared.lastWashDay = nil
                HomeVO.shared.lastWeightDay = nil
                HomeVO.shared.lastWeight = nil
                HomeVO.shared.lastHeartDay = nil
                HomeVO.shared.totalMoney = nil
                HomeVO.shared.walkList = nil
                HomeVO.shared.weightChart = nil
                HomeVO.shared.moneyList = nil
                
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                self.myDogCollectionView.reloadData()
            }
        }
    }
}
