//
//  HomeVO.swift
//  dogDiary
//
//  Created by najin on 2020/12/11.
//

import Foundation
import Alamofire

class HomeVO : Decodable, Encodable {
    static let shared: HomeVO = HomeVO()
    
    var dog: DogVO!
    
    var lastWashDay: String?
    var lastWeightDay: String?
    var lastWeight: String?
    var lastHeartDay: String?
    var totalMoney: String?
    
    var walkList: [WalkVO]?
    var weightChart: [WeightVO]?
    var moneyList: [MoneyVO]?
}
