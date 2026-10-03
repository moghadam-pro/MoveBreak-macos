import AppKit
import SwiftUI
import CoreGraphics
import UserNotifications
import ServiceManagement
import MoveBreakCore

struct Exercise: Codable, Identifiable {
    let id: Int
    let category: String
    let duration: Int
    let image: String
    let titles: [String: String]
    let instructions: [String: String]
    func title(in language: AppLanguage) -> String { titles[language.rawValue] ?? titles["en"] ?? "" }
    func instruction(in language: AppLanguage) -> String { instructions[language.rawValue] ?? instructions["en"] ?? "" }
    var illustration: NSImage? {
        Bundle.module.url(forResource: (image as NSString).deletingPathExtension, withExtension: "png")
            .flatMap { NSImage(contentsOf: $0) }
    }
}
struct Preferences: Codable {
    // Optional for backwards-compatible decoding of the 0.1.0 document.
    var languageCode: String? = nil
    var reminderMinutes = 45
    var idleMinutes = 3
    var sound = true
    var eyes = true
    var appearance = "system"
    var deferReminders = false
}
struct LocalData: Codable {
    var schemaVersion = 1
    var preferences = Preferences()
    var records: [BreakRecord] = []
    var workByDay: [String: Double] = [:]
}

@MainActor final class AppModel: ObservableObject {
    @Published var engine = BreakEngine()
    @Published var data = LocalData()
    @Published var exercise: Exercise?
    @Published var error: String?
    @Published var inactive = false
    @Published var loginStatus = SMAppService.mainApp.status
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published var settingsSaved = false
    @Published var notificationReport: String?
    var loginEnabled: Bool { loginStatus == .enabled }
    var language: AppLanguage { AppLanguage(rawValue: data.preferences.languageCode ?? "") ?? AppLanguage.preferred(from: Locale.preferredLanguages) }
    var localization: Localization { Localization(language: language) }
    func text(_ key: String, _ args: String...) -> String {
        let format = Localization.catalogs[language]?[key] ?? key
        return args.isEmpty ? format : String(format: format, locale: language.locale, arguments: args)
    }
    func number(_ value: Int) -> String { localization.number(value) }
    var version: String { Bundle.main.object(forInfoDictionaryKey: "MBReleaseVersion") as? String ?? "Development" }
    var notificationStatusText: String {
        switch notificationStatus {
        case .notDetermined: text("Not requested")
        case .denied: text("Denied")
        default: text("Allowed")
        }
    }
    var loginStatusText: String {
        switch loginStatus {
        case .enabled: text("On")
        case .requiresApproval: text("Requires approval")
        default: text("Off")
        }
    }
    let exercises: [Exercise]
    private var timer: Timer?
    private var previous = ProcessInfo.processInfo.systemUptime
    private var sleeping = false
    private var sessionActive = true
    private var observers: [NSObjectProtocol] = []
    private var saveCounter = 0
    private var canSave = true
    private var panel: NSPanel?
    private let file: URL
    var countdown: String {
        let seconds = Int(ceil(engine.remaining))
        return String(format: "%02d:%02d", locale: language.locale, seconds / 60, seconds % 60)
    }
    var status: String { text(engine.pending != nil ? "Time for a break" : engine.paused ? "Paused" : inactive ? "Away from your Mac" : "Working") }
    var completedToday: Int { data.records.filter { Calendar.current.isDateInToday($0.date) && $0.outcome == .completed }.count }
    var activeMinutes: Int { Int((data.workByDay[dayKey(Date())] ?? 0) / 60) }
    var colorScheme: ColorScheme? { data.preferences.appearance == "dark" ? .dark : data.preferences.appearance == "light" ? .light : nil }

