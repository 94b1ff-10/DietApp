//
//  Date+Extention.swift
//  MyDietDiaryApp
//
//  Created by TEN MATSUMOTO on 12/9/2022.
//

import Foundation

//日付データの比較処理を行う拡張機能を定義
extension Date {
    //"Calendar"クラスを用いることで年月日、時間、秒数、分などの単位で使用する事ができる
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        calendar.locale = Locale(identifier: "en-US")
        return calendar
    }
    
    //Date型の値を任意の時間帯に変更するための処理
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil,
               hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        var comp = DateComponents()
        comp.year = year ?? calendar.component(.year, from: self)
        comp.month = year ?? calendar.component(.month, from: self)
        comp.day = year ?? calendar.component(.day, from: self)
        comp.hour = year ?? calendar.component(.hour, from: self)
        comp.minute = year ?? calendar.component(.minute, from: self)
        comp.second = year ?? calendar.component(.second, from: self)
        return calendar.date(from: comp)!
    }
    
    //下のmethodでは、"CalendarViewController"内でカレンダーにマークを追加する処理を行う際に"isEqualDate"プロパティが同じ日付かどうかを判断するが、その際に全てのDate型の値を参照してしまうため"fixed"methodを用いてhour, minute,secondを0として返すことで異なるDate型の値を比較した際に同一の日付かどうかを判別できる
    var zeroclock: Date {
        return fixed(hour: 0, minute: 0, second: 0)
    }
}
