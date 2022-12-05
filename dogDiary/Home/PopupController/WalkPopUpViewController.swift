//
//  WalkPopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2020/10/30.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import NMapsMap

class WalkPopUpViewController: UIViewController, CLLocationManagerDelegate, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate {

    //MARK:- 프로퍼티 선언 및 초기화
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var locationButton: NMFLocationButton!
    @IBOutlet weak var timerInfoStackView: UIStackView!
    @IBOutlet weak var timerTimeLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var walkingView: NVActivityIndicatorView!
    @IBOutlet weak var insertPopOuterView: UIView!
    @IBOutlet weak var insertPopUpView: UIView!
    @IBOutlet weak var popUpMinutesLabel: UILabel!
    @IBOutlet weak var popUpDistanceLabel: UILabel!
    @IBOutlet weak var popUpTimeLabel: UILabel!
    @IBOutlet weak var goMapButton: UIButton!
    @IBOutlet weak var goHomeButton: UIButton!
    
    //timer
    var startTime: Date?
    var timer: Timer?
    var playTimer = false
    
    var pathOverlay = NMFPath()
    var coords: [NMGLatLng] = []
    var currentLocation: NMGLatLng!
    var totalDistance = 0
    
    //위치정보제공 확인받기
    private lazy var locationManager: CLLocationManager = {
      let manager = CLLocationManager()
      manager.desiredAccuracy = kCLLocationAccuracyBest
      manager.delegate = self
      manager.requestAlwaysAuthorization()
      if #available(iOS 9, *) {
        manager.allowsBackgroundLocationUpdates = true
      }
      return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerInfoStackView.layer.cornerRadius = 10
        timerInfoStackView.layer.borderWidth = 1
        timerInfoStackView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        walkingView.type = .lineScalePulseOutRapid
        walkingView.color = Common().blue
        
        //popupview setting
        insertPopOuterView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        insertPopUpView.layer.cornerRadius = 10
        goHomeButton.layer.cornerRadius = 5
        goHomeButton.backgroundColor = Common().red
        goHomeButton.setTitleColor(.white, for: .normal)
        goMapButton.layer.cornerRadius = 5
        goMapButton.backgroundColor = .gray
        goMapButton.setTitleColor(.white, for: .normal)
        insertPopOuterView.isHidden = true
        
