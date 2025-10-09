//  ContentView.swift
//  Week 5 Assignment
//
//  Created by Brenda Yang on 10/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Pages") {
                    NavigationLink("App Storage Settings") {
                        AppStoragePage()
                    }
                }

                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This simple navigation app shows a Home page and a Settings page that persists values using AppStorage.")
                            .font(.callout)
                        Text("Your changes are saved automatically.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Week 5: Navigation")
        }
    }
}

// MARK: - AppStorage Page
struct AppStoragePage: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("launchCount") private var launchCount: Int = 0
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "System"

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("Preferences") {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                Stepper("Launch Count: \(launchCount)", value: $launchCount, in: 0...100)
                Picker("Color Scheme", selection: $colorSchemePreference) {
                    Text("System").tag("System")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                }
                .pickerStyle(.segmented)
            }

            Section("Debug") {
                Button(role: .destructive) {
                    username = ""
                    notificationsEnabled = true
                    launchCount = 0
                    colorSchemePreference = "System"
                } label: {
                    Text("Reset Settings")
                }
            }
        }
        .navigationTitle("App Storage")
    }
}

#Preview {
    ContentView()
}
