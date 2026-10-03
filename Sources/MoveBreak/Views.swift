import SwiftUI
import Charts
import MoveBreakCore

private let accent = Color(red: 0.31, green: 0.56, blue: 0.53)
struct MainView: View {
    @EnvironmentObject var model: AppModel
    @State private var selectedTab = "home"
    var body: some View {
        TabView(selection: $selectedTab) {
            if model.language.isRTL {
                settingsTab; historyTab; exercisesTab; homeTab
            } else {
                homeTab; exercisesTab; historyTab; settingsTab
            }
        }.padding(12).tint(accent).frame(minWidth: 800, minHeight: 620)
            .alert("MoveBreak", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
                Button(model.text("OK")) { model.error = nil }
            } message: { Text(model.error ?? "") }
    }
    private var homeTab: some View {
        dashboard.tabItem { Label(model.text("Home"), systemImage: "house") }.tag("home")
    }
    private var exercisesTab: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240))], spacing: 20) {
                ForEach(model.exercises) { exercise in
                    ExerciseCard(exercise: exercise).padding(18).background(.background, in: RoundedRectangle(cornerRadius: 18))
                }
            }.padding(24)
        }.tabItem { Label(model.text("Exercises"), systemImage: "figure.flexibility") }.tag("exercises")
    }
    private var historyTab: some View {
        history.tabItem { Label(model.text("History"), systemImage: "chart.bar") }.tag("history")
    }
    private var settingsTab: some View {
        PreferencesView().padding(28).tabItem { Label(model.text("Settings"), systemImage: "gearshape") }.tag("settings")
    }
    private var dashboard: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 24) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Label(model.text("A little movement. A better day."), systemImage: "leaf").font(.title3).foregroundStyle(accent)
                        Text(model.text("Next movement break")).foregroundStyle(.secondary)
                        Text(model.countdown).environment(\.layoutDirection, .leftToRight).font(.system(size: 76, weight: .semibold, design: .rounded)).monospacedDigit().accessibilityLabel(model.text("Next break in %@", model.countdown))
                        Text(model.status).foregroundStyle(accent)
                        HStack {
                            Button(model.text(model.engine.paused ? "Resume" : "Pause"), action: model.togglePause)
                            Button(model.text("Restart"), action: model.restart).disabled(model.engine.pending != nil)
                            Button(model.text("Take a break"), action: model.takeBreak).buttonStyle(.borderedProminent)
                        }.buttonStyle(.bordered)
                    }.padding(28).frame(maxWidth: .infinity).background(.background, in: RoundedRectangle(cornerRadius: 20))
                    HStack(spacing: 40) {
                        metric(model.text("Breaks completed today"), value: model.number(model.completedToday))
                        metric(model.text("Active work minutes"), value: model.number(model.activeMinutes))
                    }.padding(24)
                    Text(model.text("Work at your own pace. Move gently and stop if a movement feels uncomfortable.")).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity)
                if let exercise = model.exercise {
                    ExerciseCard(exercise: exercise).padding(24).frame(width: 300).background(.background, in: RoundedRectangle(cornerRadius: 20))
                }
            }.padding(24)
        }
    }
    private func metric(_ title: String, value: String) -> some View {
        VStack { Text(value).font(.largeTitle.bold()).foregroundStyle(accent); Text(title).font(.caption).foregroundStyle(.secondary) }
    }
    private var history: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(model.text("Last seven days")).font(.title2.bold())
            Chart(0..<7, id: \.self) { offset in
                let day = Calendar.current.date(byAdding: .day, value: offset - 6, to: Date())!
                let count = model.data.records.filter { Calendar.current.isDate($0.date, inSameDayAs: day) && $0.outcome == .completed }.count
                BarMark(x: .value(model.text("Day"), Calendar.current.startOfDay(for: day), unit: .day), y: .value(model.text("Completed"), count)).foregroundStyle(accent)
            }.frame(height: 180).chartYAxis { AxisMarks(values: .automatic(desiredCount: 4)) }
            Text(model.text("Recent breaks")).font(.headline)
            List(model.data.records.reversed().prefix(100)) { record in
                HStack {
                    Text(model.exercises.first { $0.id == record.exerciseID }?.title(in: model.language) ?? model.text("Break"))
                    Spacer()
                    Text(model.text(record.outcome.rawValue.capitalized)).foregroundStyle(.secondary)
                    Text(record.date.formatted(.dateTime.month().day().hour().minute().locale(model.language.locale))).foregroundStyle(.secondary)
                }
            }
        }.padding(24)
    }
}
struct ExerciseCard: View {
    @EnvironmentObject var model: AppModel
    let exercise: Exercise
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let image = exercise.illustration {
                Image(nsImage: image).resizable().scaledToFit().frame(height: 190).accessibilityLabel(exercise.title(in: model.language))
            }
            Text(model.text(exercise.category)).font(.caption.weight(.semibold)).foregroundStyle(accent)
            Text(exercise.title(in: model.language)).font(.title2.weight(.semibold))
            Text(exercise.instruction(in: model.language)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            Label(model.text("%@ seconds", model.number(exercise.duration)), systemImage: "timer").font(.caption)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
struct BreakView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        ScrollView { VStack(spacing: 18) {
            Text(model.text("Take a moment for yourself")).font(.title2.bold())
            if let exercise = model.exercise { ExerciseCard(exercise: exercise) }
            HStack {
                Button(model.text("Skip")) { model.resolve(.skipped) }
                Button(model.text("Snooze 5 min")) { model.resolve(.snoozed) }
                Button(model.text("Completed")) { model.resolve(.completed) }.buttonStyle(.borderedProminent)
            }.buttonStyle(.bordered)
            Text(model.text("Move gently. Stop if you feel pain.")).font(.caption).foregroundStyle(.secondary)
        }.padding(28) }.frame(width: 460, height: 540).tint(accent).preferredColorScheme(model.colorScheme)
    }
}
struct PreferencesView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        Form {
            Picker(model.text("Language"), selection: Binding(get: { model.language.rawValue }, set: { model.setLanguage($0) })) {
                ForEach(AppLanguage.allCases, id: \.self) { language in Text(language.name).tag(language.rawValue) }
            }
            Section(model.text("Your rhythm")) {
                Stepper(model.text("Movement reminder: %@ minutes", model.number(model.data.preferences.reminderMinutes)), value: $model.data.preferences.reminderMinutes, in: 1...120)
                Stepper(model.text("Pause after %@ idle minutes", model.number(model.data.preferences.idleMinutes)), value: $model.data.preferences.idleMinutes, in: 1...30)
                Toggle(model.text("Eye-rest reminder every 20 active minutes"), isOn: $model.data.preferences.eyes)
                Toggle(model.text("Defer reminders (presentation mode)"), isOn: $model.data.preferences.deferReminders)
            }
            Section(model.text("macOS")) {
                Toggle(model.text("Notification sound"), isOn: $model.data.preferences.sound)
                Toggle(model.text("Launch at login"), isOn: Binding(get: { model.loginEnabled }, set: { model.setLogin($0) }))
                LabeledContent(model.text("Notification permission"), value: model.notificationStatusText)
                Button(model.text("Enable system notifications"), action: model.enableNotifications)
                Button(model.text("Open notification settings"), action: model.openNotificationSettings)
                Button(model.text("Send test notification"), action: model.sendTestNotification)
                if let report = model.notificationReport { Text(model.text(report)).font(.caption).foregroundStyle(.secondary) }
                LabeledContent(model.text("Launch at login"), value: model.loginStatusText)
                Button(model.text("Open login item settings"), action: model.openLoginSettings)
                Picker(model.text("Appearance"), selection: $model.data.preferences.appearance) {
                    Text(model.text("System")).tag("system"); Text(model.text("Light")).tag("light"); Text(model.text("Dark")).tag("dark")
                }
            }
            Text(model.text("A new interval starts after saving.")).font(.caption).foregroundStyle(.secondary)
            Button(model.text("Save settings"), action: model.applyPreferences).buttonStyle(.borderedProminent)
            if model.settingsSaved { Text(model.text("Settings saved")).foregroundStyle(accent) }
            Section {
                Text("MoveBreak \(model.version) · " + model.text("Works offline. Your activity stays on this Mac.")).font(.caption).foregroundStyle(.secondary)
                Text(model.text("General wellness guidance; not medical advice.")).font(.caption).foregroundStyle(.secondary)
            }
        }.formStyle(.grouped).tint(accent)
    }
}
