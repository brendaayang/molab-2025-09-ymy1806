//
//  OrderRowView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct OrderRowView: View {
    let order: Order
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(order.customerName.lowercased())
                        .font(Theme.Fonts.bakeryHeadline)
                        .foregroundColor(.flavorlyPinkDark)
                    
                    if !order.isPaid {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
                
                Text(order.itemName.lowercased())
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    // Status capsule - CUTE!
                    HStack(spacing: 6) {
                        Image(systemName: order.status.icon)
                            .font(.caption)
                        Text(order.status.rawValue.lowercased())
                            .font(Theme.Fonts.bakeryCaption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(order.status.color)
                            .shadow(color: order.status.color.opacity(0.4), radius: 4, y: 2)
                    )
                    
                    // Delivery method - cute
                    HStack(spacing: 4) {
                        Image(systemName: order.deliveryMethod.icon)
                            .font(.caption2)
                        Text(order.deliveryMethod.rawValue.lowercased())
                            .font(Theme.Fonts.bakeryCaption)
                    }
                    .foregroundColor(.flavorlyPink)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("$\(order.totalPrice.formatted())")
                    .font(Theme.Fonts.priceFont)
                    .foregroundColor(.flavorlyPinkDark)
                
                if let date = order.fulfillmentDate {
                    Text(date, style: .date)
                        .font(Theme.Fonts.bakeryCaption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundColor(.flavorlyPink.opacity(0.5))
            }
        }
        .padding(16)
        .background(Color.flavorlyWhite)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: .flavorlyPink.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

