//
//  GraphDateTitleFormatter.swift
//  MyDietDiaryApp
//
//  Created by TEN MATSUMOTO on 14/9/2022.
//

import Foundation
import Charts

//グラフのX軸に表示する文字列を定義する
class GraphDateTitleFormatter: IndexAxisValueFormatter {
    //X軸のラベルに日付を表示するために日付データを渡す
    var dateList: [Date] = []
    //X軸のラベルに表示するラベルを返す処理
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        //"dateList"aの要素数が”index”の値よりも大きくない場合は対象データが存在しないため空文字を返す
        guard dateList.count > index else { return "" }
        let targetDate = dateList[index]
        //日付を文字列に変換する処理
        let formatter = DateFormatter()
        //"DateFormatter"に日付フォーマット用の文字列を代入
        let dateFormatString = "M/d"
        formatter.dateFormat = dateFormatString
        //"DateFormatter"の"string"methodに対象となる日付を渡して文字列化し、戻り値で返す
        return formatter.string(from: targetDate)
    }
}
