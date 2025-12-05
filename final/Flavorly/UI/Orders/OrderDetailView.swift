//
//  OrderDetailView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct OrderDetailView: View {
    @ObservedObject var viewModel: OrderDetailViewModel
    @State var order: Order
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    
    init(viewModel: OrderDetailViewModel, order: Order) {
        self.viewModel = viewModel
        self.order = order
        viewModel.order = order
    }
    
    var body: some View {
        ZStack {
            Color.flavorlyCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header Card with Status
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(order.customerName)
                                        .font(Theme.Fonts.bakeryTitle2)
                                        .foregroundColor(.flavorlyPinkDark)
                                    
                                    Text(order.itemName)
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if order.status == .completed {
                                    Image("melody_heart")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                }
                            }
                            
                            // Status Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("status")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                
                                CustomStatusSelector(selectedStatus: Binding(
                                    get: { order.status },
                                    set: { newStatus in
                                        order.status = newStatus
                                    }
                                )) { newStatus in
                                    viewModel.updateStatus(to: newStatus)
                                }
                            }
                        }
                        .padding()
                        .background(Color.flavorlyWhite)
                        .cornerRadius(theme.cornerRadius)
                        .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        // Price Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("order details")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            HStack {
                                Text("quantity:")
                                    .font(Theme.Fonts.bakeryBody)
                                    .foregroundColor(.flavorlyPinkDark)
                                Spacer()
                                Text("\(order.quantity)")
                                    .font(Theme.Fonts.bakeryBody)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("price each:")
                                    .font(Theme.Fonts.bakeryBody)
                                    .foregroundColor(.flavorlyPinkDark)
                                Spacer()
                                Text("$\(order.price.formatted())")
                                    .font(Theme.Fonts.bakeryBody)
                                    .fontWeight(.semibold)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("total:")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                Spacer()
                                Text("$\(order.totalPrice.formatted())")
                                    .font(Theme.Fonts.priceFont)
                                    .foregroundColor(.flavorlyPinkDark)
                            }
                            
                            // Paid Toggle
                            Toggle("paid", isOn: Binding(
                                get: { order.isPaid },
                                set: { isPaid in
                                    order.isPaid = isPaid
                                    viewModel.togglePaidStatus()
                                }
                            ))
                            .font(Theme.Fonts.bakeryHeadline)
                            .tint(.flavorlyPink)
                        }
                        .padding()
                        .background(Color.flavorlyWhite)
                        .cornerRadius(theme.cornerRadius)
                        .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        // Delivery Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("delivery")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            HStack {
                                Image(systemName: order.deliveryMethod.icon)
                                Text(order.deliveryMethod.rawValue)
                                Spacer()
                            }
                            
                            if order.deliveryMethod == .delivery && !order.deliveryAddress.isEmpty {
                                HStack {
                                    Image(systemName: "map.fill")
                                    Text(order.deliveryAddress)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let date = order.fulfillmentDate {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(date, style: .date)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.flavorlyWhite)
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            
                            // Contact Info
                            if !order.customerPhone.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("contact")
                                        .font(Theme.Fonts.bakeryHeadline)
                                        .foregroundColor(.flavorlyPinkDark)
                                    
                                    Link(destination: URL(string: "tel:\(order.customerPhone)")!) {
                                        HStack {
                                            Image(systemName: "phone.fill")
                                            Text(order.customerPhone)
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                        }
                                        .foregroundColor(.flavorlyPink)
                                    }
                                }
                                .padding()
                                .background(Color.flavorlyWhite)
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            
                            // Notes
                            if !order.notes.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("notes")
                                        .font(Theme.Fonts.bakeryHeadline)
                                        .foregroundColor(.flavorlyPinkDark)
                                    
                                    Text(order.notes)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.flavorlyWhite)
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding()
                        .padding(.bottom, 100) // Add bottom padding for tab bar clearance
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            .onChange(of: order.isPaid) { _, isPaid in
                if isPaid {
                    // Show heart particles when order is marked as paid
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Heart particles will be triggered by the payment status change
                    }
                }
            }
        }
    }
}
