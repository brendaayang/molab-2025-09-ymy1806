//
//  AddPantryItemView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct AddPantryItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    
    @State private var name = ""
    @State private var quantity = 1.0
    @State private var unit = "cups"
    @State private var category: PantryCategory = .baking
    @State private var hasExpiration = false
    @State private var expirationDate = Date().addingTimeInterval(30 * 24 * 3600)
    @State private var lowStockThreshold = 1.0
    @State private var notes = ""
    
    let onAdd: (String, Double, String, PantryCategory, Date?, Double?, String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.flavorlyPinkLight.opacity(0.3), Color.flavorlyCream],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Cute Header
                        Image("melody2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.top, 20)
                        
                        Text("add to pantry")
                            .font(Theme.Fonts.bakeryTitle2)
                            .foregroundColor(.flavorlyPinkDark)
                        
                        // Name Field
                        VStack(alignment: .leading, spacing: 12) {
                            Text("item name")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextField("flour, sugar, butter...", text: $name)
                                .font(Theme.Fonts.bakeryBody)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .flavorlyPink.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        
                        // Category Selection - Large Icons
                        VStack(alignment: .leading, spacing: 12) {
                            Text("category")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(PantryCategory.allCases, id: \.self) { cat in
                                    Button {
                                        category = cat
                                    } label: {
                                        VStack(spacing: 12) {
                                            Text(categoryEmoji(for: cat))
                                                .font(.system(size: 50))
                                            
                                            Text(cat.rawValue)
                                                .font(Theme.Fonts.bakeryBody)
                                                .foregroundColor(category == cat ? .white : .flavorlyPink)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 120)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(category == cat ? Color.flavorlyPink : Color.white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.flavorlyPink, lineWidth: category == cat ? 3 : 1)
                                        )
                                        .shadow(color: .flavorlyPink.opacity(0.2), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Quantity Stepper - Large Buttons
                        VStack(alignment: .leading, spacing: 12) {
                            Text("quantity")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                                .padding(.horizontal)
                            
                            HStack(spacing: 20) {
                                // Minus Button
                                Button {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.flavorlyPink.opacity(0.8), Color.flavorlyPinkDark.opacity(0.8)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "minus")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // Quantity Display
                                VStack(spacing: 4) {
                                    Text("\(Int(quantity))")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.flavorlyPink)
                                    
                                    // Unit Picker
                                    Picker("Unit", selection: $unit) {
                                        ForEach(PantryUnit.allCases, id: \.self) { unitOption in
                                            Text(unitOption.rawValue)
                                                .font(Theme.Fonts.bakeryBody)
                                                .tag(unitOption.rawValue)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .font(Theme.Fonts.bakeryBody)
                                    .tint(.flavorlyPink)
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Plus Button
                                Button {
                                    quantity += 1
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                            .shadow(color: .flavorlyPink.opacity(0.4), radius: 4, x: 0, y: 2)
                                        
                                        Image(systemName: "plus")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Optional Expiration
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $hasExpiration) {
                                Text("add expiration date?")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                            }
                            .tint(.flavorlyPink)
                            
                            if hasExpiration {
                                DatePicker("expires on", selection: $expirationDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .font(Theme.Fonts.bakeryBody)
                                    .tint(.flavorlyPink)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .flavorlyPink.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Big Add Button
                        Button {
                            let expiration = hasExpiration ? expirationDate : nil
                            onAdd(name, quantity, unit, category, expiration, lowStockThreshold, notes)
                        } label: {
                            Text("add to pantry")
                                .font(Theme.Fonts.bakeryTitle3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    LinearGradient(
                                        colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: .flavorlyPink.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.flavorlyPink)
                    }
                }
            }
        }
        .accentColor(.flavorlyPink)
    }
    
    private func categoryEmoji(for category: PantryCategory) -> String {
        switch category {
        case .baking: return "🍰"
        case .dairy: return "🥚"
        case .pantry: return "🧈"
        case .fresh: return "🥬"
        }
    }
}