    init() {
        file = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MoveBreak/state.json")
        do {
            let url = Bundle.module.url(forResource: "exercises", withExtension: "json")!
            exercises = try JSONDecoder().decode([Exercise].self, from: Data(contentsOf: url))
        } catch { fatalError("Bundled exercise catalog is invalid: \(error)") }
        if FileManager.default.fileExists(atPath: file.path) {
            do {
                data = try JSONDecoder().decode(LocalData.self, from: Data(contentsOf: file))
                guard data.schemaVersion == 1 else { throw CocoaError(.fileReadCorruptFile) }
            } catch {
                canSave = false
                self.error = text("Saved data could not be read. The original file is preserved at %@. %@", file.path, error.localizedDescription)
            }
        }
        data.preferences.reminderMinutes = min(120, max(1, data.preferences.reminderMinutes))
        data.preferences.idleMinutes = min(30, max(1, data.preferences.idleMinutes))
        engine = BreakEngine(interval: Double(data.preferences.reminderMinutes * 60))
        engine.eyesEnabled = data.preferences.eyes
        exercise = exercises.first
        refreshPermissions()
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.willSleepNotification, NSWorkspace.screensDidSleepNotification, NSWorkspace.sessionDidResignActiveNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] note in
                let resigned = note.name == NSWorkspace.sessionDidResignActiveNotification
                Task { @MainActor in
                    if resigned { self?.sessionActive = false } else { self?.sleeping = true }
                    self?.previous = ProcessInfo.processInfo.systemUptime
                }
            })
        }
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification, NSWorkspace.sessionDidBecomeActiveNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] note in
                let activated = note.name == NSWorkspace.sessionDidBecomeActiveNotification
                Task { @MainActor in
                    if activated { self?.sessionActive = true } else { self?.sleeping = false }
                    self?.previous = ProcessInfo.processInfo.systemUptime
                }
            })
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }
    func dayKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }
    func tick() {
        let now = ProcessInfo.processInfo.systemUptime
        let elapsed = now - previous
        previous = now
        let idle = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .null)
        inactive = sleeping || !sessionActive || idle >= Double(data.preferences.idleMinutes * 60)
        let hadPending = engine.pending != nil
        // A long suspension cannot reliably be classified as active work.
        let counted = engine.advance(seconds: elapsed <= 5 ? elapsed : 0, active: !inactive, deferred: data.preferences.deferReminders)
        if counted > 0 { data.workByDay[dayKey(Date()), default: 0] += counted }
        if !hadPending, let kind = engine.pending {
            selectExercise(eyesOnly: kind == .eyes)
            showBreak()
            notify()
        }
        saveCounter += 1
        if saveCounter >= 15 { saveCounter = 0; save(); refreshPermissions() }
    }
    func selectExercise(eyesOnly: Bool = false) {
        let choices = exercises.filter { (!eyesOnly || $0.category == "Eye") && $0.id != exercise?.id }
        exercise = choices.randomElement() ?? exercises.first
    }
    func togglePause() { engine.paused.toggle(); previous = ProcessInfo.processInfo.systemUptime }
    func restart() { guard engine.pending == nil else { return }; engine.restart() }
    func takeBreak() {
        guard engine.pending == nil else { showBreak(); return }
        engine.requestBreak()
        selectExercise(); showBreak(); notify()
    }
    func resolve(_ outcome: BreakRecord.Outcome) {
        guard let kind = engine.pending, let exercise else { return }
        data.records.append(BreakRecord(exerciseID: exercise.id, kind: kind, outcome: outcome))
        engine.resolve(snooze: outcome == .snoozed)
        panel?.close(); panel = nil
        previous = ProcessInfo.processInfo.systemUptime
        save()
        selectExercise()
    }
    func applyPreferences() {
        engine.interval = Double(data.preferences.reminderMinutes * 60)
        engine.eyesEnabled = data.preferences.eyes
        if engine.pending == nil { engine.restart() }
        save()
        settingsSaved = true
    }
    func setLanguage(_ code: String) {
        guard AppLanguage(rawValue: code) != nil else { return }
        data.preferences.languageCode = code
        panel?.title = "MoveBreak · " + text("Take a moment")
        save()
    }
    func save() {
        guard canSave else { return }
        do {
            try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(data).write(to: file, options: .atomic)
        } catch { self.error = text("Could not save local data: %@", error.localizedDescription) }
    }
    func refreshPermissions() {
        loginStatus = SMAppService.mainApp.status
        UNUserNotificationCenter.current().getNotificationSettings { @Sendable settings in
            let status = settings.authorizationStatus
            Task { @MainActor in self.notificationStatus = status }
        }
    }
    func setLogin(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            loginStatus = SMAppService.mainApp.status
            if enabled && loginStatus == .requiresApproval { error = text("Approve MoveBreak in System Settings > General > Login Items.") }
        } catch { self.error = text("Login item could not be changed: %@", error.localizedDescription) }
    }
    func openLoginSettings() { SMAppService.openSystemSettingsLoginItems() }
    func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") { NSWorkspace.shared.open(url) }
    }
    func enableNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { @Sendable allowed, error in
            let message = error?.localizedDescription
            Task { @MainActor in
                self.refreshPermissions()
                if !allowed { self.error = self.text("Notifications are disabled. Enable them in System Settings.") }
                else if let message { self.error = self.text("Notification unavailable: %@", message) }
            }
        }
    }
    func sendTestNotification() { notificationReport = nil; notify(test: true) }
    private func notify(test: Bool = false) {
        let title = text("Time to move")
        let body = test ? text("This is a MoveBreak test notification.") : exercise?.title(in: language) ?? text("Take a short break.")
        let sound = data.preferences.sound
        UNUserNotificationCenter.current().getNotificationSettings { @Sendable settings in
            let status = settings.authorizationStatus
            Task { @MainActor in self.notificationStatus = status }
            let allowed = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            guard allowed else {
                if test { Task { @MainActor in self.error = self.text("Notifications are disabled. Enable them in System Settings.") } }
                return
            }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            if sound { content.sound = .default }
            let trigger = test ? UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false) : nil
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: test ? "movebreak-test" : "movebreak-reminder", content: content, trigger: trigger)) { @Sendable error in
                if let error { Task { @MainActor in self.error = self.text("Notification unavailable: %@", error.localizedDescription) } }
                else if test {
                    Task { @MainActor in
                        self.notificationReport = "Test notification scheduled. macOS controls its display."
                        try? await Task.sleep(for: .seconds(4))
                        let delivered = await withCheckedContinuation { continuation in
                            Self.readTestDeliveryStatus { continuation.resume(returning: $0) }
                        }
                        if delivered {
                            self.notificationReport = "Test notification delivered to Notification Center."
                        }
                    }
                }
            }
        }
    }
    // Older SDKs do not mark UNNotification Sendable. Inspect framework objects
    // inside the callback and transfer only a Bool to the main actor.
    private nonisolated static func readTestDeliveryStatus(_ completion: @escaping @Sendable (Bool) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications { @Sendable notifications in
            completion(notifications.contains { $0.request.identifier == "movebreak-test" })
        }
    }
    func showBreak() {
        guard engine.pending != nil else { return }
        if panel == nil {
            let newPanel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 460, height: 540), styleMask: [.titled], backing: .buffered, defer: false)
            newPanel.title = "MoveBreak · " + text("Take a moment")
            newPanel.level = .floating
            newPanel.isReleasedWhenClosed = false
            newPanel.contentView = NSHostingView(rootView: BreakView().environmentObject(self).localized(using: self))
            newPanel.center()
            panel = newPanel
        }
        panel?.makeKeyAndOrderFront(nil)
    }
}
