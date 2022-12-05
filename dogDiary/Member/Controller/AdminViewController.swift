//
//  AdminViewController.swift
//  dogDiary
//
//  Created by najin on 2021/03/02.
//

import Alamofire
import UIKit

class AdminViewController: UIViewController {
    
    @IBOutlet weak var memberTextField: UITextField!
    @IBOutlet weak var goHomeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        //사용자 테스트
        UserDefaults.standard.removeObject(forKey: "id")
        UserDefaults.standard.removeObject(forKey: "dog_id")
        
        Common().buttonEnableStyle(button: goHomeButton)
    }
    
    @IBAction func goHomeButtonClick(_ sender: UIButton) {
        var dog = "401"
        if memberTextField.text?.count != 0 {
            dog = memberTextField.text!
        }
        UserDefaults.standard.setValue(dog, forKey: "dog_id")
        let URL2 = Common().baseURL+"/diary/home/" + dog
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
    }
}
