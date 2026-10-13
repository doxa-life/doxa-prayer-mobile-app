import SwiftUI

/// Reminder settings for the prototype. Moves to the phone once the watch app
/// is embedded and the phone's reminders reach the watch.
struct SettingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        List {
            Section(L10n.string("reminders")) {
                Toggle(L10n.string("watchDailyReminder"), isOn: Binding(
                    get: { model.reminderEnabled },
                    set: { on in
                        Task {
                            model.reminderEnabled = on ? await Reminders.requestPermission() : false
                        }
                    }
                ))
                if model.reminderEnabled {
                    DatePicker(L10n.string("time"), selection: timeBinding, displayedComponents: .hourAndMinute)
                }
            }
            #if DEBUG
            Section {
                Button(L10n.string("watchSendTestReminder")) {
                    Task {
                        if await Reminders.requestPermission() { Reminders.sendTest(groups: model.groups) }
                    }
                }
                .disabled(model.groups.isEmpty)
            }
            #endif
        }
        .navigationTitle(L10n.string("settings"))
    }

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: model.reminderMinutes / 60, minute: model.reminderMinutes % 60, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                model.reminderMinutes = (c.hour ?? 8) * 60 + (c.minute ?? 0)
            }
        )
    }
}
