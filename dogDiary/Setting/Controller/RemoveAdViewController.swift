//
//  RemoveAdViewController.swift
//  dogDiary
//
//  Created by najin on 2021/03/26.
//

import UIKit

class RemoveAdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func payButtonClick(_ sender: UIButton) {
//        InAppProducts.store.buyProduct(product)
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    public struct InAppProducts {
        public static let product = "(인앱 Product ID)"
        private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts.product]
        public static let store = IAPHelper(productIds: InAppProducts.productIdentifiers)
    }
}
