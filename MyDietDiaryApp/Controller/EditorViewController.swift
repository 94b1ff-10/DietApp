//
//  EditorViewController.swift
//  MyDietDiaryApp
//
//  Created by TEN MATSUMOTO on 10/9/2022.
//

import UIKit
import RealmSwift

//日付を変更した際にCalendarViewにrecordデータが反映されるように"delegate"を使い通知する処理を作る
protocol EditorViewControllerDelegate {
    func recordUpdate()
}

class EditorViewController: UIViewController {
    @IBOutlet weak var inputWeightTextField: UITextField!
    @IBOutlet weak var inputDateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveButton(_ sender: UIButton) {
        saveRecord()
    }
    @IBAction func deleteButton(_ sender: UIButton) {
        deleteRecord()
    }
    
    var record = WeightRecord()
    var delegate: EditorViewControllerDelegate?
    
    //TextViewで日付を入力するピッカーを定義
    //コンピューテッドプロパティ
    var datePicker: UIDatePicker {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = .current //現在地のタイムゾーン
        datePicker.preferredDatePickerStyle = .wheels //".wheels"はドラムロールのようなUIを表示する
        datePicker.locale = Locale(identifier: "en-US") //"ja-JP"は日本の年月日表記, "en-US"は英語表記
        datePicker.date = record.date
        datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged) //Pickerの値が変更された際に任意のmethodを実行する
        return datePicker
    }
    
    //キーボード上部に設置する閉じるボタン(toolBarに定義)は"DateText", "WeightText"のどちらでも使用したいため、ツールバーのmethodをコンピューテッドプロパティで定義し、class内で共通利用できるようにする
    var toolBar: UIToolbar {
        //キーボードに追加するツールバーの座標とサイズを定義
        let toolBarRect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35)
        //上をインスタンス化
        let toolBar = UIToolbar(frame: toolBarRect)
        //閉じるボタンを"UIBarButtonItem"classとしてインスタンス化し、"didTapDone"methodをアクション引数として渡している
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        //閉じるボタンを"toolBar"の"setItem"methodで適用
        toolBar.setItems([doneItem], animated: true)
        return toolBar
    }
    
    //日付の値を文字列に変換する処理→ "dateFormatter"を使う
    var dateFormatter: DateFormatter {
        let dateFormatt = DateFormatter()
        dateFormatt.dateStyle = .long
        dateFormatt.timeZone = .current
        dateFormatt.locale = Locale(identifier: "en-US")
        return dateFormatt
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWeightTextField()
        configureDateTextField()
        configureSaveButton()
    }
    
    @objc func didTapDone() {
        //キーボードを閉じるためのmethod
        view.endEditing(true)
    }
    
    //キーボードの閉じるボタンを追加するmethod
    func configureWeightTextField() {
        //"toolBar.setItems"のプロパティを代入することでキーボードに閉じるボタンを追加している
        inputWeightTextField.inputAccessoryView = toolBar
        //体重を画面に表示させる処理
        inputWeightTextField.text = String(record.weight)
    }
    
    func configureDateTextField() {
        inputDateTextField.inputView = datePicker
        inputDateTextField.inputAccessoryView = toolBar
        inputDateTextField.text = dateFormatter.string(from: record.date)
    }
    
    //"datePicker"で日付が選択された際にも"UITextField"に値が表示されるようにする処理 ("datePicker"にアクションを追加する)
    //このmethodは引数の日付を文字列をしてUITextFieldに表示させる処理を行う
    @objc func didChangeDate(picker: UIDatePicker) {
        inputDateTextField.text = dateFormatter.string(from: picker.date) //ここの"picker" = "datePicker"のこと
    }
    
    func configureSaveButton() {
        saveButton.layer.cornerRadius = 5
    }
    
    //recordデータを上書きしつつRealm上に保存するmethod("Save"ボタンを押した際の働き)
    func saveRecord() {
        let realm = try! Realm() //Realmをインスタンス化
        try! realm.write {
            //"inputDateTextField"に文字列が存在していて且つDateに変換できた場合にのみ"record.date"を更新する処理
            if let dateText = inputDateTextField.text,
               let date = dateFormatter.date(from: dateText) {
                record.date = date
            }
            //"inputWeightTextField"に文字列が存在していて且つDoubleに変換できた場合にのみ"record.date"を更新する処理
            if let weightText = inputWeightTextField.text,
               let weight = Double(weightText) {
                record.weight = weight
            }
            realm.add(record)
        }
        
        //protocol内で書いたdelegateパターンを使って通知する処理(この処理はデータが上書きされた際に実行したいのでここに書く)
        delegate?.recordUpdate()
        
        //Saveボタンを押した後自動で入力画面を閉じる処理
        dismiss(animated: true)
    }
    
    //データを削除する処理("Delete"ボタンを押した際の働き)
    func deleteRecord() {
        //日付を使った処理を行うため"Calendar"classをインスタンス化
        let calendar = Calendar(identifier: .gregorian)
        //recordのDateプロパティを使って日付の削除対象データを0にする
        let startOfDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: record.date)!
        let endOfDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: record.date)!
        //データ検索をするためにRealmをインスタンス化
        let realm = try! Realm()
        //Realmから任意のデータを取得するため、"NSPredicate"を使用し条件検索を行う
        //ここでは削除対象データの日付が"startOfDate"と"endOfDate"の間にある場合にデータを取得している
        let recordList = Array(realm.objects(WeightRecord.self).filter("date BETWEEN {%@, %@}", startOfDate, endOfDate))
        //"forEach"methodを使用して"recordList"の各要素にアクセスし、それぞれの要素データをRealm上から削除する
        recordList.forEach({ record in
            try! realm.write {
                realm.delete(record)
            }
        })
        //データの削除が完了した際に親クラス(CalendarViewController: UIViewController)のカレンダーも更新する処理
        delegate?.recordUpdate()
        //Deleteボタンを押した後自動で入力画面を閉じる処理
        dismiss(animated: true)
    }
}
