import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AlarmViewModel()
    @State private var selectedDate = Date()
    @State private var message = ""
    @State private var memo = ""
    @State private var editingAlarm: Alarm? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    DatePicker("アラーム日時", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("通知メッセージ", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.done)
                        .onSubmit { hideKeyboard() } // Enterキーで閉じる
                    
                    VStack(alignment: .leading) {
                        Text("メモ")
                        TextEditor(text: $memo)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            .submitLabel(.done)
                            .onSubmit { hideKeyboard() }
                    }
                    
                    Button(editingAlarm == nil ? "アラームを追加" : "アラームを更新") {
                        if let alarm = editingAlarm {
                            viewModel.updateAlarm(alarm, date: selectedDate, message: message, memo: memo)
                        } else {
                            viewModel.addAlarm(date: selectedDate, message: message, memo: memo)
                        }
                        resetInputFields()
                        hideKeyboard()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(message.isEmpty)
                }
                
                List {
                    ForEach(viewModel.alarms) { alarm in
                        VStack(alignment: .leading) {
                            Text("\(alarm.date, formatter: dateFormatter)")
                                .font(.headline)
                            Text("メッセージ: \(alarm.message)")
                            Text("メモ:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(alarm.memo)
                                .font(.body)
                                .padding(.leading, 5)
                        }
                        .onTapGesture {
                            startEditing(alarm)
                        }
                    }
                    .onDelete(perform: viewModel.removeAlarm)
                }
            }
            .navigationTitle("アラーム設定")
            .onAppear {
                requestNotificationPermission()
            }
            .onTapGesture {
                hideKeyboard() // メモ入力後キーボードが閉じなくなったため、画面のどこかをタップで閉じるように変更
            }
        }
    }
    
    private func startEditing(_ alarm: Alarm) {
        editingAlarm = alarm
        selectedDate = alarm.date
        message = alarm.message
        memo = alarm.memo
    }
    
    private func resetInputFields() {
        editingAlarm = nil
        selectedDate = Date()
        message = ""
        memo = ""
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }
}

// キーボードを閉じるためのヘルパー関数
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
