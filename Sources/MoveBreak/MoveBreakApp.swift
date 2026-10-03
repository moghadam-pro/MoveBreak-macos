import SwiftUI
import AppKit

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate {
    static var model: AppModel?
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    func applicationWillTerminate(_ notification: Notification) { Self.model?.save() }
}
@main struct MoveBreakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var model = AppModel()
    var body: some Scene {
        Window("MoveBreak", id: "main") {
            MainView().environmentObject(model).preferredColorScheme(model.colorScheme)
                .onAppear { AppDelegate.model = model }
        }.defaultSize(width: 980, height: 700)
        MenuBarExtra("MoveBreak", systemImage: "figure.walk") {
            MenuContent().environmentObject(model)
        }
        Settings { PreferencesView().environmentObject(model).padding(24).frame(width: 440) }
    }
}
struct MenuContent: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openWindow) var openWindow
    var body: some View {
        Text("Next movement break: \(model.countdown)")
        Text(model.status)
        Button("Open MoveBreak") { openWindow(id: "main"); NSApp.activate(ignoringOtherApps: true) }
        Button(model.engine.paused ? "Resume" : "Pause", action: model.togglePause)
        Button("Take a break now", action: model.takeBreak)
        Toggle("Defer reminders (presentation mode)", isOn: $model.data.preferences.deferReminders)
            .onChange(of: model.data.preferences.deferReminders) { model.save() }
        Divider()
        SettingsLink()
        Button("Quit MoveBreak") { model.save(); NSApp.terminate(nil) }.keyboardShortcut("q")
    }
}
