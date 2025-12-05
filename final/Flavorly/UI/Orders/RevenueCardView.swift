//
//  RevenueCardView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct RevenueCardView: View {
    let totalRevenue: Decimal
    let pendingRevenue: Decimal
    let orderCount: Int
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                // Total Earned
                VStack(alignment: .leading, spacing: 4) {
                    Text("total earned")
                        .font(Theme.Fonts.bakeryCaption)
                        .foregroundColor(.flavorlyPinkDark.opacity(0.8))
                    Text("$\(totalRevenue.formatted())")
                        .font(Theme.Fonts.priceFont)
                        .foregroundColor(.flavorlyPinkDark)
                }
                
                // Pending Revenue
                VStack(alignment: .leading, spacing: 4) {
                    Text("pending")
                        .font(Theme.Fonts.bakeryCaption)
                        .foregroundColor(.flavorlyPinkDark.opacity(0.8))
                    Text("$\(pendingRevenue.formatted())")
                        .font(Theme.Fonts.priceFont)
                        .foregroundColor(.flavorlyPinkDark)
                }
                
                // Order Count
                VStack(alignment: .leading, spacing: 4) {
                    Text("orders")
                        .font(Theme.Fonts.bakeryCaption)
                        .foregroundColor(.flavorlyPinkDark.opacity(0.8))
                    Text("\(orderCount)")
                        .font(Theme.Fonts.priceFont)
                        .foregroundColor(.flavorlyPinkDark)
                }
            }
            
            Spacer()
            
            // Melody GIF contained within the card
            GIFImage(name: "melody_cookie_ok", contentMode: .scaleAspectFit)
                .frame(width: 120, height: 120)
                .scaleEffect(1.2)
                .offset(x: 10, y: 10)
        }
        .padding(20)
        .background(Color.flavorlyWhite)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: .flavorlyPink.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

