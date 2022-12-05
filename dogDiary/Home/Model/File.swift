//
//  File.swift
//  dogDiary
//
//  Created by najin on 2020/12/09.
//

import Foundation

class DogVO : Decodable, Encodable {
    static let shared: DogVO = DogVO()
    
    var id: Int?
    var name: String?
    var gender: Int?
    var birth: String?
    var image: String?
    
    var lastWashDay: String?
    var lastWeightDay: String?
    var lastWeight: String?
    var lastHeartDay: String?
    var totalMoney: String?
    var totalWalk: Int?
    var countWalk: Int?
}
