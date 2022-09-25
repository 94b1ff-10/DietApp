//
//  GraphViewController.swift
//  MyDietDiaryApp
//
//  Created by TEN MATSUMOTO on 9/9/2022.
//

import UIKit
import Charts
import RealmSwift

class GraphViewController: UIViewController {
    @IBOutlet weak var graphView: LineChartView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    
    var recordList: [WeightRecord] = []
    
    //期間を入力する2つの"Textfield"ではDatePickerを使用したいため既に"EditorViewController"で定義してあるプロパティをコピペ
    var datePicker: UIDatePicker {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = .current
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "en-US")
        return datePicker
    }
    
    //日付を文字列に変換する処理。これも"EditorViewController"に既にあるものをコピペ
    var dateFormatter: DateFormatter {
        let dateFormatt = DateFormatter()
        dateFormatt.dateStyle = .long
        dateFormatt.timeZone = .current
        dateFormatt.locale = Locale(identifier: "en-US")
        return dateFormatt
    }
    
    //2つの"Textfield"の入力ツールを閉じるボタンを設置。これも"EditorViewController"からコピペ
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setRecord()
        updateGraph()
        configureGraph()
        configureTextField()
    }
    
    //グラフを表示するためにRealmからデータを取得する処理
    func setRecord() {
        //Realmをインスタンス化
        let realm = try! Realm()
        //WeightRecordの全データを取得しresultにてインスタンス化
        var result = Array(realm.objects(WeightRecord.self))
        //realmから取得したデータを日付が若い順に並び替える処理(配列内のデータを並び替える"sort"methodを使う)
        result.sort(by: { $0.date < $1.date }) // ここで小さいdateを表している"$0.date"が"$1.date"より小さかった場合はBool型のtrueで返す
        //resultをrecordListに代入
        recordList = result
        //値が変更された2つの"Textfield"に合わせてグラフの表示内容にも変更を加える処理
        //最初の文では"if"を使い、2つの"Textfield"に表示されている文字列を取得する
        if let startDateText = startDateTextField.text, // ","はこの文のように使うと複数のプロパティを定義できる(改行も可)
           let endDateText = endDateTextField.text,
           //その文字列を"Date"型に変換
           let startDate = dateFormatter.date(from: startDateText),
           let endDate = dateFormatter.date(from: endDateText) {
            //Realmからデータを取得する際に".filter"で検索条件を指定。ここでは"NSPredicate"の"BETWEEN"を使用し条件検索を行う
            var filteredRecord = Array(realm.objects(WeightRecord.self)
                .filter("date BETWEEN { %@, %@ }", startDate, endDate))
            filteredRecord.sort(by: { $0.date < $1.date })
            recordList = filteredRecord
        }
    }
    
    //Realmから取得したデータをグラフに描画する処理
    //これはグラフ画面が表示される度に実行したい処理→ ViewWillAppearへ
    func updateGraph() {
        //グラフにデータを設定するために"ChartDataEntry"というクラスを要素にもつ配列型の変数をインスタンス化
        var entry = [ChartDataEntry]()
        //"recordList"の各要素にアクセス
        //"enumerated()"を組み込むことで各要素のindex番号を引数として取得できるようになる
        recordList.enumerated().forEach({ index, record in
            //"record.weight"を"ChartDataEntry"というグラフを表すためのクラスとして変換している
            let data = ChartDataEntry(x: Double(index), y: record.weight)
            //インスタンス化した"ChartDataEntry"クラスの変数を"entry"配列に追加
            entry.append(data)
        })
        //棒グラフを表すクラス"LineChartDataSet"をインスタンス化
        //"entry"を引数で渡すことで"entry"内の各要素をグラフとして表現できる
        let dataSet = LineChartDataSet(entries: entry, label: "Weight")
        graphView.data = LineChartData(dataSet: dataSet)
        //setされたデータを使いグラフを更新する
        graphView.data?.notifyDataChanged()
        graphView.notifyDataSetChanged()
    }
    
    //グラフのX軸のラベルがグラフの下部に表示されるようにする処理
    //このmethodはグラフ画面を表示した際に実行したい→ ViewWillAppearへ
    func configureGraph() {
        graphView.xAxis.labelPosition = .bottom
        //"GraphDateTitleFormatter"をインスタンス化
        let titleFormatter = GraphDateTitleFormatter()
        //"GraphDateTitleFormatter"に渡す日付の配列を"dateList"としてインスタンス化
        let dateList = recordList.map({ $0.date })
        titleFormatter.dateList = dateList
        graphView.xAxis.valueFormatter = titleFormatter
    }
    
    //"datePicker"を2つの"Textfield"に適用するためのmethod → ViewWilAppearへ
    func configureTextField() {
        let startDatePicker = datePicker
        let endDatePicker = datePicker
        //開始日を1か月前にする処理
        let today = Date()
        let pastMonth = Calendar.current.date(byAdding: .month, value: -1, to: today)!
        startDatePicker.date = pastMonth
        endDatePicker.date = today
        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker
        startDateTextField.text = dateFormatter.string(from: pastMonth)
        endDateTextField.text = dateFormatter.string(from: today)
        startDateTextField.inputAccessoryView = toolBar
        endDateTextField.inputAccessoryView = toolBar
        startDatePicker.addTarget(self, action: #selector(didChangeStartDate), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(didChangeEndDate), for: .valueChanged)
    }
    
    @objc func didTapDone() {
        //キーボードの閉じるボタンが押された際に、グラフとデータを更新する処理
        setRecord()
        updateGraph()
        //キーボードを閉じるためのmethod
        view.endEditing(true)
    }
    
    //2つの"DatePicker"の値が変更された際に"TextField"にもその値が適用されるようにする処理
    @objc func didChangeStartDate(picker: UIDatePicker) {
        startDateTextField.text = dateFormatter.string(from: picker.date)
    }
    
    @objc func didChangeEndDate(picker: UIDatePicker) {
        endDateTextField.text = dateFormatter.string(from: picker.date)
    }
}
