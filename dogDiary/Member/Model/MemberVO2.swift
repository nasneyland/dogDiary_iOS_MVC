import Foundation

class MemberVO : Decodable {
    static let shared = MemberVO()
    
    var id: Int?
    var nickname: String?
    var phone: String?
    var mail: String?
}



