//
//  OrderListView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct OrderListView: View {
    @ObservedObject var viewModel: OrderListViewModel
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flavorlyCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: theme.spacing) {
                        // Revenue Card
                        RevenueCardView(
                            totalRevenue: viewModel.totalRevenue,
                            pendingRevenue: viewModel.pendingRevenue,
                            orderCount: viewModel.orders.count
                        )
                        
                        // Divider
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Status Filter
                        StatusFilterView(selectedStatus: $viewModel.filterStatus)
                            .padding(.bottom, 12)
                        
                        // Orders List
                        if viewModel.filteredOrders.isEmpty {
                            if viewModel.filterStatus != nil {
                                // Filtered empty state
                                VStack(spacing: 32) {  // Use actual spacing, not 0
                                    // GIF ABOVE everything - smaller size
                                    GIFImage(name: "melody_working", contentMode: .scaleAspectFit)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                        .background(Color.clear)
                                    
                                    // Text content below
                                    VStack(spacing: 12) {
                                        Text("no \(viewModel.filterStatus?.rawValue.lowercased() ?? "filtered") orders")
                                            .font(Theme.Fonts.bakeryTitle3)
                                            .foregroundColor(.flavorlyPinkDark)
                                        
                                        Text("try a different filter")
                                            .font(Theme.Fonts.bakeryBody)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(24)
                                .frame(maxWidth: .infinity)
                                .background(Color.flavorlyWhite)
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                                .padding(.top, 40)
                            } else {
                                // No orders at all
                                emptyStateView
                                    .padding(.top, 40)
                            }
                        } else {
                            ForEach(viewModel.filteredOrders) { order in
                                NavigationLink {
                                    OrderDetailView(
                                        viewModel: OrderDetailViewModel(
                                            orderService: viewModel.orderService
                                        ),
                                        order: order
                                    )
                                } label: {
                                    OrderRowView(order: order)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("my bakery")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddOrder = true
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
            .sheet(isPresented: $viewModel.showingAddOrder) {
                AddOrderView { customerName, itemName, quantity, price, fulfillmentDate, deliveryMethod, phone, address, notes in
                    viewModel.addOrder(
                        customerName: customerName,
                        itemName: itemName,
                        quantity: quantity,
                        price: price,
                        fulfillmentDate: fulfillmentDate,
                        deliveryMethod: deliveryMethod,
                        phone: phone,
                        address: address,
                        notes: notes
                    )
                    viewModel.showingAddOrder = false
                }
            }
            .fullScreenCover(isPresented: $viewModel.showVampireCouple) {
                VampireCoupleEasterEgg()
            }
            .fullScreenCover(isPresented: $viewModel.showAviArms) {
                AviArmsEasterEgg()
            }
        }
        .accentColor(.flavorlyPink) // Apply accent color OUTSIDE NavigationView
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 30) { // Increased spacing to prevent clipping
            GIFImage(name: "melody_eating2", contentMode: .scaleAspectFit)
                .frame(width: 140, height: 140)
            
            Text("no orders yet!")
                .font(Theme.Fonts.bakeryTitle2)
                .foregroundColor(.flavorlyPinkDark)
            
            Text("grace add your first damn order")
                .font(Theme.Fonts.bakeryBody)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20) // Extra horizontal padding
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 80) // Increased top padding
    }
}

struct StatusFilterView: View {
    @Binding var selectedStatus: OrderStatus?
    @EnvironmentObject var theme: Theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                FilterChip(title: "All", icon: "list.bullet", isSelected: selectedStatus == nil) {
                    selectedStatus = nil
                }
                
                ForEach(OrderStatus.allCases, id: \.self) { status in
                    FilterChip(title: status.rawValue, icon: status.icon, isSelected: selectedStatus == status) {
                        selectedStatus = status
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
