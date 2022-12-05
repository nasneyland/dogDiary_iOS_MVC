//
//  EtcVO.swift
//  dogDiary
//
//  Created by najin on 2021/02/17.
//

import Foundation

class EtcVO: Decodable, Encodable {
    var id: Int?
    var dog_id: Int?
    var dog: Int?
    var date: String?
    var color: String?
    var title: String?
    var content: String?
}
