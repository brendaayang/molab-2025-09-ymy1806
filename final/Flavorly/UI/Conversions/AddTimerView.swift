//
//  AddTimerView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct AddTimerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    
    @State private var name = ""
    @State private var selectedPreset: TimerPreset = .baking
    @State private var customHours = 0
    @State private var customMinutes = 25
    @State private var customSeconds = 0
    @State private var selectedColor: TimerColor = .pink
    
    let onAdd: (String, TimeInterval, TimerColor) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flavorlyCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Cute Header
                        HStack {
                            Image("melody3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                            
                            Text("set a timer")
                                .font(Theme.Fonts.bakeryTitle2)
                                .foregroundColor(.flavorlyPinkDark)
                        }
                        .padding(.top, 16)
                        
                        // Timer Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("timer name")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextField("cookies in oven, dough proofing...", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Theme.Fonts.bakeryBody)
                        }
                        
                        // Presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("quick presets")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(TimerPreset.allCases, id: \.self) { preset in
                                    Button {
                                        selectedPreset = preset
                                        if name.isEmpty {
                                            name = preset.rawValue.components(separatedBy: " (").first ?? ""
                                        }
                                    } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: preset.icon)
                                                .font(.title2)
                                            Text(preset.rawValue)
                                                .font(Theme.Fonts.bakeryBody)
                                                .multilineTextAlignment(.center)
                                        }
                                        .foregroundColor(selectedPreset == preset ? .white : .flavorlyPink)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: theme.cornerRadius)
                                                .fill(selectedPreset == preset ? Color.flavorlyPink : Color.flavorlyPinkLight.opacity(0.3))
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Custom Time (if custom preset selected)
                        if selectedPreset == .custom {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("custom duration")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                
                                HStack(spacing: 16) {
                                    VStack {
                                        Text("hours")
                                            .font(Theme.Fonts.bakeryCaption)
                                            .foregroundColor(.secondary)
                                        Picker("Hours", selection: $customHours) {
                                            ForEach(0..<24) { hour in
                                                Text("\(hour)").tag(hour)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 80, height: 100)
                                    }
                                    
                                    VStack {
                                        Text("minutes")
                                            .font(Theme.Fonts.bakeryCaption)
                                            .foregroundColor(.secondary)
                                        Picker("Minutes", selection: $customMinutes) {
                                            ForEach(0..<60) { minute in
                                                Text("\(minute)").tag(minute)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 80, height: 100)
                                    }
                                    
                                    VStack {
                                        Text("seconds")
                                            .font(Theme.Fonts.bakeryCaption)
                                            .foregroundColor(.secondary)
                                        Picker("Seconds", selection: $customSeconds) {
                                            ForEach(0..<60) { second in
                                                Text("\(second)").tag(second)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 80, height: 100)
                                    }
                                }
                            }
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("timer color")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            HStack(spacing: 16) {
                                ForEach(TimerColor.allCases, id: \.self) { color in
                                    Button {
                                        selectedColor = color
                                    } label: {
                                        Circle()
                                            .fill(colorForTimerColor(color))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.flavorlyPinkLight.opacity(0.5), lineWidth: 2)
                                            )
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.flavorlyPinkDark, lineWidth: selectedColor == color ? 4 : 0)
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                        
                        // Start Button
                        Button {
                            let duration = selectedPreset == .custom
                                ? TimeInterval(customHours * 3600 + customMinutes * 60 + customSeconds)
                                : selectedPreset.duration
                            
                            onAdd(
                                name.isEmpty ? selectedPreset.rawValue : name,
                                duration,
                                selectedColor
                            )
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title3)
                                Text("start timer")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(theme.cornerRadius)
                            .shadow(color: .flavorlyPink.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .disabled(totalDuration == 0)
                        .opacity(totalDuration == 0 ? 0.6 : 1.0)
                    }
                    .padding()
                }
            }
            .navigationTitle("new timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.flavorlyPink)
                }
            }
        }
        .accentColor(.flavorlyPink)
    }
    
    private var totalDuration: TimeInterval {
        if selectedPreset == .custom {
            return TimeInterval(customHours * 3600 + customMinutes * 60 + customSeconds)
        } else {
            return selectedPreset.duration
        }
    }
    
    private func colorForTimerColor(_ color: TimerColor) -> Color {
        switch color {
        case .pink:
            return .flavorlyPink
        case .rose:
            return .flavorlyRose
        case .peach:
            return Color(red: 1.0, green: 0.8, blue: 0.6)
        case .lavender:
            return Color(red: 0.8, green: 0.7, blue: 1.0)
        }
    }
}

