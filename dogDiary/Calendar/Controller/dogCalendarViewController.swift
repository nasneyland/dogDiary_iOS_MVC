//
//  dogCalendarViewController.swift
//  dogDiary
//
//  Created by najin on 2020/11/02.
//

import UIKit
import FSCalendar
import Alamofire
import NVActivityIndicatorView

class DogCalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource{

    //MARK:- 선언 및 초기화
    //MARK: 프로퍼티 선언
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var popOuterView: UIView!
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    //입력 버튼
    @IBOutlet weak var insertWalkButton: UIButton!
    @IBOutlet weak var insertWashButton: UIButton!
    @IBOutlet weak var insertWeightButton: UIButton!
    @IBOutlet weak var insertHeartButton: UIButton!
    @IBOutlet weak var insertMoneyButton: UIButton!
    
//    @IBOutlet weak var bannerView: GADBannerView!
//    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    var indicator: NVActivityIndicatorView!
    var checkCount = 0
    
    var walks: [WalkVO] = []
    var washs: [WashVO] = []
    var weights: [WeightVO] = []
    var hearts: [HeartVO] = []
    var moneys: [MoneyVO] = []
    var etcs: [EtcVO] = []
    
    var selectedWalks: [WalkVO] = []
    var selectedWashs: [WashVO] = []
    var selectedWeights: [WeightVO] = []
    var selectedHearts: [HeartVO] = []
    var selectedMoneys: [MoneyVO] = []
    var selectedEtcs: [EtcVO] = []
    
    var selectedDate: String?
    var selectedDateString: String?
    
    //MARK: 초기화
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        //bannerView.delegate = self
        
        popOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        popUpView.layer.cornerRadius = 20
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        //indicator 셋팅
        indicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50), type: .ballPulseSync, color: .white, padding: 0)
        self.view.addSubview(indicator)
        indicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        indicatorView.isHidden = true

        //라벨에 타이틀 날짜 넣기
        _ = moveDate(type: 0)
        
        //달력 font 설정
        calendar.locale = Locale(identifier: "en_US")
        calendar.appearance.weekdayFont = UIFont(name: "Cafe24Ohsquare", size: 15)
//        calendar.appearance.weekdayFont = UIFont(name: "Gong Gothic OTF Medium", size: 15)
        calendar.appearance.titleFont = UIFont(name: "ImcreSoojin OTF", size: 0)
//        calendar.appearance.subtitleFont = UIFont(name: "ImcreSoojin OTF", size: 40)
        
        //달력 배경색, 선택한 날짜색, 오늘 날짜색 설정
        calendar.backgroundColor = .white
//        calendar.layer.cornerRadius = 10
        calendar.appearance.selectionColor = .clear
//        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.todayColor = .clear
//        calendar.appearance.titleWeekendColor = Common().red
//        calendar.appearance.titleTodayColor = Common().blue
        
        //스크롤 작동여부와 방향
        calendar.scrollEnabled = true
        calendar.scrollDirection = .horizontal
        
        //custom cell 선언
        calendar.collectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendarCell")
        tableView.register(UINib(nibName: "CalendarTableViewCell", bundle: nil), forCellReuseIdentifier: "tableCell")
        
