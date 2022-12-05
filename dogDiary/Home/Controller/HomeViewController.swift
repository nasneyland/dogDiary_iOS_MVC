//
//  HomeViewController.swift
//  dogDiary
//
//  Created by najin on 2020/10/28.
//

import UIKit
import Charts
import FSCalendar
import Alamofire

class HomeViewController: UIViewController, ChartViewDelegate, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    //MARK:- 선언 및 초기화
    //MARK: 프로퍼티 선언
    @IBOutlet weak var homeOuterView: UIView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var birthImageView: UIImageView!
    //기본정보
    @IBOutlet weak var calendarImageView: UIImageView!
    @IBOutlet weak var settingImageView: UIImageView!
    @IBOutlet weak var imageOuterView: UIView!
    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var insertDogButton: UIButton!
    @IBOutlet weak var dogNameLabel: UILabel!
    @IBOutlet weak var dogMonthLabel: UILabel!
    @IBOutlet weak var dogHumanAgeLabel: UILabel!
    //입력 버튼
    @IBOutlet weak var insertWalkButton: UIButton!
    @IBOutlet weak var insertWashButton: UIButton!
    @IBOutlet weak var insertWeightButton: UIButton!
    @IBOutlet weak var insertHeartButton: UIButton!
    @IBOutlet weak var insertMoneyButton: UIButton!
    @IBOutlet weak var insertEtcButton: UIButton!
    //심장사상충
    @IBOutlet weak var heartOuterView: UIView!  
    @IBOutlet weak var lastHeartLabel: UILabel!
    //목욕
    @IBOutlet weak var washOuterView: UIView!
    @IBOutlet weak var lastWashLabel: UILabel!
    //몸무게
    @IBOutlet weak var weightOuterView: UIView!
    @IBOutlet weak var lastWeightLabel: UILabel!
    //몸무게 그래프
    @IBOutlet weak var weightChartOuterView: UIView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var weightTypeButton: UIButton!
    @IBOutlet weak var weightMinLabel: UILabel!
    @IBOutlet weak var weightMaxLabel: UILabel!
    //산책 통계
    @IBOutlet weak var walkOuterView: UIView!
    @IBOutlet weak var walkLeftButton: UIButton!
    @IBOutlet weak var walkMonthLabel: UILabel!
    @IBOutlet weak var walkRightButton: UIButton!
    @IBOutlet weak var monthAvgDistanceLabel: UILabel!
    @IBOutlet weak var monthAvgTimeLabel: UILabel!
    @IBOutlet weak var walkCalendar: FSCalendar!
    //지출 통계
    @IBOutlet weak var moneyOuterView: UIView!
    @IBOutlet weak var moneyLeftButton: UIButton!
    @IBOutlet weak var moneyMonthLabel: UILabel!
    @IBOutlet weak var moneyRightButton: UIButton!
    @IBOutlet weak var monthMoneyLabel: UILabel!
    @IBOutlet weak var moneyField1Label: UILabel!
    @IBOutlet weak var moneyField2Label: UILabel!
    @IBOutlet weak var moneyField3Label: UILabel!
    @IBOutlet weak var moneyField4Label: UILabel!
    @IBOutlet weak var moneyField5Label: UILabel!
    @IBOutlet weak var moneyField1ProgressView: UIProgressView!
    @IBOutlet weak var moneyField2ProgressView: UIProgressView!
    @IBOutlet weak var moneyField3ProgressView: UIProgressView!
    @IBOutlet weak var moneyField4ProgressView: UIProgressView!
    @IBOutlet weak var moneyField5ProgressView: UIProgressView!
    
    var todayYear: Int!
    var todayMonth: Int!
    
    var selectedWalkList: [WalkVO]!
    var selectedWalkYear: Int!
    var selectedWalkMonth: Int!
    
    var selectedMoneyYear: Int!
    var selectedMoneyMonth: Int!
    
    //산책 data
    var sumTime = 0
    var sumDistance: Float = 0.0
    var walkDates: [String] = []
    var maxMinute = 0
    var minMinute = 0
    var diffMinute = 0
    
