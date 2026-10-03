import SwiftUI
import AppKit
import UserNotifications

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    static var model: AppModel?
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    func applicationWillTerminate(_ notification: Notification) { Self.model?.save() }
}
@main struct MoveBreakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var model = AppModel()
    var body: some Scene {
        Window("MoveBreak", id: "main") {
            MainView().environmentObject(model).localized(using: model).preferredColorScheme(model.colorScheme)
                .onAppear { AppDelegate.model = model }
        }.defaultSize(width: 980, height: 700)
        MenuBarExtra("MoveBreak", systemImage: "figure.walk") {
            MenuContent().environmentObject(model).localized(using: model)
        }
        Settings { PreferencesView().environmentObject(model).localized(using: model).padding(24).frame(width: 520, height: 660) }
    }
}
struct MenuContent: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openWindow) var openWindow
    var body: some View {
        Text(model.text("Next movement break: %@", model.countdown))
        Text(model.status)
        Button(model.text("Open MoveBreak")) { openWindow(id: "main"); NSApp.activate(ignoringOtherApps: true) }
        Button(model.text(model.engine.paused ? "Resume" : "Pause"), action: model.togglePause)
        Button(model.text("Take a break now"), action: model.takeBreak)
        Toggle(model.text("Defer reminders (presentation mode)"), isOn: $model.data.preferences.deferReminders)
            .onChange(of: model.data.preferences.deferReminders) { model.save() }
        Divider()
        SettingsLink { Text(model.text("Settings")) }
        Button(model.text("Quit MoveBreak")) { model.save(); NSApp.terminate(nil) }.keyboardShortcut("q")
    }
}

private struct LocalizationModifier: ViewModifier {
    @ObservedObject var model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    func body(content: Content) -> some View {
        content
            .environment(\.locale, model.language.locale)
            .environment(\.layoutDirection, model.language.isRTL ? .rightToLeft : .leftToRight)
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in model.refreshPermissions() }
            .onChange(of: scenePhase) { _, phase in if phase == .active { model.refreshPermissions() } }
    }
}
extension View {
    func localized(using model: AppModel) -> some View { modifier(LocalizationModifier(model: model)) }
}
