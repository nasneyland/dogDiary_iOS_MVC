//
//  BasicFile.swift
//  dogDiary
//
//  Created by najin on 2020/10/31.
//

import Foundation
import UIKit

class Common {
    let baseURL = "#####"
    
    let mint = UIColor(displayP3Red: 94/255, green: 158/255, blue: 160/255, alpha: 1)
    let darkMint = UIColor(displayP3Red: 55/255, green: 74/255, blue: 93/255, alpha: 1)
    
    let red = UIColor(displayP3Red: 221/255, green: 105/255, blue: 93/255, alpha: 1)
    let yellow = UIColor(displayP3Red: 253/255, green: 174/255, blue: 97/255, alpha: 1)
    let green = UIColor(displayP3Red: 101/255, green: 171/255, blue: 132/255, alpha: 1)
    let blue = UIColor(displayP3Red: 69/255, green: 117/255, blue: 180/255, alpha: 1)
    let purple = UIColor(displayP3Red: 94/255, green: 79/255, blue: 162/255, alpha: 1)
    
    let lightRed = UIColor(displayP3Red: 249/255, green: 155/255, blue: 139/255, alpha: 1)
    let lightYellow = UIColor(displayP3Red: 254/255, green: 197/255, blue: 140/255, alpha: 1)
    let lightGreen = UIColor(displayP3Red: 172/255, green: 220/255, blue: 173/255, alpha: 1)
    let lightBlue = UIColor(displayP3Red: 141/255, green: 172/255, blue: 211/255, alpha: 1)
    let lightPurple = UIColor(displayP3Red: 189/255, green: 182/255, blue: 220/255, alpha: 1)
    
    let genderPink = UIColor(displayP3Red: 213/255, green: 100/255, blue: 124/255, alpha: 1)
    let genderBlue = UIColor(displayP3Red: 40/255, green: 103/255, blue: 160/255, alpha: 1)
    
    let tracker1 = UIColor(displayP3Red: 201/255, green: 221/255, blue: 237/255, alpha: 1)
    let tracker2 = UIColor(displayP3Red: 163/255, green: 192/255, blue: 224/255, alpha: 1)
    let tracker3 = UIColor(displayP3Red: 144/255, green: 172/255, blue: 218/255, alpha: 1)
    let tracker4 = UIColor(displayP3Red: 140/255, green: 158/255, blue: 217/255, alpha: 1)
    let tracker5 = UIColor(displayP3Red: 133/255, green: 138/255, blue: 214/255, alpha: 1)
    
    //반응형 폰트 함수
    func fontStyle(name: String, size: Float) -> UIFont {
        var responsiveSize: CGFloat
        switch size {
        case 22:
            responsiveSize = UIScreen.main.bounds.size.width * 0.075
        case 20:
            responsiveSize = UIScreen.main.bounds.size.width * 0.065
        case 18:
            responsiveSize = UIScreen.main.bounds.size.width * 0.055
        case 16:
            responsiveSize = UIScreen.main.bounds.size.width * 0.045
        case 15:
            responsiveSize = UIScreen.main.bounds.size.width * 0.040
        case 14:
            responsiveSize = UIScreen.main.bounds.size.width * 0.035
        case 12:
            responsiveSize = UIScreen.main.bounds.size.width * 0.025
        default:
            responsiveSize = UIScreen.main.bounds.size.width * 0.01
        }
        return UIFont(name: name, size: responsiveSize)!
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let dateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()
    
    func timeFormatter(date: Date) -> String {
        let formatter = DateFormatter();
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "m"
        if formatter.string(from: date) == "0" {
            formatter.dateFormat = "a h시"
        } else {
            formatter.dateFormat = "a h시 m분"
        }
        formatter.amSymbol = "오전";
        formatter.pmSymbol = "오후";
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func timeDateFormatter(date: String) -> Date {
        
        let dayIdx: String.Index = date.index(date.startIndex, offsetBy: 1)
        var day = String(date[...dayIdx])
        
        let hourIdx = date.firstIndex(of: "시")!
        let startHourIdx: String.Index = date.index(date.startIndex, offsetBy: 3)
        let hour = String(date[startHourIdx..<hourIdx])
        
        var minutes = "0"
        if date.contains("분") {
            let endMinutesIdx: String.Index = date.index(date.endIndex, offsetBy: -1)
            minutes = String(date[hourIdx..<endMinutesIdx])
            let startMinutesIdx: String.Index = minutes.index(minutes.startIndex, offsetBy: 2)
            minutes = String(minutes[startMinutesIdx...])
        }
        
        if(day == "오전") {
            day = "am"
        } else {
            day = "pm"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h:m"
        let dateResult = dateFormatter.date(from: "\(day) \(hour):\(minutes)")
        
        return dateResult!
    }
    
    func DecimalWon(value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: value))! + "원"
        
        return result
    }
    
    //MARK: 둥근 버튼 활성화 함수
    func buttonEnableStyle(button: UIButton){
        button.backgroundColor = self.mint
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = true
        button.layer.cornerRadius = 5
    }
    
    //MARK: 둥근 버튼 비활성화 함수
    func buttonDisableStyle(button: UIButton){
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 5
    }
    
    //에러 alert
    func errorAlert() -> UIAlertController{
        let alert = UIAlertController(title: "서버 접속 실패", message: "인터넷 연결 상태를 확인해주세요.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
    
    //준비중 alert
    func readyAlert() -> UIAlertController{
        let alert = UIAlertController(title: "준비중입니다.", message: "다음 업데이트까지 기다려주세요:)", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
}