//    //알림설정
//    func requestNotificationPermission(){
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in
//            if didAllow {
//                //push 허용
//                UserDefaults.standard.set(1, forKey: "push")
//                print("push허용")
//            } else {
//                //push 거부
//                UserDefaults.standard.set(0, forKey: "push")
//                print("push거부")
//            }
//        })
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walkCalendar.delegate = self
        walkCalendar.dataSource = self
//        requestNotificationPermission()
        
        //calendar view로 이동
        calendarImageView.isUserInteractionEnabled = true
        let calendar = UITapGestureRecognizer(target: self, action: #selector(self.tapCalendar(_:)))
        self.calendarImageView.addGestureRecognizer(calendar)
        
        //setting view로 이동
        settingImageView.isUserInteractionEnabled = true
        let setting = UITapGestureRecognizer(target: self, action: #selector(self.tapSetting(_:)))
        self.settingImageView.addGestureRecognizer(setting)
        
        //뷰 셋팅
        homeOuterView.layer.cornerRadius = 10
        heartOuterView.layer.cornerRadius = 10
        washOuterView.layer.cornerRadius = 10
        weightOuterView.layer.cornerRadius = 10
        walkOuterView.layer.cornerRadius = 10
        weightChartOuterView.layer.cornerRadius = 10
        moneyOuterView.layer.cornerRadius = 10
        insertDogButton.layer.cornerRadius = 10
        
        //todayFormat 설정
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "ko")
        monthFormatter.dateFormat = "yyyy"
        todayYear = Int(monthFormatter.string(from: Date()))
        monthFormatter.dateFormat = "M"
        todayMonth = Int(monthFormatter.string(from: Date()))
        
        //강아지 프로필 셋팅
        imageOuterView.layer.cornerRadius = imageOuterView.frame.height / 2
        imageOuterView.layer.shadowColor = UIColor.gray.cgColor
        imageOuterView.layer.shadowOpacity = 1.0
        imageOuterView.layer.shadowOffset = CGSize.zero
        imageOuterView.layer.shadowRadius = 6
        imageOuterView.translatesAutoresizingMaskIntoConstraints = false
        dogImageView.layer.cornerRadius = dogImageView.frame.height / 2
        dogImageView.layer.masksToBounds = true
        
        //몸무게 차트 셋팅
        lineChartView.noDataText = "몸무게 데이터가 없습니다."
        lineChartView.noDataTextColor = .gray
        
        //walk calendar 셋팅
        walkCalendar.appearance.weekdayFont = UIFont(name: "Cafe24Ohsquare", size: 0)
        walkCalendar.appearance.titleFont = UIFont(name: "Gong Gothic OTF Light", size: 13)
        walkCalendar.appearance.subtitleFont = UIFont(name: "Cafe24Ohsquare", size: 0)
        walkCalendar.headerHeight = 0
        walkCalendar.appearance.titlePlaceholderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        walkCalendar.appearance.titleDefaultColor = .darkGray
        walkCalendar.appearance.titleTodayColor = .darkGray
        walkCalendar.scrollEnabled = false
        walkCalendar.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //오늘날짜 표시
        let dateString = Common().dateStringFormatter.string(from: Date())
        let birthFormatter = DateFormatter()
        birthFormatter.locale = Locale(identifier: "ko")
        birthFormatter.dateFormat = "MM-dd"
        todayLabel.text = dateString
        
        //오늘 연도와 월 셋팅
        let formatter_date = DateFormatter()
        formatter_date.dateFormat = "yyyy"
        selectedWalkYear = Int(formatter_date.string(from: Date()))
        selectedMoneyYear = Int(formatter_date.string(from: Date()))
        formatter_date.dateFormat = "M"
        selectedWalkMonth = Int(formatter_date.string(from: Date()))
        selectedMoneyMonth = Int(formatter_date.string(from: Date()))
        walkMonthLabel.text = "\(selectedWalkYear!)년 \(selectedWalkMonth!)월 산책"
        moneyMonthLabel.text = "\(selectedMoneyYear!)년 \(selectedMoneyMonth!)월 지출"
        
        if UserDefaults.standard.string(forKey: "dog_id") == nil {
            //아직 강아지 등록을 하지 않았을 때
            insertDogButton.isHidden = false
            birthImageView.isHidden = true
            
            insertWalkButton.isHidden = true
            insertMoneyButton.isHidden = true
            insertWashButton.isHidden = true
            insertWeightButton.isHidden = true
            insertHeartButton.isHidden = true
            insertEtcButton.isHidden = true
            
            walkLeftButton.isEnabled = false
            walkRightButton.isEnabled = false
            moneyLeftButton.isEnabled = false
            moneyRightButton.isEnabled = false
            weightTypeButton.isEnabled = false
            
            loadHomeReset()
        } else {
            //생일 배경 셋팅
            if HomeVO.shared.dog != nil && birthFormatter.string(from: Date()) == birthFormatter.string(from: Common().dateFormatter.date(from: HomeVO.shared.dog.birth ?? "")!) {
                birthImageView.isHidden = false
            } else {
                birthImageView.isHidden = true
            }
            
            insertDogButton.isHidden = true
            //오늘 심장사상충을 이미 등록했을 경우
            if HomeVO.shared.lastHeartDay == "0" {
                insertHeartButton.isHidden = true
            } else {
                insertHeartButton.isHidden = false
            }
            //오늘 몸무게를 이미 등록했을 경우
            if HomeVO.shared.lastWeightDay == "0" {
                insertWeightButton.isHidden = true
            } else {
                insertWeightButton.isHidden = false
            }
            //오늘 목욕을 이미 등록했을 경우
            if HomeVO.shared.lastWashDay == "0" {
                insertWashButton.isHidden = true
            } else {
                insertWashButton.isHidden = false
            }
            
            walkLeftButton.isEnabled = true
            walkRightButton.isEnabled = true
            moneyLeftButton.isEnabled = true
            moneyRightButton.isEnabled = true
            weightTypeButton.isEnabled = true
            
            insertWalkButton.isHidden = false
            insertMoneyButton.isHidden = false
            insertEtcButton.isHidden = false
            
            loadHomeData()
        }
    }
    
    //MARK:- 홈 초기화하기
    func loadHomeReset() {
        //강아지 정보 초기화
        self.dogImageView.image = UIImage(named: "app_dog")
        self.dogNameLabel.text = "멍멍이 🐶"
        self.dogMonthLabel.text = "-"
        self.dogHumanAgeLabel.text = "-"
            
        //입력 정보 초기화
        self.lastHeartLabel.textColor = .darkGray
        self.lastHeartLabel.text = "-"
        self.lastWashLabel.textColor = .darkGray
        self.lastWashLabel.text = "-"
        self.lastWeightLabel.text = "-"
        self.monthAvgTimeLabel.text = "0분"
        self.monthAvgDistanceLabel.text = "0km"
        self.monthMoneyLabel.text = "총 0원"
        
        //몸무게 뷰 초기화
        self.lineChartView.data = nil
        weightMinLabel.text = ""
        weightMaxLabel.text = ""
        
        //산책 캘린더 초기화
        walkCalendar.reloadData()
        
        //지출 뷰 초기화
        self.moneyField1Label.text = "0%"
        self.moneyField2Label.text = "0%"
        self.moneyField3Label.text = "0%"
        self.moneyField4Label.text = "0%"
        self.moneyField5Label.text = "0%"
        self.moneyField1ProgressView.progress = 0
        self.moneyField2ProgressView.progress = 0
        self.moneyField3ProgressView.progress = 0
        self.moneyField4ProgressView.progress = 0
        self.moneyField5ProgressView.progress = 0
    }
    
    //MARK:- 강아지 정보 셋팅하기
    func loadHomeData() {
        //강아지 프로필 이미지 셋팅
        if HomeVO.shared.dog.image ?? "" != "" {
            guard let url = URL(string: "\(Common().baseURL)/media/\(HomeVO.shared.dog.image ?? "")") else {
                return
            }
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    self.dogImageView.image = image
                }
            }
        } else {
            self.dogImageView.image = UIImage(named: "app_dog")
        }

        //강아지 이름과 성별 셋팅
        if HomeVO.shared.dog.gender == 1 {
            let nameString = HomeVO.shared.dog.name! + " ♂︎"
            let attributedStr = NSMutableAttributedString(string: nameString)
            attributedStr.addAttribute(.foregroundColor, value: Common().genderBlue, range: (nameString as NSString).range(of: "♂︎"))
            self.dogNameLabel.attributedText = attributedStr
        } else {
            let nameString = HomeVO.shared.dog.name! + " ♀︎"
            let attributedStr = NSMutableAttributedString(string: nameString)
            attributedStr.addAttribute(.foregroundColor, value: Common().genderPink, range: (nameString as NSString).range(of: "♀︎"))
            self.dogNameLabel.attributedText = attributedStr
        }

        //강아지 개월수 셋팅
        let birthDate = Common().dateFormatter.date(from: HomeVO.shared.dog.birth!)
        let todayDate = Common().dateFormatter.date(from: Common().dateFormatter.string(from: Date()))
        let calendar = Calendar(identifier: .gregorian)
        let offsetComps = calendar.dateComponents([.year,.month, .day], from:birthDate!, to:todayDate!)
        if case let (y?, m?, d?) = (offsetComps.year, offsetComps.month, offsetComps.day) {
            //태어난지
            if y < 0 || m < 0 || d < 0 {
                self.dogMonthLabel.text = "-"
            } else if y == 0 {
                self.dogMonthLabel.text = "\(m)개월"
            } else if m == 0 {
                self.dogMonthLabel.text = "\(y)년"
            } else {
                self.dogMonthLabel.text = "\(y)년 \(m)개월"
            }
            //강아지 나이 사람나이로 환산
            var age = 0
            if y == 0 {
                //1살 전까지
                switch m {
                case 1:
                    age = 1
                case 2:
                    age = 2
                case 3:
                    age = 5
                case 4:
                    age = 6
                case 5:
                    age = 8
                case 6:
                    age = 10
                case 7:
                    age = 11
                case 8:
                    age = 12
                case 9:
                    age = 13
                case 10:
                    age = 14
                case 11:
                    age = 15
                default:
                    age = 0
                }
            } else if y == 1 {
                age = 16
            } else if y == 2 {
                age = 24
            } else {
                if Float(HomeVO.shared.lastWeight ?? "0")! < 10 {
                    age = 24 + ( y - 2 ) * 5
                } else if Float(HomeVO.shared.lastWeight ?? "0")! < 20 {
                    age = 24 + ( y - 2 ) * 6
                } else {
                    age = 24 + ( y - 2 ) * 7
                }
            }
            var group = ""
            if y == 0 {
                if m <= 4 {
                    group = "영유아기"
                } else {
                    group = "청소년기"
                }
            } else {
                if y == 1 {
                    group = "청소년기"
                } else if y <= 4 {
                    group = "청년기"
                } else if y <= 10 {
                    group = "중장년기"
                } else {
                    group = "노년기"
                }
            }
            if y < 0 || m < 0 || d < 0 {
                self.dogHumanAgeLabel.text = "-"
            } else {
                self.dogHumanAgeLabel.text = "\(age)세 \(group)"
            }
        }
            
        //마지막 심장사상충
        if HomeVO.shared.lastHeartDay == nil {
            self.lastHeartLabel.textColor = .darkGray
            self.lastHeartLabel.text = "-"
        } else if HomeVO.shared.lastHeartDay == "0" {
            self.lastHeartLabel.textColor = Common().blue
            self.lastHeartLabel.text = "오늘"
        } else {
            self.lastHeartLabel.textColor = Int(HomeVO.shared.lastHeartDay!)! >= 30 ? Common().red : .darkGray
            self.lastHeartLabel.text = "\(HomeVO.shared.lastHeartDay!)일전"
        }
        
        //마지막 목욕
        if HomeVO.shared.lastWashDay == nil {
            self.lastWashLabel.textColor = .darkGray
            self.lastWashLabel.text = "-"
        } else if HomeVO.shared.lastWashDay == "0" {
            self.lastWashLabel.textColor = Common().blue
            self.lastWashLabel.text = "오늘"
        } else {
            self.lastWashLabel.textColor = Int(HomeVO.shared.lastWashDay!)! >= 100 ? Common().red : .darkGray
            self.lastWashLabel.text = "\(HomeVO.shared.lastWashDay!)일전"
        }
        
        //마지막 몸무게
        if HomeVO.shared.lastWeight == nil {
            self.lastWeightLabel.text = "-"
        } else {
            self.lastWeightLabel.text = "\(HomeVO.shared.lastWeight!)kg"
        }
        
        //산책 셋팅
        setWalkCalendar(walks: HomeVO.shared.walkList!)
        
        //몸무게 셋팅
        weightTypeButton.setTitle("최근 몸무게 변화량 ", for: .normal)
        setWeightChart(weights: HomeVO.shared.weightChart!)
        
        //지출 셋팅
        setMoneyChart(moneys: HomeVO.shared.moneyList!)
    }
    
    //MARK:- 산책 달력 셋팅
    func setWalkCalendar(walks: [WalkVO]) {
        //산책 데이터 계산
        sumTime = 0
        sumDistance = 0.0
        walkDates = []
        maxMinute = 0
        minMinute = 0
        diffMinute = 0
        selectedWalkList = walks
        
        var walkMinutes: [Int] = []
        for walk in walks {
            sumTime += walk.minutes!
            sumDistance += Float(walk.distance!)!
            walkDates.append(walk.date!)
            walkMinutes.append(walk.minutes!)
        }
        
        minMinute = walkMinutes.min() ?? 0
        maxMinute = walkMinutes.max() ?? 0
        diffMinute = maxMinute - minMinute
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.M"
        let dateResult = dateFormatter.date(from: "\(selectedWalkYear!).\(selectedWalkMonth!)")
        self.walkCalendar.setCurrentPage(dateResult!, animated: true)
        
        let days: String
        
        if !((selectedWalkYear! == todayYear!) && (selectedWalkMonth! == todayMonth!)) {
            let dateComponents = DateComponents(year: selectedWalkYear, month: selectedWalkMonth)
            let calendar = Calendar.current
            let date = calendar.date(from: dateComponents)!
            let range = calendar.range(of: .day, in: .month, for: date)!
            days = "\(range.count)"
        } else {
            dateFormatter.locale = Locale(identifier: "ko")
            dateFormatter.dateFormat = "dd"
            days = dateFormatter.string(from: Date())
        }
        
        //평균 시간
        let totalminute = (sumTime / Int(days)!)
        self.monthAvgTimeLabel.text = "\(totalminute)분"
        
        //평균 거리
        let totaldistance = Float(sumDistance)
        let avgdistance = String(format: "%.1f", (totaldistance / Float(days)!))
        self.monthAvgDistanceLabel.text = "\(avgdistance)km"
        
        walkCalendar.reloadData()
    }
    
    func calendar(_ calendar:FSCalendar, appearance apperance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        if UserDefaults.standard.string(forKey: "dog_id") != nil {
            var minutes = 0
            for walk in selectedWalkList {
                if walk.date == Common().dateFormatter.string(from: date) {
                    minutes += walk.minutes!
                }
            }
            if minutes != 0 {
                if minutes >= (maxMinute - (1 * (diffMinute / 10))) {
                    return Common().tracker5
                } else if minutes >= (maxMinute - (4 * (diffMinute / 10))) {
                    return Common().tracker4
                } else if minutes >= (maxMinute - (6 * (diffMinute / 10))) {
                    return Common().tracker3
                } else if minutes >= (maxMinute - (9 * (diffMinute / 10))) {
                    return Common().tracker2
                } else {
                    return Common().tracker1
                }
            } else {
                return .clear
            }
        } else {
            return .clear
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        return 1
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "ko")
        monthFormatter.dateFormat = "yyyyM"
        if "\(selectedWalkYear!)\(selectedWalkMonth!)" == monthFormatter.string(from: date) {
            return .gray
        } else {
            return .clear
        }
    }
    
    //이전 달력으로 이동
    @IBAction func walkLeftButtonClick(_ sender: UIButton) {
        selectedWalkMonth -= 1
        if selectedWalkMonth == 0 {
            selectedWalkMonth = 12
            selectedWalkYear -= 1
        }
        setWalkData()
    }
    
    //다음 달력으로 이동
    @IBAction func walkRightButtonClick(_ sender: UIButton) {
        if !((selectedWalkYear! == todayYear!) && (selectedWalkMonth! == todayMonth!)) {
            selectedWalkMonth += 1
            if selectedWalkMonth == 13 {
                selectedWalkMonth = 1
                selectedWalkYear += 1
            }
            setWalkData()
        }
    }
    
    //MARK: 산책 데이터 불러오기
    func setWalkData() {
        //alamofire - walk data 받아오기
        let URL = Common().baseURL+"/diary/home/walk/"+UserDefaults.standard.string(forKey: "dog_id")!
        let alamo = AF.request(URL, method: .post, parameters: ["year": selectedWalkYear, "month": selectedWalkMonth], encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.response { response in
            switch response.result {
            case .success(let value):
                let jsonDecoder = JSONDecoder()
                do {
                    let walkList = try jsonDecoder.decode([WalkVO].self, from: value!)
                    self.setWalkCalendar(walks: walkList)
                    self.walkMonthLabel.text = "\(self.selectedWalkYear!)년 \(self.selectedWalkMonth!)월 산책"
                } catch {
                    print("json_decoder_error")
                }
            case .failure(_):
                let alert = UIAlertController(title: "서버 접속 실패", message: "인터넷 연결 상태를 확인해주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default)
                alert.addAction(action)
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
    
    //MARK:- 몸무게 뷰 셋팅하기
    func setWeightChart(weights: [WeightVO]) {
        if weights.count == 0 {
            //몸무게가 없으면 초기화
            self.lineChartView.data = nil
            weightMinLabel.text = ""
            weightMaxLabel.text = ""
        } else {
            //몸무게 그래프 셋팅
            self.lineChartView.dragEnabled = false
            self.lineChartView.isUserInteractionEnabled = false
            self.lineChartView.leftAxis.enabled = false
            self.lineChartView.xAxis.enabled = false
            self.lineChartView.legend.enabled = false

            //y축 설정
            let yAxis = self.lineChartView.rightAxis
            yAxis.setLabelCount(3, force: true)
            yAxis.labelTextColor = .black
            yAxis.axisLineColor = .white
            
            //x축 설정
            weightMinLabel.text = weights.first?.date
            weightMaxLabel.text = weights.last?.date

            //몸무게 데이터 셋팅
            var yValues: [ChartDataEntry]?
            var cnt = 0
            for weight in weights {
                cnt += 1
                if yValues == nil {
                    yValues = [ChartDataEntry(x: Double(cnt), y: Double(weight.kg!)!)]
                } else {
                    yValues!.append(ChartDataEntry(x: Double(cnt), y: Double(weight.kg!)!))
                }
            }
            let set1 = LineChartDataSet(entries: yValues, label: "weight")
            set1.drawCirclesEnabled = false
            set1.mode = .cubicBezier
            //set1.mode = .horizontalBezier
            set1.lineWidth = 3
            set1.setColor(Common().lightGreen)
            set1.fill = Fill(color: Common().lightGreen)
            set1.fillAlpha = 0.8
            set1.drawFilledEnabled = true

            let data = LineChartData(dataSet: set1)
            data.setDrawValues(false)
            self.lineChartView.data = data
        }
    }
    
    //MARK: 몸무게 모드 변경
    @IBAction func weightTypeButtonClick(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let last10Action = UIAlertAction(title: "최근 10회 변화량", style: .default) { [self]
            (action) in
            self.weightTypeButton.setTitle("최근 몸무게 변화량 ", for: .normal)
            self.setWeightChart(weights: HomeVO.shared.weightChart!)
        }
        let thisMonthAction = UIAlertAction(title: "이번 달 변화량", style: .default) {
            (action) in
            self.weightTypeButton.setTitle("이번 달 몸무게 변화량 ", for: .normal)
            self.setWeightData(weightType: 1)
        }
        let thisYearAction = UIAlertAction(title: "이번 연도 변화량", style: .default) {
            (action) in
            self.weightTypeButton.setTitle("이번 연도 몸무게 변화량 ", for: .normal)
            self.setWeightData(weightType: 2)
        }
        let totalAction = UIAlertAction(title: "전체 변화량", style: .default) {
            (action) in
            self.weightTypeButton.setTitle("전체 몸무게 변화량 ", for: .normal)
            self.setWeightData(weightType: 3)
        }
        alert.title = "몸무게 그래프 기간"
        alert.addAction(cancelAction)
        alert.addAction(last10Action)
        alert.addAction(thisMonthAction)
        alert.addAction(thisYearAction)
        alert.addAction(totalAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: 몸무게 데이터 불러오기
    func setWeightData(weightType: Int) {
        //alamofire - weight data 받아오기
        let URL = Common().baseURL+"/diary/home/weight/"+UserDefaults.standard.string(forKey: "dog_id")!
        let alamo = AF.request(URL, method: .post, parameters: ["type":weightType], encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.response { response in
            switch response.result {
            case .success(let value):
                let jsonDecoder = JSONDecoder()
                do {
                    let weightList = try jsonDecoder.decode([WeightVO].self, from: value!)
                    self.setWeightChart(weights: weightList)
                } catch {
                    print("json_decoder_error")
                }
            case .failure(_):
                let alert = UIAlertController(title: "서버 접속 실패", message: "인터넷 연결 상태를 확인해주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default)
                alert.addAction(action)
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
        
    //MARK:- 지출 뷰 셋팅하기
    func setMoneyChart(moneys: [MoneyVO]) {
        var field1 = 0
        var field2 = 0
        var field3 = 0
        var field4 = 0
        var field5 = 0
        var totalMoney = 0
        for money in moneys {
            totalMoney += money.price!
            switch money.type {
            case 1:
                field1 += money.price!
            case 2:
                field2 += money.price!
            case 3:
                field3 += money.price!
            case 4:
                field4 += money.price!
            case 5:
                field5 += money.price!
            default:
                print()
            }
        }
        
        //총 지출
        self.monthMoneyLabel.text = "총 " + Common().DecimalWon(value: totalMoney)
        
        let fieldTotal = field1 + field2 + field3 + field4 + field5
        if fieldTotal != 0 {
            
            let percentField1 = Float(field1) / Float(fieldTotal)
            let percentField2 = Float(field2) / Float(fieldTotal)
            let percentField3 = Float(field3) / Float(fieldTotal)
            let percentField4 = Float(field4) / Float(fieldTotal)
            let percentField5 = Float(field5) / Float(fieldTotal)
            
            self.moneyField1Label.text = "\(Int(round((percentField1) * 100)))%"
            self.moneyField2Label.text = "\(Int(round((percentField2) * 100)))%"
            self.moneyField3Label.text = "\(Int(round((percentField3) * 100)))%"
            self.moneyField4Label.text = "\(Int(round((percentField4) * 100)))%"
            self.moneyField5Label.text = "\(Int(round((percentField5) * 100)))%"

            self.moneyField1ProgressView.progress = percentField1
            self.moneyField2ProgressView.progress = percentField2
            self.moneyField3ProgressView.progress = percentField3
            self.moneyField4ProgressView.progress = percentField4
            self.moneyField5ProgressView.progress = percentField5
        } else {
            self.moneyField1Label.text = "0%"
            self.moneyField2Label.text = "0%"
            self.moneyField3Label.text = "0%"
            self.moneyField4Label.text = "0%"
            self.moneyField5Label.text = "0%"
            
            self.moneyField1ProgressView.progress = 0
            self.moneyField2ProgressView.progress = 0
            self.moneyField3ProgressView.progress = 0
            self.moneyField4ProgressView.progress = 0
            self.moneyField5ProgressView.progress = 0
        }
    }
    
    //MARK: 이전 달의 지출 목록 보기
    @IBAction func moneyLeftButtonClick(_ sender: UIButton) {
        selectedMoneyMonth -= 1
        if selectedMoneyMonth == 0 {
            selectedMoneyMonth = 12
            selectedMoneyYear -= 1
        }
        setMoneyData()
    }
    
    //MARK: 다음 달의 지출 목록 보기
    @IBAction func moneyRightButtonClick(_ sender: UIButton) {
        if !((selectedMoneyYear! == todayYear!) && (selectedMoneyMonth! == todayMonth!)) {
            selectedMoneyMonth += 1
            if selectedMoneyMonth == 13 {
                selectedMoneyMonth = 1
                selectedMoneyYear += 1
            }
            setMoneyData()
        }
    }
    
    //MARK: 지출 데이터 불러오기
    func setMoneyData() {
        //alamofire - money data 받아오기
        let URL = Common().baseURL+"/diary/home/money/"+UserDefaults.standard.string(forKey: "dog_id")!
        let alamo = AF.request(URL, method: .post, parameters: ["year": selectedMoneyYear, "month": selectedMoneyMonth], encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.response { response in
            switch response.result {
            case .success(let value):
                let jsonDecoder = JSONDecoder()
                do {
                    let moneyList = try jsonDecoder.decode([MoneyVO].self, from: value!)
                    self.setMoneyChart(moneys: moneyList)
                    self.moneyMonthLabel.text = "\(self.selectedMoneyYear!)년 \(self.selectedMoneyMonth!)월 지출"
                } catch {
                    print("json_decoder_error")
                }
            case .failure(_):
                let alert = UIAlertController(title: "서버 접속 실패", message: "인터넷 연결 상태를 확인해주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default)
                alert.addAction(action)
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
    
    //MARK:- 강아지 등록 버튼 클릭
    @IBAction func insertDogButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "joinViewController")
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK: 캘린더 클릭
    @objc func tapCalendar(_ tap: UITapGestureRecognizer) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "dogCalendarViewController")
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK: 설정 클릭
    @objc func tapSetting(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "settingViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: 산책하기 버튼 클릭
    @IBAction func walkButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "walkPopUpView")as! WalkPopUpViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    //MARK: 목욕하기 버튼 클릭
    @IBAction func washButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "washPopUpView")as! WashPopUpViewController
        vc.date = Common().dateFormatter.string(from: Date())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    //MARK: 몸무게 버튼 클릭
    @IBAction func weightButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "weightPopUpView")as! WeightPopUpViewController
        vc.date = Common().dateFormatter.string(from: Date())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    //MARK: 심장사상충 버튼 클릭
    @IBAction func heartButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "heartPopUpView")as! HeartPopUpViewController
        vc.date = Common().dateFormatter.string(from: Date())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    //MARK: 지출하기 버튼 클릭
    @IBAction func moneyButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "moneyPopUpView")as! MoneyPopUpViewController
        vc.date = Common().dateFormatter.string(from: Date())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    //MARK: 기타내역 버튼 클릭
    @IBAction func etcButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "etcPopUpView")as! EtcPopUpViewController
        vc.date = Common().dateFormatter.string(from: Date())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
}
