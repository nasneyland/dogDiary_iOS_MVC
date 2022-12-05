//
//  DailyVO.swift
//  dogDiary
//
//  Created by najin on 2020/11/21.
//

import Foundation

class DailyVO : Decodable, Encodable {
    var id: Int?
    var mid: Int?
    var mid_id: Int?
    var date: String?
    var content: String?
    var icon: String?
    var mapx: String?
    var mapy: String?
    var photo: String?
}
