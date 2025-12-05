//
//  AddOrderView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct AddOrderView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    
    @State private var customerName = ""
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var price = ""
    @State private var fulfillmentDate = Date()
    @State private var hasFulfillmentDate = false
    @State private var deliveryMethod: DeliveryMethod = .pickup
    @State private var phone = ""
    @State private var address = ""
    @State private var notes = ""
    
    let onSave: (String, String, Int, Decimal, Date?, DeliveryMethod, String, String, String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flavorlyCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Cute header with My Melody
                        GIFImage(name: "melody_working", contentMode: .scaleAspectFit)
                            .frame(width: 100, height: 100)
                            .padding(.top)
                        
                        Text("let's add an order!")
                            .font(Theme.Fonts.bakeryTitle3)
                            .foregroundColor(.flavorlyPinkDark)
                        
                        // Customer Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("customer name")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextField("e.g., Sarah", text: $customerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Theme.Fonts.bakeryBody)
                        }
                        
                        // Item Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("item")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextField("e.g., Cupcakes", text: $itemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Theme.Fonts.bakeryBody)
                        }
                        
                        // Quantity & Price
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("quantity")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                
                                Stepper("\(quantity)", value: $quantity, in: 1...100)
                                    .font(Theme.Fonts.bakeryBody)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(theme.smallCornerRadius)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("price each")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                
                                TextField("$0.00", text: $price)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(Theme.Fonts.bakeryBody)
                            }
                        }
                        
                        // Fulfillment Date
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("set fulfillment date", isOn: $hasFulfillmentDate)
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                                .tint(.flavorlyPink)
                            
                            if hasFulfillmentDate {
                                DatePicker(
                                    "date",
                                    selection: $fulfillmentDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(.flavorlyPink)
                                .tint(.flavorlyPink)
                            }
                        }
                        
                        // Delivery Method
                        VStack(alignment: .leading, spacing: 8) {
                            Text("delivery method")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            HStack(spacing: 12) {
                                ForEach(DeliveryMethod.allCases, id: \.self) { method in
                                    Button {
                                        deliveryMethod = method
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: method.icon)
                                                .font(.system(size: 16))
                                            Text(method.rawValue.lowercased())
                                                .font(Theme.Fonts.bakeryBody)
                                        }
                                        .foregroundColor(deliveryMethod == method ? .white : .flavorlyPink)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            deliveryMethod == method
                                                ? LinearGradient(
                                                    colors: [Color.flavorlyPink, Color.flavorlyRose],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                                : LinearGradient(
                                                    colors: [Color.flavorlyWhite, Color.flavorlyWhite],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                        )
                                        .cornerRadius(theme.smallCornerRadius)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: theme.smallCornerRadius)
                                                .stroke(Color.flavorlyPink, lineWidth: deliveryMethod == method ? 0 : 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Phone
                        VStack(alignment: .leading, spacing: 8) {
                            Text("phone number")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextField("(555) 123-4567", text: $phone)
                                .keyboardType(.phonePad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Theme.Fonts.bakeryBody)
                        }
                        
                        // Address (if delivery)
                        if deliveryMethod == .delivery {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("delivery address")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                
                                TextField("123 Main St", text: $address)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(Theme.Fonts.bakeryBody)
                            }
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("notes")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextEditor(text: $notes)
                                .font(Theme.Fonts.bakeryBody)
                                .frame(height: 80)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(theme.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.smallCornerRadius)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.flavorlyPink)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let priceDecimal = Decimal(string: price) {
                            onSave(
                                customerName,
                                itemName,
                                quantity,
                                priceDecimal,
                                hasFulfillmentDate ? fulfillmentDate : nil,
                                deliveryMethod,
                                phone,
                                address,
                                notes
                            )
                        }
                    }
                    .foregroundColor(.flavorlyPink)
                    .fontWeight(.semibold)
                    .disabled(customerName.isEmpty || itemName.isEmpty || price.isEmpty)
                }
            }
        }
        .heartParticles() // Add heart particles when adding orders
    }
}

