//
//  Walk.swift
//  dogDiary
//
//  Created by najin on 2020/11/01.
//

import Foundation

class WalkVO: Decodable, Encodable {
    var id: Int?
    var dog_id: Int?
    var dog: Int?
    var date: String?
    var time: String?
    var minutes: Int?
    var distance: String?
}