//        //배너광고 추가
//        if MemberVO.shared.grade == 2 || self.view.frame.height < 810 {
//            bannerHeight.constant = 0
//        } else {
//            bannerHeight.constant = 100
//            bannerView.adUnitID = "ca-app-pub-1025720268361094/3777980798"
////            bannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111" //test ID
//            bannerView.rootViewController = self
//            bannerView.load(GADRequest())
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        popOuterView.isHidden = true
        
        //강아지 등록이 되어있는 경우
        if UserDefaults.standard.string(forKey: "dog_id") != nil {
            checkCount = 0
            self.indicatorView.isHidden = false
            self.indicator.startAnimating()
            //calendar 기본 셋팅
            calendarData(type: "walk")
            calendarData(type: "wash")
            calendarData(type: "weight")
            calendarData(type: "heart")
            calendarData(type: "money")
            calendarData(type: "etc")
        }
    }
    
    //MARK: 서버에서 날짜 데이터 받아오는 함수
    func calendarData(type: String) {
        let URL = Common().baseURL+"/diary/\(type)/\(UserDefaults.standard.string(forKey: "dog_id")!)"
        let alamo = AF.request(URL, method: .get).validate(statusCode: 200..<300)
        alamo.response { response in
            switch response.result {
            case .success(let value):
                let jsonDecoder = JSONDecoder()
                do {
                    switch type {
                    case "walk":
                        self.walks = try jsonDecoder.decode([WalkVO].self, from: value!)
                        self.calendar.reloadData()
                    case "wash":
                        self.washs = try jsonDecoder.decode([WashVO].self, from: value!)
                        self.calendar.reloadData()
                    case "weight":
                        self.weights = try jsonDecoder.decode([WeightVO].self, from: value!)
                        self.calendar.reloadData()
                    case "heart":
                        self.hearts = try jsonDecoder.decode([HeartVO].self, from: value!)
                        self.calendar.reloadData()
                    case "money":
                        self.moneys = try jsonDecoder.decode([MoneyVO].self, from: value!)
                        self.calendar.reloadData()
                    case "etc":
                        self.etcs = try jsonDecoder.decode([EtcVO].self, from: value!)
                        self.calendar.reloadData()
                    default:
                        print("error")
                    }
                    self.checkCount += 1
                    self.checkDataSet()
                } catch {
                    print("json_decoder_error")
                }
            case .failure(_):
                let alert = UIAlertController(title: "서버 접속 실패", message: "인터넷 연결 상태를 확인해주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default) {(action) in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
    
    func checkDataSet() {
        if checkCount == 6 {
            self.indicatorView.isHidden = true
            self.indicator.stopAnimating()
        }
    }
    
    //MARK:- 캘린더 셋팅
    //MARK: 달력 개월 넘기기
    //달력의 현재 표시된 연도와 달 출력
    func moveDate(type: Int) -> Date {
        let cal = Calendar.current
        let moveDate = cal.date(byAdding: .month, value: type, to: calendar.currentPage)
        let year = cal.component(.year, from: moveDate!)
        let month = cal.component(.month, from: moveDate!)
        self.monthLabel.text = "\(year).\(month)"

        return moveDate!
    }
    
    @IBAction func todayButtonClick(_ sender: UIButton) {
        self.calendar.setCurrentPage(Date(), animated: true)
    }

    //달력 넘길 때마다 네비게이션 컨트롤러 변경
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.calendar.setCurrentPage(moveDate(type: 0), animated: true)
    }
    
    //선택한 날짜의 배경 색상 지정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return .clear
    }
    
    //선택한 날짜의 텍스트 색상 지정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return .black
    }

    //MARK: 달력의 각 셀에 데이터 표시 (custom cell)
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "calendarCell", for: date, at: position) as! CalendarCollectionViewCell
        
        //날짜 표시
        let cal = Calendar.current
        let cellYear = cal.component(.year, from: date)
        let cellMonth = cal.component(.month, from: date)
        let cellDay = cal.component(.day, from: date)
        let cellWeekday = cal.component(.weekday, from: date)
