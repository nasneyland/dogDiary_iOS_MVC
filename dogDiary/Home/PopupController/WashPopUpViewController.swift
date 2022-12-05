//
//  WashPopUpViewController.swift
//  dogDiary
//
//  Created by najin on 2020/10/30.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import GoogleMobileAds

class WashPopUpViewController: UIViewController, GADInterstitialDelegate {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var date: String!
    var dateString: String?
    var indicator: NVActivityIndicatorView!
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //날짜 셋팅
        if date == Common().dateFormatter.string(from: Date()) {
            dateLabel.text = "오늘"
        } else {
            dateLabel.text = dateString
        }
    }
    
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK:- 등록버튼 눌렀을 때
    @IBAction func insertButtonClick(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicator.startAnimating()
        if MemberVO.shared.grade! == 1 {
            if self.interstitial.isReady {
                self.interstitial.present(fromRootViewController: self)
            } else {
                self.washInsert()
            }
        } else {
            self.washInsert()
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        washInsert()
    }
    
    func washInsert() {
        let URL = Common().baseURL+"/diary/wash"
        let wash = WashVO()
        wash.dog = Int(UserDefaults.standard.string(forKey: "dog_id")!)
        wash.date = self.date
        let alamo = AF.request(URL, method: .post, parameters: wash, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
        alamo.responseDecodable(of: HomeVO.self) { (response) in
            guard let home = response.value else {
                self.present(Common().errorAlert(), animated: false, completion: nil)
                self.indicatorView.isHidden = true
                self.indicator.stopAnimating()
                return
            }
            HomeVO.shared.lastWashDay = home.lastWashDay
            self.dismiss(animated: false, completion: nil)
        }
    }
}
