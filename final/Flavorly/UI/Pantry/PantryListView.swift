//
//  PantryListView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

// Custom thought bubble shape with triangle tail on LEFT side
struct ThoughtBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Main rounded rectangle body
        let mainRect = CGRect(
            x: 0,
            y: 0,
            width: rect.width,
            height: rect.height
        )
        
        // Simple rounded rectangle (no triangle)
        path.addRoundedRect(
            in: mainRect,
            cornerSize: CGSize(width: 20, height: 20),
            style: .continuous
        )
        
        return path
    }
}

struct PantryListView: View {
    @ObservedObject var viewModel: PantryListViewModel
    @EnvironmentObject var theme: Theme
    @State private var showingExpiredSheet = false
    
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
                    VStack(spacing: 16) {
                        // Melody Filter System
                        if viewModel.lowStockCount > 0 || viewModel.expiringCount > 0 {
                            melodyFilterBubble
                                .padding(.top, 8)
                        }
                        
                        // Items Grid with Shelves
                        if viewModel.filteredItems.isEmpty {
                            emptyStateView
                        } else {
                            shelfView
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("my pantry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddItem = true
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
                                .frame(width: 36, height: 36)
                                .shadow(color: .flavorlyPink.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddItem) {
                AddPantryItemView(onAdd: { name, quantity, unit, category, expiration, threshold, notes in
                    viewModel.addItem(
                        name: name,
                        quantity: quantity,
                        unit: unit,
                        category: category,
                        expirationDate: expiration,
                        lowStockThreshold: threshold,
                        notes: notes
                    )
                    viewModel.showingAddItem = false
                })
                .environmentObject(theme)
            }
            .sheet(isPresented: $showingExpiredSheet) {
                ExpiredItemsSheet(
                    items: viewModel.items,
                    lastLoginDate: AppLoginService.shared.lastLoginDate,
                    onUseItem: { id in
                        viewModel.useItem(id: id)
                    },
                    onDeleteItem: { id in
                        viewModel.deleteItem(id: id)
                    }
                )
                .environmentObject(theme)
            }
        }
        .accentColor(.flavorlyPink)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image("melody2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
            
            VStack(spacing: 16) {
                Text(emptyMessage)
                    .font(Theme.Fonts.bakeryTitle2)
                    .foregroundColor(.flavorlyPinkDark)
                
                Text("tap + to add items")
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.flavorlyPink)
            }
            
            Button {
                viewModel.showingAddItem = true
            } label: {
                Text("add item")
                    .font(Theme.Fonts.bakeryHeadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var emptyMessage: String {
        if viewModel.showLowStockOnly {
            return "no low stock items!"
        } else if viewModel.showExpiringOnly {
            return "nothing expiring soon!"
        } else {
            return "your pantry is empty!"
        }
    }
    
    // Shelf view with 4 columns and realistic shelving
    private var shelfView: some View {
        VStack(spacing: 0) {
            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                ZStack {
                    // Stronger wall backdrop with cartoon cracks
                    ZStack {
                        // Main wall with stronger color
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.88, blue: 0.82),  // Warm peachy beige
                                        Color(red: 0.88, green: 0.82, blue: 0.76)   // Darker tan
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        
                        // Border
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.7, green: 0.6, blue: 0.5).opacity(0.4), lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 0) {
                        // Items sitting on shelf (3 per row)
                        HStack(alignment: .bottom, spacing: 10) {
                            ForEach(itemsForRow(rowIndex)) { item in
                                PantryItemRow(item: item, viewModel: viewModel)
                                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                            }
                            
                            // Fill empty spots
                            ForEach(0..<(3 - itemsForRow(rowIndex).count), id: \.self) { _ in
                                Color.clear.frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                        
                        // Realistic 3D Shelf Plank
                        shelfPlank
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var numberOfRows: Int {
        let itemCount = viewModel.filteredItems.count
        return (itemCount + 2) / 3  // Round up for 3 columns
    }
    
    private func itemsForRow(_ rowIndex: Int) -> [PantryItem] {
        let startIndex = rowIndex * 3
        let endIndex = min(startIndex + 3, viewModel.filteredItems.count)
        guard startIndex < viewModel.filteredItems.count else { return [] }
        return Array(viewModel.filteredItems[startIndex..<endIndex])
    }
    
    
    private var shelfPlank: some View {
        ZStack(alignment: .bottom) {
            // Deep shadow underneath shelf (cast on wall)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.15))
                .frame(height: 4)
                .blur(radius: 4)
                .offset(y: 8)
                .padding(.horizontal, 8)
            
            // Main shelf board - thick and dimensional
            VStack(spacing: 0) {
                // Top edge highlight (light reflection)
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                
                // Main plank body with wood/pink gradient
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.82, green: 0.62, blue: 0.55),  // Light wood/pink tone
                                Color(red: 0.75, green: 0.55, blue: 0.48),  // Medium
                                Color(red: 0.68, green: 0.48, blue: 0.42)   // Darker edge
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 16)  // Thicker shelf for realism
                    .overlay(
                        // Wood grain texture simulation
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.02),
                                        Color.clear,
                                        Color.black.opacity(0.02)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                
                // Bottom shadow edge (depth)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.5, green: 0.35, blue: 0.3).opacity(0.6))
                    .frame(height: 2)
            }
            .overlay(
                // Front edge highlight (3D bevel)
                RoundedRectangle(cornerRadius: 3)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            
            // Shelf brackets/supports (varied orientations)
            HStack {
                shelfBracket(orientation: .left)
                Spacer()
                shelfBracket(orientation: .right)
            }
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, 4)
    }
    
    private func shelfBracket(orientation: BracketOrientation) -> some View {
        ZStack {
            // Bracket shadow
            Path { path in
                switch orientation {
                case .left:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 20))
                    path.addLine(to: CGPoint(x: 12, y: 20))
                case .right:
                    path.move(to: CGPoint(x: 12, y: 0))
                    path.addLine(to: CGPoint(x: 12, y: 20))
                    path.addLine(to: CGPoint(x: 0, y: 20))
                case .center:
                    path.move(to: CGPoint(x: 6, y: 0))
                    path.addLine(to: CGPoint(x: 6, y: 20))
                    path.addLine(to: CGPoint(x: 0, y: 20))
                    path.addLine(to: CGPoint(x: 12, y: 20))
                }
            }
            .fill(Color.black.opacity(0.2))
            .offset(x: orientation == .right ? -1 : 1, y: 1)
            
            // Main bracket (varied L-shapes)
            Path { path in
                switch orientation {
                case .left:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 20))
                    path.addLine(to: CGPoint(x: 12, y: 20))
                case .right:
                    path.move(to: CGPoint(x: 12, y: 0))
                    path.addLine(to: CGPoint(x: 12, y: 20))
                    path.addLine(to: CGPoint(x: 0, y: 20))
                case .center:
                    path.move(to: CGPoint(x: 6, y: 0))
                    path.addLine(to: CGPoint(x: 6, y: 20))
                    path.addLine(to: CGPoint(x: 0, y: 20))
                    path.addLine(to: CGPoint(x: 12, y: 20))
                }
            }
            .stroke(
                LinearGradient(
                    colors: [
                        Color(red: 0.6, green: 0.5, blue: 0.45),
                        Color(red: 0.5, green: 0.4, blue: 0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 3
            )
            
            // Decorative screw/nail (varied positions)
            Circle()
                .fill(Color(red: 0.4, green: 0.35, blue: 0.3))
                .frame(width: 4, height: 4)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                )
                .offset(
                    x: orientation == .right ? -2 : 2,
                    y: orientation == .center ? 6 : 4
                )
        }
        .frame(width: 12, height: 20)
        .offset(y: -4)
    }
    
    private enum BracketOrientation {
        case left, right, center
    }
    
    // Proper Melody thought bubble filter system
    private var melodyFilterBubble: some View {
        HStack(alignment: .top, spacing: 8) {
            // Melody character
            ZStack {
                // Soft glow behind Melody
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.flavorlyPink.opacity(0.3),
                                Color.flavorlyPink.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                
                // Melody standing
                Image("melody_stand")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
            }
            
            // Thought bubble trail (smallest to largest) - positioned lower
            HStack(spacing: 4) {
                // Small bubble (closest to Melody)
                Circle()
                    .fill(Color.flavorlyPink.opacity(0.4))
                    .frame(width: 6, height: 6)
                
                // Medium bubble
                Circle()
                    .fill(Color.flavorlyPink.opacity(0.6))
                    .frame(width: 10, height: 10)
                
                // Large bubble (closest to thought bubble)
                Circle()
                    .fill(Color.flavorlyPink.opacity(0.8))
                    .frame(width: 14, height: 14)
            }
            .offset(x: -8, y: 20)  // Moved lower, no triangle to align with
            
            // Cute thought bubble with triangle tail
            ZStack {
                // Custom thought bubble shape with triangle
                ThoughtBubbleShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.flavorlyPink.opacity(0.95),
                                Color.flavorlyPink.opacity(0.8),
                                Color.flavorlyPink.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        ThoughtBubbleShape()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.8),
                                        Color.flavorlyPinkDark.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .flavorlyPink.opacity(0.4), radius: 10, x: 0, y: 5)
                
                // Clear filter buttons (no ellipses)
                HStack(spacing: 16) {
                    // Low stock filter
                    if viewModel.lowStockCount > 0 {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.showLowStockOnly.toggle()
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text("⚠️")
                                    .font(.system(size: 20))
                                
                                Text("\(viewModel.lowStockCount)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.showLowStockOnly ? Color.white.opacity(0.3) : Color.clear)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Expiring filter
                    if viewModel.expiringCount > 0 {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingExpiredSheet = true
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text("🔴")
                                    .font(.system(size: 20))
                                
                                Text("\(viewModel.expiringCount)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(width: 140, height: 80)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .transition(.scale.combined(with: .opacity))
    }
}