//        let currentYear = cal.component(.year, from: calendar.currentPage)
//        let currentMonth = cal.component(.month, from: calendar.currentPage)
        let todayYear = cal.component(.year, from: Date())
        let todayMonth = cal.component(.month, from: Date())
        let todayDay = cal.component(.day, from: Date())
        
        cell.todayButton.isHidden = true
        cell.birthImageView.isHidden = true
        cell.dateLabel.text = String(cellDay)
        
        //달력 데이터 셋팅
        if position.rawValue == 1 {
            
            //날짜 색상 셋팅
            if cellYear == todayYear && cellMonth == todayMonth && cellDay == todayDay {
                cell.todayButton.layer.cornerRadius = 9
                cell.todayButton.isHidden = false
                cell.dateLabel.textColor = .white
            } else if cellWeekday == 1 {
               cell.dateLabel.textColor = .red
                cell.todayButton.isHidden = true
            } else {
                cell.todayButton.isHidden = true
               cell.dateLabel.textColor = .darkGray
            }
            
            //생일 날짜 구하기
            let birthFormatter = DateFormatter()
            birthFormatter.locale = Locale(identifier: "ko")
            birthFormatter.dateFormat = "MM-dd"
            
            if HomeVO.shared.dog != nil && birthFormatter.string(from: date) == birthFormatter.string(from: Common().dateFormatter.date(from: HomeVO.shared.dog.birth ?? "")!) {
                cell.birthImageView.isHidden = false
                cell.todayButton.isHidden = true
            } else {
                cell.birthImageView.isHidden = true
            }
            
            //셀의 날짜
            let dateString = Common().dateFormatter.string(from: date)
            
            //캘린더 리스트 셋팅
            var dayList:[CalendarVO] = []
            cell.listView1.isHidden = true
            cell.listView2.isHidden = true
            cell.listView3.isHidden = true
            cell.listView4.isHidden = true
            cell.listView5.isHidden = true
            cell.listView6.isHidden = true
            cell.addListLabel.isHidden = true
            
            //산책 시간 표시
            var walkMinutes = 0
            var walkDistance: Float = 0.0
            for walk in walks {
                if walk.date == dateString {
                    walkDistance += Float(walk.distance!)!
                    walkMinutes += walk.minutes!
                }
            }

            if walkMinutes > 0 {
                let calendar = CalendarVO()
                calendar.color = "#dd695d"
                calendar.title = "\(String(format: "%.1f", walkDistance as CVarArg))km"
                dayList.append(calendar)
            }
            
            //심장사상충 복용일 나타내기
            var heartDate = false
            for heart in hearts {
                if heart.date == dateString {
                    heartDate = true
                }
            }
            if heartDate {
                let calendar = CalendarVO()
                calendar.color = "#4575b4"
                calendar.title = "심장사상충"
                dayList.append(calendar)
            }

            //목욕일자 나타내기
            var washDate = false
            for wash in washs {
                if wash.date == dateString {
                    washDate = true
                }
            }
            if washDate {
                let calendar = CalendarVO()
                calendar.color = "#fdae61"
                calendar.title = "목욕"
                dayList.append(calendar)
            }

            //몸무게 잰 날짜와 몸무게 나타내기
            var weightKG = ""
            for weight in weights {
                if weight.date == dateString {
                    weightKG = weight.kg!
                }
            }
            if weightKG != "" {
                let calendar = CalendarVO()
                calendar.color = "#65ab84"
                calendar.title = "\(weightKG)kg"
                dayList.append(calendar)
            }

            //지출금액 나타내기
            var moneyDate = false
            var moneyPrices = 0
            for money in moneys {
                if money.date == dateString {
                    moneyDate = true
                    moneyPrices += money.price!
                }
            }
            if moneyDate {
                let calendar = CalendarVO()
                calendar.color = "#5e4fa2"
                calendar.title = Common().DecimalWon(value: Int(moneyPrices))
                dayList.append(calendar)
            }
            
            //기타 내역 나타내기
            for etc in etcs {
                if etc.date == dateString {
                    let calendar = CalendarVO()
                    calendar.color = etc.color!
                    calendar.title = etc.title!
                    dayList.append(calendar)
                }
            }

            func list1() {
                cell.listView1.isHidden = false
                cell.listView1.backgroundColor = UIColor(hexString: dayList[0].color!)
                cell.listLabel1.text = dayList[0].title
            }
            func list2() {
                cell.listView2.isHidden = false
                cell.listView2.backgroundColor = UIColor(hexString: dayList[1].color!)
                cell.listLabel2.text = dayList[1].title
            }
            func list3() {
                cell.listView3.isHidden = false
                cell.listView3.backgroundColor = UIColor(hexString: dayList[2].color!)
                cell.listLabel3.text = dayList[2].title
            }
            func list4() {
                cell.listView4.isHidden = false
                cell.listView4.backgroundColor = UIColor(hexString: dayList[3].color!)
                cell.listLabel4.text = dayList[3].title
            }
            func list5() {
                cell.listView5.isHidden = false
                cell.listView5.backgroundColor = UIColor(hexString: dayList[4].color!)
                cell.listLabel5.text = dayList[4].title
            }
            func list6() {
                cell.listView6.isHidden = false
                cell.listView6.backgroundColor = UIColor(hexString: dayList[5].color!)
                cell.listLabel6.text = dayList[5].title
            }
            switch dayList.count {
            case 0:
                cell.listView1.isHidden = true
                cell.listView2.isHidden = true
                cell.listView3.isHidden = true
                cell.listView4.isHidden = true
                cell.listView5.isHidden = true
                cell.listView6.isHidden = true
                cell.addListLabel.isHidden = true
            case 1:
                list1()
            case 2:
                list1()
                list2()
            case 3:
                list1()
                list2()
                list3()
            case 4:
                list1()
                list2()
                list3()
                list4()
            case 5:
                list1()
                list2()
                list3()
                list4()
                if calendar.fs_height <= 577 {
                    cell.addListLabel.isHidden = false
                    cell.addListLabel.text = "+1"
                } else {
                    list5()
                }
            case 6:
                list1()
                list2()
                list3()
                list4()
                if calendar.fs_height <= 577 {
                    cell.addListLabel.isHidden = false
                    cell.addListLabel.text = "+2"
                } else if calendar.fs_height <= 700 {
                    list5()
                    cell.addListLabel.isHidden = false
                    cell.addListLabel.text = "+1"
                } else {
                    list5()
                    list6()
                }
            default:
                list1()
                list2()
                list3()
                list4()
                if calendar.fs_height <= 577 {
                    cell.addListLabel.isHidden = false
                    cell.addListLabel.text = "+\(dayList.count - 4)"
                } else if calendar.fs_height <= 700 {
                    list5()
                    cell.addListLabel.isHidden = false
                    cell.addListLabel.text = "+\(dayList.count - 5)"
                } else {
                    list5()
                    list6()
                    cell.addListLabel.isHidden = false
                    cell.addListLabel.text = "+\(dayList.count - 6)"
                }
            }
        } else {
            cell.dateLabel.textColor = .lightGray
            
            cell.listView1.isHidden = true
            cell.listView2.isHidden = true
            cell.listView3.isHidden = true
            cell.listView4.isHidden = true
            cell.listView5.isHidden = true
            cell.listView6.isHidden = true
            cell.addListLabel.isHidden = true
        }
        return cell
    }
    
    //MARK: 캘린더 cell 클릭 이벤트
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if UserDefaults.standard.string(forKey: "dog_id") != nil {
            popOuterView.isHidden = false
            
            let dateString = Common().dateStringFormatter.string(from: date)
            dateLabel.text = dateString
            
            selectedDateString = dateString
            selectedDate = Common().dateFormatter.string(from: date)
            
            selectedWalks = []
            selectedWashs = []
            selectedWeights = []
            selectedHearts = []
            selectedMoneys = []
            selectedEtcs = []
            
            let date1 = Common().dateFormatter.date(from: Common().dateFormatter.string(from: date))!
            let date2 = Common().dateFormatter.date(from: Common().dateFormatter.string(from: Date()))!
            if date1 > date2 {
                self.insertWalkButton.isHidden = true
                self.insertWashButton.isHidden = true
                self.insertWeightButton.isHidden = true
                self.insertHeartButton.isHidden = true
                self.insertMoneyButton.isHidden = true
                
                for etc in etcs {
                    if etc.date == Common().dateFormatter.string(from: date) {
                        selectedEtcs.append(etc)
                    }
                }
            } else {
                self.insertWalkButton.isHidden = false
                self.insertWashButton.isHidden = false
                self.insertWeightButton.isHidden = false
                self.insertHeartButton.isHidden = false
                self.insertMoneyButton.isHidden = false
                
                //전체 데이터중에 선택한 날짜에 해당하는 데이터만 리스트로 셋팅
                for walk in walks {
                    if walk.date == Common().dateFormatter.string(from: date) {
                        selectedWalks.append(walk)
                    }
                }
                for wash in washs {
                    if wash.date == Common().dateFormatter.string(from: date) {
                        selectedWashs.append(wash)
                        self.insertWashButton.isHidden = true
                    }
                }
                for weight in weights {
                    if weight.date == Common().dateFormatter.string(from: date) {
                        selectedWeights.append(weight)
                        self.insertWeightButton.isHidden = true
                    }
                }
                for heart in hearts {
                    if heart.date == Common().dateFormatter.string(from: date) {
                        selectedHearts.append(heart)
                        self.insertHeartButton.isHidden = true
                    }
                }
                for money in moneys {
                    if money.date == Common().dateFormatter.string(from: date) {
                        selectedMoneys.append(money)
                    }
                }
                for etc in etcs {
                    if etc.date == Common().dateFormatter.string(from: date) {
                        selectedEtcs.append(etc)
                    }
                }
            }
            tableView.reloadData()
        }
    }
    
    //MARK:- 테이블 뷰 셋팅
    func numberOfSections(in tableView: UITableView) -> Int {
        //섹션 나누기
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CalendarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CalendarTableViewCell
        
        switch indexPath.section {
        case 0:
            //산책
            cell.colorView.backgroundColor = Common().red
            cell.label.text = "\(selectedWalks[indexPath.row].time!) \(selectedWalks[indexPath.row].distance!)km \(String(selectedWalks[indexPath.row].minutes!))분 산책"
        case 1:
            //목욕
            cell.colorView.backgroundColor = Common().yellow
            cell.label.text = "목욕했어요"
        case 2:
            //몸무게
            cell.colorView.backgroundColor = Common().green
            cell.label.text = "몸무게 \(selectedWeights[indexPath.row].kg ?? "")kg"
        case 3:
            //심장사상충
            cell.colorView.backgroundColor = Common().blue
            cell.label.text = "심장사상충 예방일"
        case 4:
            //지출
            var field = ""
            switch selectedMoneys[indexPath.row].type {
            case 1:
                field = "사료/간식"
            case 2:
                field = "장난감"
            case 3:
                field = "병원"
            case 4:
                field = "미용/의류"
            case 5:
                field = "기타"
            default:
                print()
            }
            
            cell.colorView.backgroundColor = Common().purple
            cell.label.text = "(\(field)) \(Common().DecimalWon(value: selectedMoneys[indexPath.row].price!)) \(selectedMoneys[indexPath.row].item ?? "")"
        case 5:
            //기타 일정
            cell.colorView.backgroundColor = UIColor(hexString: selectedEtcs[indexPath.row].color!)
            cell.label.text = "(" + selectedEtcs[indexPath.row].title! + ") " + selectedEtcs[indexPath.row].content!
        default:
            print("error")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = (selectedWalks.count + selectedWashs.count + selectedWeights.count + selectedHearts.count + selectedMoneys.count + selectedEtcs.count)
        
        if cnt == 0 {
            tableHeight.constant = 0
        } else {
            tableHeight.constant = 170
        }
        
        switch section {
        case 0:
            return selectedWalks.count
        case 1:
            return selectedWashs.count
        case 2:
            return selectedWeights.count
        case 3:
            return selectedHearts.count
        case 4:
            return selectedMoneys.count
        case 5:
            return selectedEtcs.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //셀 터치했을 때 배경 없애기
        if let cell = tableView.cellForRow(at: indexPath){
            cell.selectionStyle = .none
        }
        
        //클릭한 항목
        var title = ""
        switch indexPath.section {
        case 0:
            //산책
            title = "\(selectedWalks[indexPath.row].time!) \(selectedWalks[indexPath.row].distance!)km \(String(selectedWalks[indexPath.row].minutes!))분 산책"
        case 1:
            //목욕
            title = "목욕했어요"
        case 2:
            //몸무게
            title = "몸무게 \(selectedWeights[indexPath.row].kg ?? "")kg"
        case 3:
            //심장사상충
            title = "심장사상충 예방일"
        case 4:
            //지출
            var field = ""
            switch selectedMoneys[indexPath.row].type {
            case 1:
                field = "사료/간식"
            case 2:
                field = "장난감"
            case 3:
                field = "병원"
            case 4:
                field = "미용/의류"
            case 5:
                field = "기타"
            default:
                print()
            }
            title = "(\(field)) \(Common().DecimalWon(value: selectedMoneys[indexPath.row].price!)) \(selectedMoneys[indexPath.row].item ?? "")"
        case 5:
            //기타 일정
            title = "(" + selectedEtcs[indexPath.row].title! + ") " + selectedEtcs[indexPath.row].content!
        default:
            print("error")
        }
        
        //셀 터치하면 수정, 삭제 나타내기
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        //복사하기
        let copyAction = UIAlertAction(title: "복사하기", style: .default) {
            (action) in
            switch indexPath.section {
            case 0:
                //산책
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "walkUpdatePopUpViewController")as! WalkUpdatePopUpViewController
                vc.type = 1
                vc.date = self.selectedDate
                vc.dateString = self.selectedDateString
                vc.selectedWalk = self.selectedWalks[indexPath.row]
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            case 4:
                //지출
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "moneyUpdatePopUpViewController")as! MoneyUpdatePopUpViewController
                vc.type = 1
                vc.date = self.selectedDate
                vc.dateString = self.selectedDateString
                vc.selectedMoney = self.selectedMoneys[indexPath.row]
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            case 5:
                //기타
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "etcUpdatePopUpViewController")as! EtcUpdatePopUpViewController
                vc.type = 1
                vc.date = self.selectedDate
                vc.dateString = self.selectedDateString
                vc.selectedEtc = self.selectedEtcs[indexPath.row]
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            default:
                print("error")
            }
        }
        //수정하기
        let editAction = UIAlertAction(title: "수정하기", style: .default) {
            (action) in
            switch indexPath.section {
            case 0:
                //산책
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "walkUpdatePopUpViewController")as! WalkUpdatePopUpViewController
                vc.type = 2
                vc.date = self.selectedDate
                vc.dateString = self.selectedDateString
                vc.selectedWalk = self.selectedWalks[indexPath.row]
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
//                self.navigationController?.pushViewController(nextView, animated: false)
            case 2:
                //몸무게
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "weightUpdateViewController")as! WeightUpdateViewController
                vc.date = self.selectedDate
                vc.dateString = self.selectedDateString
                vc.selectedWeight = self.selectedWeights[indexPath.row]
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            case 4:
                //지출
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "moneyUpdatePopUpViewController")as! MoneyUpdatePopUpViewController
                vc.type = 2
                vc.date = self.selectedDate
                vc.dateString = self.selectedDateString
                vc.selectedMoney = self.selectedMoneys[indexPath.row]
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            case 5:
                //기타
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "etcUpdatePopUpViewController")as! EtcUpdatePopUpViewController
                vc.type = 2
                vc.date = self.selectedDate
                vc.dateString = self.selectedDateString
                vc.selectedEtc = self.selectedEtcs[indexPath.row]
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            default:
                print("error")
            }
        }
        //삭제하기
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) {
            (action) in
            let alert = UIAlertController(title: "정보 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let okAction = UIAlertAction(title: "삭제", style: .destructive) {
                (action) in
                switch indexPath.section {
                case 0:
                    //산책
                    self.calendarDelete(type: "walk", id: self.selectedWalks[indexPath.row].id!, index: indexPath.row)
                case 1:
                    //목욕
                    self.calendarDelete(type: "wash", id: self.selectedWashs[indexPath.row].id!, index: indexPath.row)
                case 2:
                    //몸무게
                    self.calendarDelete(type: "weight", id: self.selectedWeights[indexPath.row].id!, index: indexPath.row)
                case 3:
                    //심장사상충
                    self.calendarDelete(type: "heart", id: self.selectedHearts[indexPath.row].id!, index: indexPath.row)
                case 4:
                    //지출
                    self.calendarDelete(type: "money", id: self.selectedMoneys[indexPath.row].id!, index: indexPath.row)
                case 5:
                    //기타
                    self.calendarDelete(type: "etc", id: self.selectedEtcs[indexPath.row].id!, index: indexPath.row)
                default:
                    print("error")
                }
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        alert.title = title
        alert.addAction(cancelAction)
        if (indexPath.section != 1 && indexPath.section != 2 && indexPath.section != 3) {
            alert.addAction(copyAction)
        }
        if (indexPath.section != 1 && indexPath.section != 3) {
            alert.addAction(editAction)
        }
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: 서버에서 날짜 데이터 삭제하는 함수
    func calendarDelete(type: String, id: Int, index: Int) {
        let URL = Common().baseURL+"/diary/\(type)/\(id)"
        let alamo = AF.request(URL, method: .delete).validate(statusCode: 200..<300)
        alamo.response { response in
            switch response.result {
            case .success(_):
                switch type {
                case "walk":
                    self.calendarData(type: "walk")
                    self.selectedWalks.remove(at: index)
                    self.tableView.reloadData()
                    self.loadHomeData()
                case "wash":
                    self.calendarData(type: "wash")
                    self.selectedWashs.remove(at: index)
                    self.tableView.reloadData()
                    self.loadHomeData()
                case "weight":
                    self.calendarData(type: "weight")
                    self.selectedWeights.remove(at: index)
                    self.tableView.reloadData()
                    self.loadHomeData()
                case "heart":
                    self.calendarData(type: "heart")
                    self.selectedHearts.remove(at: index)
                    self.tableView.reloadData()
                    self.loadHomeData()
                case "money":
                    self.calendarData(type: "money")
                    self.selectedMoneys.remove(at: index)
                    self.tableView.reloadData()
                    self.loadHomeData()
                case "etc":
                    self.calendarData(type: "etc")
                    self.selectedEtcs.remove(at: index)
                    self.tableView.reloadData()
                    self.loadHomeData()
                default:
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK:- PopUp View 이동
    //MARK: 산책하기 버튼 클릭
    @IBAction func walkButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "walkDirectPopUpViewController")as! WalkDirectPopUpViewController
        vc.date = selectedDate
        vc.dateString = selectedDateString
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    //MARK: 목욕하기 버튼 클릭
    @IBAction func washButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "washPopUpView")as! WashPopUpViewController
        vc.date = selectedDate
        vc.dateString = selectedDateString
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    //MARK: 몸무게 버튼 클릭
    @IBAction func weightButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "weightPopUpView")as! WeightPopUpViewController
        vc.date = selectedDate
        vc.dateString = selectedDateString
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    //MARK: 심장사상충 버튼 클릭
    @IBAction func heartButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "heartPopUpView")as! HeartPopUpViewController
        vc.date = selectedDate
        vc.dateString = selectedDateString
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    //MARK: 지출하기 버튼 클릭
    @IBAction func moneyButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "moneyPopUpView")as! MoneyPopUpViewController
        vc.date = selectedDate
        vc.dateString = selectedDateString
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    //MARK: 기타 입력 버튼 클릭
    @IBAction func etcButtonClick(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "etcPopUpView")as! EtcPopUpViewController
        vc.date = selectedDate
        vc.dateString = selectedDateString
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    //MARK:- 팝업 끄기 버튼 클릭
    @IBAction func cancelPopupButtonClick(_ sender: UIButton) {
        self.popOuterView.isHidden = true
        tableView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    //MARK:- 뒤로가기 버튼 클릭
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        }
    }
}