        //네이버지도 초기화
        naverMapView.mapView.touchDelegate = self
        naverMapView.showScaleBar = false
        naverMapView.showZoomControls = false
        naverMapView.showLocationButton = false
        naverMapView.showCompass = false
        naverMapView.mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        naverMapView.bringSubviewToFront(locationButton)
        locationButton.mapView = naverMapView.mapView
        //카메라 위치 사용 선언
        naverMapView.mapView.addCameraDelegate(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        //사용자의 현재위치로 기본위치 설정
        let coor = locationManager.location?.coordinate
        let latitude = coor?.latitude
        let longitude = coor?.longitude
        //위치정보 제공을 하지 않았으면
        if coor != nil {
            naverMapView.mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: latitude!, lng: longitude!), zoom: 16, tilt: 0, heading: 0)))
            currentLocation = NMGLatLng(lat: latitude!, lng: longitude!)
            coords.append(currentLocation)
        } else {
            naverMapView.mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: 37.542578658412445, lng: 127.03804799945983), zoom: 16, tilt: 0, heading: 0)))
        }
    }
    
    //MARK:- 사용자 위치 업데이트(백그라운드)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startTime != nil {
            let coor = locationManager.location?.coordinate
            let latitude = coor?.latitude
            let longitude = coor?.longitude
            var distance: Double = 0
            if currentLocation != nil {
                distance = NMGLatLng(lat: latitude!, lng: longitude!).distance(to: currentLocation)
            } else {
                currentLocation = NMGLatLng(lat: latitude!, lng: longitude!)
            }
            if distance > 20 {
                totalDistance += Int(distance)
                totalDistanceLabel.text = "\(String(format: "%.1f", Float(totalDistance) / 1000.0))km"
                
                currentLocation = NMGLatLng(lat: latitude!, lng: longitude!)
                coords.append(currentLocation)
                
                if let pathOverlay = NMFPath(points: coords) {
                    pathOverlay.width = 12
                    pathOverlay.outlineWidth = 2
                    pathOverlay.color = Common().red
                    pathOverlay.outlineColor = UIColor.white
                    let image = UIImage(named: "dog_foot")
                    pathOverlay.patternIcon = NMFOverlayImage(image: image!.resize(12, 12)!)
                    pathOverlay.mapView = naverMapView.mapView
                }
            }
        }
    }
    
    //MARK:- 타이머 모드
    @objc func onTimerUpdate() {
        let interval = Int(Date().timeIntervalSince(startTime!))

        let hours = (interval % 3600) / 3600
        let minutes = (interval % 3600) / 60
        let seconds = (interval % 3600) % 60

        let hour = hours > 9 ? "\(hours)" : "0\(hours)"
        let minute = Int(minutes) > 9 ? "\(minutes)" : "0\(minutes)"
        let second = Int(seconds) > 9 ? "\(seconds)" : "0\(seconds)"

        timerTimeLabel.text = "\(hour):\(minute):\(second)"
    }
    
    //MARK:- 닫기버튼 눌렀을 때
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        if startTime == nil {
            self.dismiss(animated: false, completion: nil)
        } else {
            let alter = UIAlertController(title: "팝업을 종료하시겠습니까?", message: "화면을 벗어나면 산책정보가 리셋됩니다.", preferredStyle: UIAlertController.Style.alert)
            let logOkAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){
                (action: UIAlertAction) in
                self.timer?.invalidate()
                self.dismiss(animated: false, completion: nil)
            }
            let logNoAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.destructive)
            alter.addAction(logNoAction)
            alter.addAction(logOkAction)
            self.present(alter, animated: true, completion: nil)
        }
    }
    
    //MARK:- 산책버튼 눌렀을 때
    @IBAction func insertButtonClick(_ sender: UIButton) {
        
        let coor = locationManager.location?.coordinate
        if coor == nil {
            //위치정보 제공을 하지 않았으면
            let alter = UIAlertController(title: "이 기능을 사용하시려면 위치정보 제공에 동의해주셔야 합니다.\n설정화면으로 이동하시겠습니까?", message: "직접입력은 캘린더에서만 가능합니다.", preferredStyle: UIAlertController.Style.alert)
            let logOkAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){
                (action: UIAlertAction) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(NSURL(string:UIApplication.openSettingsURLString)! as URL)
                } else {
                    UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
                }
            }
            let logNoAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.destructive)
            alter.addAction(logNoAction)
            alter.addAction(logOkAction)
            self.present(alter, animated: true, completion: nil)
        } else {
            //위치정보 제공 동의를 했으면
            if startTime == nil {
                //산책시작
                walkingView.startAnimating()
                startTime = Date()
                walkButton.setTitle("산책종료", for: .normal)
                
                //위치정보 업데이트 시작
                locationManager.startUpdatingLocation()
                
                //timer 시작
                self.timer?.invalidate()
                self.timer = nil
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.onTimerUpdate), userInfo: nil, repeats: true)
            } else {
                let interval = Int(Date().timeIntervalSince(startTime!))
                let distance = String(format: "%.1f", Float(totalDistance) / 1000.0)
                if (interval / 60) < 5 || (Float(totalDistance) / 1000.0) < 0.1 {
                    //산책정보가 충분하지 않은 경우
                    let alert = UIAlertController(title: "산책 정보가 부족합니다.", message: "5분 이상, 0.1km 이상의 산책이 필요합니다.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    present(alert, animated: false, completion: nil)
                } else {
                    //산책종료
                    walkingView.stopAnimating()
                    walkingView.isHidden = true
                    timer?.invalidate()

                    //alamofire 산책정보 입력하기
                    let URL = Common().baseURL+"/diary/walk"
                    let walk = WalkVO()
                    walk.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
                    walk.date = Common().dateFormatter.string(from: Date())
                    walk.time = Common().timeFormatter(date: startTime!)
                    walk.minutes = (interval / 60)
                    walk.distance = distance
                    let alamo = AF.request(URL, method: .post, parameters: walk, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
                    alamo.responseDecodable(of: HomeVO.self) { (response) in
                        guard let home = response.value else {
                            self.present(Common().errorAlert(), animated: false, completion: nil)
                            return
                        }
                        self.insertPopOuterView.isHidden = false
                        self.popUpMinutesLabel.text = "\(interval / 60)분"
                        self.popUpDistanceLabel.text = "\(distance)km"
                        self.popUpTimeLabel.text = Common().timeFormatter(date: self.startTime!)

                        HomeVO.shared.walkList = home.walkList
                        self.walkButton.isEnabled = false
                        self.startTime = nil
                    }
                }
            }
        }
    }
    
    @IBAction func clickGoMapButton(_ sender: UIButton) {
        self.insertPopOuterView.isHidden = true
    }
    
    @IBAction func clickGoHomeButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}
