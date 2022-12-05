//
//  EtcPopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2021/02/15.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import GoogleMobileAds

class EtcPopUpViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate, GADInterstitialDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //입력값
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contentCount: UILabel!
    
    //입력값 체크
    @IBOutlet weak var checkColorLabel: UILabel!
    @IBOutlet weak var checkTitleLabel: UILabel!
    @IBOutlet weak var checkContentLabel: UILabel!
    
    var indicator: NVActivityIndicatorView!
    var interstitial: GADInterstitial!
    
    var date: String!
    var dateString: String?
    var viewHeight: CGFloat?
    var selectedIndex: Int?
    var checkTitle = false;
    var checkContent = false;
    
    let colorList = ["#e9a799","#db8438","#c76026","#963f2e","#edc233",
                     "#97d5e0","#89bbb8","#479a83","#5c7148","#4a5336",
                     "#489ad8","#bfa7f6","#a7a3f8","#8357ac","#3c5066",
                     "#bec3c7","#999999","#818b8d","#798da5","#495057",]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        scrollView.delegate = self
        titleTextField.delegate = self
        contentTextView.delegate = self
        
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
        
        //color set collection view 셋팅
        colorCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "colorCell")
        
        //날짜 셋팅
        if date == Common().dateFormatter.string(from: Date()) {
            dateLabel.text = "오늘의"
        } else {
            dateLabel.text = dateString
        }
        
        //반응형 키보드
        viewHeight = view.frame.size.height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //프로퍼티 기본셋팅
        checkColorLabel.isHidden = true
        checkTitleLabel.isHidden = true
        checkContentLabel.isHidden = true
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.borderColor = #colorLiteral(red: 0.8802245259, green: 0.8749924302, blue: 0.8842467666, alpha: 1)
        contentTextView.layer.cornerRadius = 5
    }
    
    //keyboard 반응형
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.size.height = viewHeight! - keyboardSize.height
        }
        self.view.layoutIfNeeded()
        scrollView.scrollToBottom()
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.size.height = viewHeight!
        self.view.layoutIfNeeded()
    }

//    //MARK: 키보드 없애기
//    @IBAction func tabView(_ sender: UIGestureRecognizer) {
//        self.view.endEditing(true)
//    }
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.view.endEditing(true)
//    }
    
    //MARK:- color set 콜렉션 뷰 셋팅
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
        
        cell.colorView.layer.cornerRadius = 25
        cell.colorView.backgroundColor = UIColor(hexString: colorList[indexPath.row])
        
        if selectedIndex != nil && selectedIndex == indexPath.row {
            cell.selectedImageView.isHidden = false
        } else {
            cell.selectedImageView.isHidden = true
        }
        return cell
    }
    
    //MARK:- color set cell을 클릭했을 때
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        checkColorLabel.isHidden = true
        self.view.endEditing(true)
        selectedIndex = indexPath.row
        colorCollectionView.reloadData()
        return false
   }
    
    //MARK: 글자 수 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //최대 5문자만 입력가능하도록 설정
        guard let textFieldText = textField.text, let rangeOfTextToReplce = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplce]
        let count = textFieldText.count - substringToReplace.count + string.count

        return count <= 5
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //최대 100자만 입력가능하도록 설정
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        contentCount.text = "\(updatedText.count)/100"
        return updatedText.count < 100
    }
    
    //MARK: 제목, 상세 내용 유효성검사
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkTitleLabel.isHidden = true
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        checkContentLabel.isHidden = true
    }
    
    //MARK: 취소버튼 눌렀을 때
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.view.endEditing(true)
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: 등록버튼 눌렀을 때
    @IBAction func insertButtonClick(_ sender: UIButton) {
        let titleText = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let contentText = contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if selectedIndex == nil {
            checkColorLabel.isHidden = false
        } else if titleText.count == 0 {
            checkTitleLabel.isHidden = false
        } else if contentText.count == 0 {
            checkContentLabel.isHidden = false
            scrollView.scrollToBottom()
        } else {
            indicatorView.isHidden = false
            indicator.startAnimating()
            if MemberVO.shared.grade! == 1 {
                if interstitial.isReady {
                    interstitial.present(fromRootViewController: self)
                } else {
                    etcInsert()
                }
            } else {
                etcInsert()
            }
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        etcInsert()
    }
    
    func etcInsert() {
        let URL = Common().baseURL+"/diary/etc"
        let etc = EtcVO()
        etc.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
        etc.date = self.date
        etc.color = colorList[selectedIndex!]
        etc.title = titleTextField.text
        etc.content = contentTextView.text
        let alamo = AF.request(URL, method: .post, parameters: etc, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.response { response in
            switch response.result {
            case .success(_):
                self.dismiss(animated: false, completion: nil)
            case .failure(_):
                self.present(Common().errorAlert(), animated: false, completion: nil)
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
            }
        }
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension UIScrollView {
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
}
