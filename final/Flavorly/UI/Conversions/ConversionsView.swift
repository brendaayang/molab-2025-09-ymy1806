//
//  ConversionsView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct ConversionsView: View {
    @ObservedObject var viewModel: ConversionsViewModel
    @EnvironmentObject var theme: Theme
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Pink gradient background
                LinearGradient(
                    colors: [Color.flavorlyCream, Color.flavorlyPinkLight.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // TIMERS SECTION
                        timersSectionView
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Cute header with melody ABOVE the text
                        VStack(spacing: 20) { // Increased spacing
                            if viewModel.isListening {
                                GIFImage(name: "melody_working", contentMode: .scaleAspectFit)
                                    .frame(width: 120, height: 120)
                                    .padding(.top, 40) // More top padding
                            } else {
                                GIFImage(name: "melody_hearteyes", contentMode: .scaleAspectFit)
                                    .frame(width: 120, height: 120)
                                    .padding(.top, 40) // More top padding
                            }
                            
                            Text("ask me anything grace")
                                .font(Theme.Fonts.bakeryTitle2)
                                .foregroundColor(.flavorlyPink)
                        }
                        
                        // Input card - PINK!
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("vat need ?")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                
                                Spacer()
                                
                                // Clear button
                                if !viewModel.queryText.isEmpty {
                                    Button {
                                        viewModel.queryText = ""
                                        viewModel.result = nil
                                        viewModel.errorMessage = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.flavorlyPink)
                                            .font(.title3)
                                    }
                                }
                            }
                            
                            // Input field with mic button
                            HStack(spacing: 12) {
                                TextField("like '30 grams to cups'", text: $viewModel.queryText)
                                    .font(Theme.Fonts.bakeryBody)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(theme.smallCornerRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: theme.smallCornerRadius)
                                            .stroke(Color.flavorlyPink.opacity(0.3), lineWidth: 2)
                                    )
                                    .focused($isTextFieldFocused)
                                    .onSubmit {
                                        viewModel.convert()
                                    }
                                
                                // Mic button
                                Button {
                                    viewModel.startListening()
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                } label: {
                                    Image(systemName: viewModel.isListening ? "mic.fill" : "mic.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            Circle()
                                                .fill(viewModel.isListening ? Color.flavorlyRose : Color.flavorlyPink)
                                        )
                                        .shadow(color: .flavorlyPink.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                            }
                            
                            // Convert button - BIG
                            Button {
                                viewModel.convert()
                                isTextFieldFocused = false
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.title3)
                                    Text("convert")
                                        .font(Theme.Fonts.bakeryHeadline)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: .flavorlyPink.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(20)
                        .background(Color.flavorlyWhite)
                        .cornerRadius(theme.cornerRadius)
                        .shadow(color: .flavorlyPink.opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        // Result card - PINK!
                        if let result = viewModel.result {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.flavorlyRose)
                                        .font(.title2)
                                    Text("here you go!")
                                        .font(Theme.Fonts.bakeryHeadline)
                                        .foregroundColor(.flavorlyPinkDark)
                                }
                                
                                HStack(spacing: 16) {
                                    VStack(spacing: 4) {
                                        Text(result.original)
                                            .font(Theme.Fonts.bakeryTitle3)
                                            .foregroundColor(.flavorlyPinkDark)
                                        Text("from")
                                            .font(Theme.Fonts.bakeryCaption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.flavorlyPink)
                                    
                                    VStack(spacing: 4) {
                                        Text(result.converted)
                                            .font(Theme.Fonts.bakeryTitle3)
                                            .foregroundColor(.flavorlyRose)
                                        Text("to")
                                            .font(Theme.Fonts.bakeryCaption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: theme.smallCornerRadius)
                                        .fill(Color.flavorlyPinkLight.opacity(0.3))
                                )
                                
                                Text(result.explanation)
                                    .font(Theme.Fonts.bakeryCaption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(20)
                            .background(Color.flavorlyWhite)
                            .cornerRadius(theme.cornerRadius)
                            .shadow(color: .flavorlyRose.opacity(0.3), radius: 12, x: 0, y: 6)
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Error message
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 12) {
                                GIFImage(name: "angry_melody", contentMode: .scaleAspectFit)
                                    .frame(width: 40, height: 40)
                                Text(error)
                                    .font(Theme.Fonts.bakeryBody)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(theme.smallCornerRadius)
                        }
                        
                        // Quick examples - CUTE
                        VStack(alignment: .leading, spacing: 12) {
                            Text("try these:")
                                .font(Theme.Fonts.bakeryCaption)
                                .foregroundColor(.flavorlyPink)
                            
                            VStack(spacing: 8) {
                                exampleButton("30 grams to cups")
                                exampleButton("350 fahrenheit to celsius")
                                exampleButton("2 tablespoons to teaspoons")
                                exampleButton("4 ounces to grams")
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding()
                    .padding(.bottom, 100)
            }
        }
        .navigationTitle("tools")
        .navigationBarTitleDisplayMode(.large)
        .heartParticles() // Add heart particles when using tools
            .navigationViewStyle(.stack) // Add this to fix constraints
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done") {
                        isTextFieldFocused = false
                    }
                    .foregroundColor(.flavorlyPink)
                    .font(Theme.Fonts.bakeryBody)
                }
            }
        }
    }
    
    private func exampleButton(_ text: String) -> some View {
        Button {
            viewModel.queryText = text
            viewModel.convert()
        } label: {
            HStack {
                Text(text)
                    .font(Theme.Fonts.bakeryBody)
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
            }
            .foregroundColor(.flavorlyPink)
            .padding(14)
            .background(Color.flavorlyWhite)
            .cornerRadius(theme.smallCornerRadius)
            .shadow(color: .flavorlyPink.opacity(0.2), radius: 6, x: 0, y: 3)
        }
    }
    
    // MARK: - Timers Section
    
    private var timersSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("baking timers")
                        .font(Theme.Fonts.bakeryTitle3)
                        .foregroundColor(.flavorlyPinkDark)
                    
                    if !viewModel.activeTimers.isEmpty {
                        Text("\(viewModel.activeTimers.count) active")
                            .font(Theme.Fonts.bakeryCaption)
                            .foregroundColor(.flavorlyPink)
                    }
                }
                
                Spacer()
                
                // Add Timer Button
                Button {
                    viewModel.showingAddTimer = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("new timer")
                            .font(Theme.Fonts.bakeryBody)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(theme.smallCornerRadius)
                    .shadow(color: .flavorlyPink.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Active Timers List
            if viewModel.activeTimers.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Image("melody2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    VStack(spacing: 8) {
                        Text("no timers running :(")
                            .font(Theme.Fonts.bakeryHeadline)
                            .foregroundColor(.flavorlyPinkDark)
                        
                        Text("let's get baking 🎀")
                            .font(Theme.Fonts.bakeryBody)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.flavorlyWhite)
                .cornerRadius(theme.cornerRadius)
                .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.activeTimers) { timer in
                        TimerRowView(
                            timer: timer,
                            onPause: {
                                viewModel.pauseTimer(id: timer.id)
                            },
                            onResume: {
                                viewModel.resumeTimer(id: timer.id)
                            },
                            onRemove: {
                                viewModel.removeTimer(id: timer.id)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $viewModel.showingAddTimer) {
            AddTimerView(onAdd: { name, duration, color in
                viewModel.addTimer(name: name, duration: duration, color: color)
                viewModel.showingAddTimer = false
            })
            .environmentObject(theme)
        }
    }
}

