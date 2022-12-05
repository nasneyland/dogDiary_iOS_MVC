//
//  SettingViewController.swift
//  dogDiary
//
//  Created by najin on 2020/11/15.
//

import UIKit
import Alamofire

class SettingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
