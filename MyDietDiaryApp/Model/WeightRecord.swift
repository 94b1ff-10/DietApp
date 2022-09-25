//
//  WeightRecord.swift
//  MyDietDiaryApp
//
//  Created by TEN MATSUMOTO on 11/9/2022.
//

import Foundation
import RealmSwift

class WeightRecord: Object {
    override static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var weight: Double = 0
}
