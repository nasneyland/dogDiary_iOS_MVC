//
//  DefaultHomeViewController.swift
//  dogDiary
//
//  Created by najin on 2020/12/09.
//

import UIKit

class DefaultHomeViewController: UIViewController {

    @IBOutlet weak var insertDogButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        insertDogButton.layer.cornerRadius = 20
    }
    
    @IBAction func insertDogButtonClick(_ sender: UIButton) {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "joinViewController")
        self.navigationController?.pushViewController(nextView!, animated: false)
    }
}
