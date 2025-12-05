//
//  FilterChip.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(Theme.Fonts.bakeryBody)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : .flavorlyPink)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.flavorlyPink : Color.flavorlyPinkLight.opacity(0.3))
            )
        }
    }
}

