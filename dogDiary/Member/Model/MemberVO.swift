//
//  MemberVO.swift
//  dogDiary
//
//  Created by najin on 2020/10/28.
//

import Foundation

class MemberVO : Decodable, Encodable {
    static let shared: MemberVO = MemberVO()
    
    var id: Int?
    var phone: String?
    var mail: String?
    var grade: Int?
    
    var dogList: [DogVO]?
}

struct Auth : Decodable, Encodable {
    let authNumber : Int
    let id : Int
}
