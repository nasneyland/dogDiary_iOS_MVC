//
//  FaqViewController.swift
//  dogDiary
//
//  Created by najin on 2021/01/04.
//

import UIKit

class FaqViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
