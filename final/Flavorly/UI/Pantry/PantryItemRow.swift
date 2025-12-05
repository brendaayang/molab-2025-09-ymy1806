//
//  PantryItemRow.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

// Custom shape that combines jar lid and body as one unified piece
struct JarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        // Jar dimensions
        let jarWidth = width * 0.8
        let jarHeight = height * 0.85
        let cornerRadius = jarWidth * 0.13
        
        // Lid dimensions
        let lidWidth = jarWidth * 1.1
        let lidHeight = height * 0.06
        
        // Calculate positions
        let jarX = (width - jarWidth) / 2
        let jarY = height - jarHeight
        let lidX = (width - lidWidth) / 2
        let lidY = jarY - lidHeight * 0.3  // Lid sits properly ON the jar opening with slight offset
        
        var path = Path()
        
        // Create jar body with rounded corners (properly sized for lid overlap)
        let jarRect = CGRect(
            x: jarX,
            y: jarY,
            width: jarWidth,
            height: jarHeight - lidHeight * 0.2  // Minimal cut to allow lid to sit on top
        )
        
        // Jar body with rounded corners
        path.addRoundedRect(
            in: jarRect,
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius),
            style: .continuous
        )
        
        // Add lid that completely covers the jar opening
        let lidRect = CGRect(
            x: lidX,
            y: lidY,
            width: lidWidth,
            height: lidHeight
        )
        
        // Lid ellipse that sits ON the jar opening
        path.addEllipse(in: lidRect)
        
        return path
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct PantryItemRow: View {
    let item: PantryItem
    let viewModel: PantryListViewModel
    @EnvironmentObject var theme: Theme
    @State private var showingEditSheet = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var showActionMenu = false
    @State private var isRemoving = false
    
    // Break up complex view into computed properties for compiler
    private var jarBaseGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.95),
                Color.white.opacity(0.85),
                Color(red: 0.98, green: 0.98, blue: 1.0).opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var jarShineGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.6),
                Color.clear,
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .center
        )
    }
    
    private var jarBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.8),
                Color.flavorlyPink.opacity(0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var lidRimGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.4),
                Color.black.opacity(0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var lidKnobGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.8, green: 0.6, blue: 0.55),
                Color(red: 0.6, green: 0.4, blue: 0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var confirmButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Break up body into smaller views for compiler
    private var jarShapes: some View {
        Group {
            JarShape()
                .fill(jarBaseGradient)
            
            JarShape()
                .fill(jarShineGradient)
            
            JarShape()
                .stroke(jarBorderGradient, lineWidth: 2)
        }
    }
    
    private var lidDetails: some View {
        VStack(spacing: 0) {
            ZStack {
                // Lid shadow underneath
                Ellipse()
                    .fill(Color.black.opacity(0.15))
                    .blur(radius: 3)
                    .frame(height: 10)
                    .offset(y: 2)
                
                // Metal rim (screw threads look)
                Ellipse()
                    .stroke(lidRimGradient, lineWidth: 2)
                    .frame(height: 14)
                
                // Top rim highlight
                Ellipse()
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    .frame(height: 14)
                    .offset(y: -1)
                
                // Lid grip/knob
                Capsule()
                    .fill(lidKnobGradient)
                    .frame(width: 16, height: 6)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                    .offset(y: -6)
            }
            .frame(height: 18)
            .padding(.horizontal, 8)
            .zIndex(10)
            
            Spacer()
        }
    }
    
    private var jarContent: some View {
        VStack(spacing: 4) {
            Spacer().frame(height: 16)
            
            // Emoji badge
            Text(categoryEmoji(for: item.category))
                .font(.system(size: 32))
                .padding(.top, 8)
                .opacity(item.isLowStock ? 0.4 : 1.0)
            
            // Item Name
            Text(item.name)
                .font(Theme.Fonts.bakeryCaption)
                .foregroundColor(.flavorlyPinkDark)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(height: 16)
                .opacity(item.isLowStock ? 0.5 : 1.0)
            
            // Quantity
            VStack(spacing: -2) {
                Text("\(Int(item.quantity))")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.flavorlyPink)
                    .opacity(item.isLowStock ? 0.4 : 1.0)
                
                Text(item.unit)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .opacity(item.isLowStock ? 0.5 : 1.0)
            }
            .frame(height: 32)
            
            Spacer(minLength: 2)
            
            controlButtons
                .padding(.bottom, 16)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 8) {
            // Minus Button
            Button {
                viewModel.adjustQuantity(item: item, by: -1)
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.flavorlyPinkLight.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("−")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            // Plus Button
            Button {
                viewModel.adjustQuantity(item: item, by: 1)
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.flavorlyPink.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("+")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    private var confirmationModal: some View {
        Group {
            if showActionMenu {
                ZStack {
                    // Transparent background (tap to dismiss)
                    Color.clear
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showActionMenu = false
                            }
                        }
                    
                    // Simple confirmation modal
                    VStack(spacing: 20) {
                        Text("r u sure?")
                            .font(Theme.Fonts.bakeryTitle2)
                            .foregroundColor(.flavorlyPinkDark)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Just checkmark button - clicking outside cancels
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showActionMenu = false
                            }
                            removeWithAnimation()
                        } label: {
                            Text("✓")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(Circle().fill(confirmButtonGradient))
                                .shadow(color: .flavorlyPink.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(40)
                    .frame(minWidth: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 12)
                    )
                    .padding(.horizontal, 40)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    var body: some View {
        ZStack {
            jarShapes
            lidDetails
            jarContent
            
            // Warning overlay
            JarShape()
                .fill(warningOverlayColor)
        }
        .frame(height: 170)
        .scaleEffect(isRemoving ? 0.01 : 1.0)
        .opacity(isRemoving ? 0 : 1)
        .rotationEffect(.degrees(isRemoving ? 360 : 0))
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRemoving)
        .onTapGesture {
            showingEditSheet = true
        }
        .onLongPressGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showActionMenu = true
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPantryItemView(item: item, onUpdate: { updatedItem in
                viewModel.updateItem(updatedItem)
                showingEditSheet = false
            })
            .environmentObject(theme)
        }
        .overlay(confirmationModal)
    }
    
    private func removeWithAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            isRemoving = true
        }
        
        // Animate scale down and fade
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.deleteItem(id: item.id)
        }
    }
    
    // Natural warning overlay color (more visible)
    private var warningOverlayColor: Color {
        if isExpired {
            // Stronger brown/sepia tint for expired (more visible)
            return Color(red: 0.5, green: 0.35, blue: 0.25).opacity(0.25)
        } else if isExpiringSoon {
            // Stronger amber/honey tint for expiring soon
            return Color(red: 0.95, green: 0.75, blue: 0.35).opacity(0.22)
        } else if item.isLowStock {
            // Stronger frosted look for low stock
            return Color(red: 0.75, green: 0.78, blue: 0.82).opacity(0.18)
        }
        return Color.clear
    }
    
    private var isExpired: Bool {
        guard let expiration = item.expirationDate else { return false }
        return expiration < Date()
    }
    
    private var isExpiringSoon: Bool {
        guard let expiration = item.expirationDate else { return false }
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: expiration).day ?? 0
        return daysUntil > 0 && daysUntil <= 3
    }
    
    private func categoryEmoji(for category: PantryCategory) -> String {
        switch category {
        case .baking: return "🍰"
        case .dairy: return "🥚"
        case .pantry: return "🧈"
        case .fresh: return "🥬"
        }
    }
    
    private var daysUntilExpiration: Int? {
        guard let expirationDate = item.expirationDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day
        return days
    }
    
    private var expirationColor: Color {
        guard let days = daysUntilExpiration else { return .green }
        if days < 0 || item.isExpired { return .red }
        if days <= 3 { return .red }
        if days <= 7 { return .yellow }
        return .green
    }
    
    private func expirationText(days: Int) -> String {
        if days < 0 { return "expired" }
        if days == 0 { return "today!" }
        if days == 1 { return "1 day" }
        if days <= 7 { return "\(days) days" }
        return "fresh!"
    }
}
