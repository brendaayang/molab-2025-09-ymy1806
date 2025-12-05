//
//  ExpiredItemsSheet.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct ExpiredItemsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    
    let items: [PantryItem]
    let lastLoginDate: Date?
    let onUseItem: (UUID) -> Void
    let onDeleteItem: (UUID) -> Void
    
    var expiredItems: [PantryItem] {
        items.filter { $0.isExpired }
            .sorted { ($0.expirationDate ?? Date()) > ($1.expirationDate ?? Date()) }
    }
    
    var expiringSoonItems: [PantryItem] {
        items.filter { $0.isExpiringSoon && !$0.isExpired }
            .sorted { ($0.expirationDate ?? Date()) < ($1.expirationDate ?? Date()) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Pink gradient background
                LinearGradient(
                    colors: [Color.flavorlyPinkLight.opacity(0.3), Color.flavorlyCream],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image("melody_working")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                            
                            Text("items that expired!")
                                .font(Theme.Fonts.bakeryTitle2)
                                .foregroundColor(.flavorlyPinkDark)
                        }
                        .padding(.top, 20)
                        
                        // Expired Section
                        if !expiredItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("expired (\(expiredItems.count))")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                                
                                ForEach(expiredItems) { item in
                                    ExpiredItemCard(
                                        item: item,
                                        isNewSinceLogin: isNewSinceLastLogin(item),
                                        onUse: { onUseItem(item.id) },
                                        onDelete: { onDeleteItem(item.id) }
                                    )
                                }
                            }
                        }
                        
                        // Expiring Soon Section
                        if !expiringSoonItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("expiring soon (\(expiringSoonItems.count))")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal)
                                
                                ForEach(expiringSoonItems) { item in
                                    ExpiredItemCard(
                                        item: item,
                                        isNewSinceLogin: false,
                                        onUse: { onUseItem(item.id) },
                                        onDelete: { onDeleteItem(item.id) }
                                    )
                                }
                            }
                        }
                        
                        // Empty State
                        if expiredItems.isEmpty && expiringSoonItems.isEmpty {
                            VStack(spacing: 20) {
                                Image("melody2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120)
                                
                                Text("all fresh!")
                                    .font(Theme.Fonts.bakeryTitle3)
                                    .foregroundColor(.flavorlyPinkDark)
                            }
                            .padding(.top, 60)
                        }
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
    
    private func isNewSinceLastLogin(_ item: PantryItem) -> Bool {
        guard let lastLogin = lastLoginDate,
              let expiration = item.expirationDate else { return false }
        return expiration < Date() && expiration > lastLogin
    }
}

struct ExpiredItemCard: View {
    let item: PantryItem
    let isNewSinceLogin: Bool
    let onUse: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji Icon
            Text(categoryEmoji(for: item.category))
                .font(.system(size: 44))
            
            // Item Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(Theme.Fonts.bakeryHeadline)
                    .foregroundColor(.flavorlyPinkDark)
                
                Text(expirationText)
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(expirationColor)
                
                if isNewSinceLogin {
                    HStack(spacing: 4) {
                        Text("⚠️")
                            .font(.caption2)
                        Text("new since your last visit")
                            .font(Theme.Fonts.bakeryCaption)
                            .foregroundColor(.flavorlyPink)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.flavorlyPinkLight.opacity(0.3))
                    .cornerRadius(8)
                }
                
                Text("\(Int(item.quantity)) \(item.unit) remaining")
                    .font(Theme.Fonts.bakeryCaption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 8) {
                Button {
                    onUse()
                } label: {
                    Text("use it")
                        .font(Theme.Fonts.bakeryCaption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.flavorlyPink)
                        .cornerRadius(12)
                }
                
                Button {
                    onDelete()
                } label: {
                    Text("toss it")
                        .font(Theme.Fonts.bakeryCaption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: isNewSinceLogin ? .flavorlyPink.opacity(0.3) : .gray.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private func categoryEmoji(for category: PantryCategory) -> String {
        switch category {
        case .baking: return "🍰"
        case .dairy: return "🥚"
        case .pantry: return "🧈"
        case .fresh: return "🥬"
        }
    }
    
    private var expirationText: String {
        guard let expirationDate = item.expirationDate else { return "" }
        let days = Calendar.current.dateComponents([.day], from: expirationDate, to: Date()).day ?? 0
        
        if item.isExpired {
            if days == 0 {
                return "expired today"
            } else if days == 1 {
                return "expired 1 day ago"
            } else {
                return "expired \(days) days ago"
            }
        } else {
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
            if daysLeft == 0 {
                return "expires today!"
            } else if daysLeft == 1 {
                return "expires tomorrow"
            } else {
                return "expires in \(daysLeft) days"
            }
        }
    }
    
    private var expirationColor: Color {
        if item.isExpired {
            return .red
        } else if item.isExpiringSoon {
            return .orange
        }
        return .green
    }
}

