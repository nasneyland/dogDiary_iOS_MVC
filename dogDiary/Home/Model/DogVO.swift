//
//  DogVO.swift
//  dogDiary
//
//  Created by najin on 2020/12/09.
//

import Foundation

class DogVO : Decodable, Encodable {
    static let shared: DogVO = DogVO()
    
    var id: Int?
    var member: Int?
    var name: String?
    var gender: Int?
    var birth: String?
    var image: String?
}
