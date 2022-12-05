//
//  EtcUpdatePopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2021/02/19.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class EtcUpdatePopUpViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var updateButton: UIButton!
    
    //입력값
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contentCount: UILabel!
    
    //입력값 체크
    @IBOutlet weak var checkTitleLabel: UILabel!
    @IBOutlet weak var checkContentLabel: UILabel!
    
    //날짜 입력
    @IBOutlet weak var datePopOuterView: UIView!
    @IBOutlet weak var datePopUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var dateCancelButton: UIButton!
    
    var indicator: NVActivityIndicatorView!
    
    var selectedEtc: EtcVO!
    var type: Int!
    var date: String!
    var dateString: String?
    var viewHeight: CGFloat?
    var selectedIndex: Int?
    var checkTitle = true;
    var checkContent = true;
    
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
        
        //indicator 셋팅
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true
        
        //수정,삭제 구분하기
        if type == 1 {
            typeLabel.text = "일정 복사하기"
            updateButton.setTitle("등록하기", for: .normal)
        } else {
            typeLabel.text = "일정 수정하기"
            updateButton.setTitle("수정하기", for: .normal)
        }
        
        //color set collection view 셋팅
        colorCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "colorCell")
        
        //반응형 키보드
        viewHeight = view.frame.size.height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //프로퍼티 기본셋팅
        checkTitleLabel.isHidden = true
        checkContentLabel.isHidden = true
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.borderColor = #colorLiteral(red: 0.8802245259, green: 0.8749924302, blue: 0.8842467666, alpha: 1)
        contentTextView.layer.cornerRadius = 5
        
        if let firstIndex = colorList.firstIndex(of: selectedEtc.color!) {
            selectedIndex = firstIndex
            colorCollectionView.reloadData()
        }
        
        titleTextField.text = selectedEtc.title!
        contentTextView.text = selectedEtc.content!
        contentCount.text = "\(selectedEtc.content!.count)/100"
        
        //날짜 수정
        datePopOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        datePopOuterView.isHidden = true
        datePopUpView.layer.cornerRadius = 10
        dateCancelButton.layer.cornerRadius = 5
        dateButton.layer.cornerRadius = 5
        dateButton.backgroundColor = Common().mint
        dateButton.setTitleColor(.white, for: .normal)
        dateLabel.text = dateString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: "2020-01-01") {
            datePickerView.minimumDate = date
        }
        if let date = dateFormatter.date(from: date!) {
            datePickerView.setDate(date, animated: false)
        }
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
//    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.view.endEditing(true)
//    }
    
    //MARK: 일정 날짜 입력
    @IBAction func dateSelectClick(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        datePopOuterView.isHidden = false
    }
    @IBAction func dateButtonClick(_ sender: UIButton) {
        date = Common().dateFormatter.string(from: datePickerView.date)
        dateLabel.text = Common().dateStringFormatter.string(from: datePickerView.date)
        datePopOuterView.isHidden = true
    }
    @IBAction func dateCancelButtonClick(_ sender: UIButton) {
        self.datePopOuterView.isHidden = true
    }
    
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
        if titleTextField.text == "" {
            checkTitle = false
        } else {
            checkTitle = true
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        checkContentLabel.isHidden = true
        if contentTextView.text == "" {
            checkContent = false
        } else {
            checkContent = true
        }
    }
    
    //MARK: 취소버튼 눌렀을 때
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.view.endEditing(true)
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: 등록버튼 눌렀을 때
    @IBAction func updateButtonClick(_ sender: UIButton) {
        self.view.endEditing(true)
        let titleText = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let contentText = contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if titleText.count == 0 {
            checkTitleLabel.isHidden = false
        } else if contentText.count == 0 {
            checkContentLabel.isHidden = false
        } else {
            indicatorView.isHidden = false
            indicator.startAnimating()
            if type == 1 {
                etcInsert()
            } else {
                etcUpdate()
            }
        }
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
    
    func etcUpdate() {
        let URL = Common().baseURL+"/diary/etc/\(selectedEtc.id!)"
        let etc = EtcVO()
        etc.date = date!
        etc.color = colorList[selectedIndex!]
        etc.title = titleTextField.text!
        etc.content = contentTextView.text!
        let alamo = AF.request(URL, method: .put, parameters: etc, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.response { response in
            switch response.result {
            case .success(_):
                self.loadHomeData()
            case .failure(_):
                self.present(Common().errorAlert(), animated: false, completion: nil)
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
            }
        }
    }
    
    //MARK:- 데이터 셋팅
    func loadHomeData() {
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
            
            self.dismiss(animated: false, completion: nil)
        }
    }
}
