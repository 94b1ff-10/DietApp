//
//  CalenderViewController.swift
//  MyDietDiaryApp
//
//  Created by TEN MATSUMOTO on 9/9/2022.
//

import UIKit
import FSCalendar
import RealmSwift

class CalendarViewController: UIViewController {
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var addButton: UIButton!
    //Buttonがタップされた処理を記述する際は"@IBAction"を使う
    @IBAction func addButton(_ sender: UIButton) {
        transitionToEditorView()
    }
    
    var recordList: [WeightRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendar()
        configureButton()
        //"CalendarViewController: FSCalendarDataSource"を有効化
        calendarView.dataSource = self
        //"CalendarViewController: FSCalendarDelegate"を有効化
        calendarView.delegate = self
    }
    
    //データ取得処理はカレンダー画面が表示される度に実行したいので"viewWillAppear"に記述
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        //データ取得処理
        getRecord()
        //カレンダー更新処理
        calendarView.reloadData()
    }
    
    //CalandarViewの設定
    func configureCalendar() {
        // ヘッダーの日付フォーマットを変更
        calendarView.appearance.headerDateFormat = "dd/MM/yyyy"
        // 曜日と今日の色を指定
        calendarView.appearance.todayColor = .orange
        calendarView.appearance.headerTitleColor = .orange
        calendarView.appearance.weekdayTextColor = .black
        // 曜日表示内容を変更
        calendarView.calendarWeekdayView.weekdayLabels[0].text = "Sun"
        calendarView.calendarWeekdayView.weekdayLabels[1].text = "Mon"
        calendarView.calendarWeekdayView.weekdayLabels[2].text = "Tue"
        calendarView.calendarWeekdayView.weekdayLabels[3].text = "Wed"
        calendarView.calendarWeekdayView.weekdayLabels[4].text = "Thu"
        calendarView.calendarWeekdayView.weekdayLabels[5].text = "Fri"
        calendarView.calendarWeekdayView.weekdayLabels[6].text = "Sat"
        // 土日の色を変更
        calendarView.calendarWeekdayView.weekdayLabels[0].textColor = .red
        calendarView.calendarWeekdayView.weekdayLabels[6].textColor = .blue
        //カレンダーの外枠を丸くする
        calendarView.layer.cornerRadius = 4
    }
    //カレンダーの右下に追加した"＋"ボタンの設定
    func configureButton() {
        //ボタンの角を落とし、丸くする処理
        addButton.layer.cornerRadius = addButton.bounds.width / 2
    }
    
    //Buttonがタップされた際のAction("EditorViewController"をインスタンス化した後にpresentメソッドで画面遷移するように記述)
    func transitionToEditorView(with record: WeightRecord? = nil) {
        let storyboard = UIStoryboard(name: "EditorViewController", bundle: nil)
        //optional-binding
        guard let editorViewController = storyboard.instantiateInitialViewController() as? EditorViewController else { return }
        //"editorViewController"に画面遷移する際にrecordを渡す
        if let record = record {
            editorViewController.record = record
        }
        //子クラスの"delegate"に対して"calendarViewController"自身を適用する
        editorViewController.delegate = self
        present(editorViewController, animated: true)
    }
    
    //"recordList"にRealmで保存されているデータを格納する処理
    func getRecord() {
        let realm = try! Realm()
        recordList = Array(realm.objects(WeightRecord.self))
    }
}

//カレンダーにマークを追加する処理
//"FSCalendarDataSource"はカレンダーの見た目などを設定するプロトコル。様々なmethodが用意されている
extension CalendarViewController: FSCalendarDataSource {
    //"numberOfEventsFor"はカレンダーの日付にイベントマークを追加するmethod
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        //"recordList"に格納されている"dateRecord"クラスの"date"プロパティだけを取得したいので"map"methodで"date"だけをインスタンス化
        let dateList = recordList.map({ $0.date.zeroclock })
        //"contains"methodを使用し"dateList"の要素の中に引数である"date"と同じ値のデータが存在するかをBool型で判別している
        //"Date+Extension"で記述した"zeroclock"プロパティを用いて参照内容を年月日に指定する
        let isEqualDate = dateList.contains(date.zeroclock)
        return isEqualDate ? 1 : 0
        //"isEqualDate"がRealm上に保存されたデータの日付とカレンダーの日付を参照し、true→ 1, false→ 0を"calendar"methodに返す
    }
}

//カレンダーがタップされた際の処理 ("FSCalendarDelegate"にはカレンダーを操作した際に実行されるmethodがあらかじめ用意されている)
extension CalendarViewController: FSCalendarDelegate {
    //カレンダーの日付がタップされた際に動作させたいので"didSelect"methodを使用する。引数の"Date"はタップした際の日付が渡されるのでこの日付に該当するデータを渡す
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //カレンダーがタップされた際の日付の選択状態を解除する処理
        calendar.deselect(date)
        //配列に対して任意のデータを取得する際には"first(where:)"methodを使用する
        guard let record = recordList.first(where: { $0.date.zeroclock == date.zeroclock}) else { return } // $0 = dateRecord
        //データ記録画面を表示する際に"record"データを渡す処理
        transitionToEditorView(with: record)
    }
}

//子クラス(EditorViewController: UIViewController)からのdelegateの通知を受け取る
extension CalendarViewController: EditorViewControllerDelegate {
    //EditorViewControllerからの"delegate"を受け取った際に行う処理(recordUpdate)
    func recordUpdate() {
        //この通知(recordUpdate)を受け取った時に行う処理を記述する。ここでは最新のデータを取得しカレンダーを更新する処理
        getRecord()
        calendarView.reloadData()
    }
}
