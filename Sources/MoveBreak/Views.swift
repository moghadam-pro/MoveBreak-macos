import SwiftUI
import Charts
import MoveBreakCore

private let accent = Color(red: 0.31, green: 0.56, blue: 0.53)
struct MainView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        TabView {
            dashboard.tabItem { Label("Home", systemImage: "house") }
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240))], spacing: 20) {
                    ForEach(model.exercises) { exercise in
                        ExerciseCard(exercise: exercise).padding(18).background(.background, in: RoundedRectangle(cornerRadius: 18))
                    }
                }.padding(24)
            }.tabItem { Label("Exercises", systemImage: "figure.flexibility") }
            history.tabItem { Label("History", systemImage: "chart.bar") }
            PreferencesView().padding(28).tabItem { Label("Settings", systemImage: "gearshape") }
        }.padding(12).tint(accent).frame(minWidth: 800, minHeight: 620)
            .alert("MoveBreak", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
                Button("OK") { model.error = nil }
            } message: { Text(model.error ?? "") }
    }
    private var dashboard: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 24) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Label("A little movement. A better day.", systemImage: "leaf").font(.title3).foregroundStyle(accent)
                        Text("Next movement break").foregroundStyle(.secondary)
                        Text(model.countdown).font(.system(size: 76, weight: .semibold, design: .rounded)).monospacedDigit().accessibilityLabel("Next break in \(model.countdown)")
                        Text(model.status).foregroundStyle(accent)
                        HStack {
                            Button(model.engine.paused ? "Resume" : "Pause", action: model.togglePause)
                            Button("Restart", action: model.restart).disabled(model.engine.pending != nil)
                            Button("Take a break", action: model.takeBreak).buttonStyle(.borderedProminent)
                        }.buttonStyle(.bordered)
                    }.padding(28).frame(maxWidth: .infinity).background(.background, in: RoundedRectangle(cornerRadius: 20))
                    HStack(spacing: 40) {
                        metric("Breaks completed today", value: "\(model.completedToday)")
                        metric("Active work minutes", value: "\(model.activeMinutes)")
                    }.padding(24)
                    Text("Work at your own pace. Move gently and stop if a movement feels uncomfortable.").foregroundStyle(.secondary)
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
            Text("Last seven days").font(.title2.bold())
            Chart(0..<7, id: \.self) { offset in
                let day = Calendar.current.date(byAdding: .day, value: offset - 6, to: Date())!
                let count = model.data.records.filter { Calendar.current.isDate($0.date, inSameDayAs: day) && $0.outcome == .completed }.count
                BarMark(x: .value("Day", Calendar.current.startOfDay(for: day), unit: .day), y: .value("Completed", count)).foregroundStyle(accent)
            }.frame(height: 180).chartYAxis { AxisMarks(values: .automatic(desiredCount: 4)) }
            Text("Recent breaks").font(.headline)
            List(model.data.records.reversed().prefix(100)) { record in
                HStack {
                    Text(model.exercises.first { $0.id == record.exerciseID }?.title ?? "Break")
                    Spacer()
                    Text(record.outcome.rawValue.capitalized).foregroundStyle(.secondary)
                    Text(record.date, format: .dateTime.month().day().hour().minute()).foregroundStyle(.secondary)
                }
            }
        }.padding(24)
    }
}
struct ExerciseCard: View {
    let exercise: Exercise
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let image = exercise.illustration {
                Image(nsImage: image).resizable().scaledToFit().frame(height: 190).accessibilityLabel(exercise.title)
            }
            Text(exercise.category.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(accent)
            Text(exercise.title).font(.title2.weight(.semibold))
            Text(exercise.instruction).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            Label("\(exercise.duration) seconds", systemImage: "timer").font(.caption)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
struct BreakView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        ScrollView { VStack(spacing: 18) {
            Text("Take a moment for yourself").font(.title2.bold())
            if let exercise = model.exercise { ExerciseCard(exercise: exercise) }
            HStack {
                Button("Skip") { model.resolve(.skipped) }
                Button("Snooze 5 min") { model.resolve(.snoozed) }
                Button("Completed") { model.resolve(.completed) }.buttonStyle(.borderedProminent)
            }.buttonStyle(.bordered)
            Text("Move gently. Stop if you feel pain.").font(.caption).foregroundStyle(.secondary)
        }.padding(28) }.frame(width: 460, height: 540).tint(accent).preferredColorScheme(model.colorScheme)
    }
}
struct PreferencesView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        Form {
            Section("Your rhythm") {
                Stepper("Movement reminder: \(model.data.preferences.reminderMinutes) minutes", value: $model.data.preferences.reminderMinutes, in: 1...120)
                Stepper("Pause after \(model.data.preferences.idleMinutes) idle minutes", value: $model.data.preferences.idleMinutes, in: 1...30)
                Toggle("Eye-rest reminder every 20 active minutes", isOn: $model.data.preferences.eyes)
                Toggle("Defer reminders (presentation mode)", isOn: $model.data.preferences.deferReminders)
            }
            Section("macOS") {
                Toggle("Notification sound", isOn: $model.data.preferences.sound)
                Toggle("Launch at login", isOn: Binding(get: { model.loginEnabled }, set: { model.setLogin($0) }))
                Button("Enable system notifications", action: model.enableNotifications)
                Picker("Appearance", selection: $model.data.preferences.appearance) {
                    Text("System").tag("system"); Text("Light").tag("light"); Text("Dark").tag("dark")
                }
            }
            Button("Save settings", action: model.applyPreferences).buttonStyle(.borderedProminent)
            Section {
                Text("MoveBreak 0.1.0 · Works offline. Your activity stays on this Mac.").font(.caption).foregroundStyle(.secondary)
                Text("General wellness guidance; not medical advice.").font(.caption).foregroundStyle(.secondary)
            }
        }.formStyle(.grouped).tint(accent)
    }
}
