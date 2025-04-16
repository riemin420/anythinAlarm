import SwiftUI
import UserNotifications

class AlarmViewModel: ObservableObject {
    @Published var alarms: [Alarm] = [] {
        didSet {
            saveAlarms()
        }
    }
    
    init() {
        loadAlarms()
    }
    
    private let alarmsKey = "savedAlarms"
    
    func addAlarm(date: Date, message: String, memo: String) {
        let newAlarm = Alarm(date: date, message: message, memo: memo)
        alarms.append(newAlarm)
        scheduleNotification(for: newAlarm)
    }
    
    func updateAlarm(_ alarm: Alarm, date: Date, message: String, memo: String) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].date = date
            alarms[index].message = message
            alarms[index].memo = memo
            
            cancelNotification(for: alarms[index])
            scheduleNotification(for: alarms[index])
        }
    }
    
    func removeAlarm(at offsets: IndexSet) {
        offsets.forEach { index in
            cancelNotification(for: alarms[index])
        }
        alarms.remove(atOffsets: offsets)
    }
    
    private func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: alarmsKey)
        }
    }
    
    private func loadAlarms() {
        if let savedData = UserDefaults.standard.data(forKey: alarmsKey),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: savedData) {
            alarms = decoded
        }
    }
    
    private func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "アラーム通知"
        content.body = alarm.message
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alarm.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification(for alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }
}
