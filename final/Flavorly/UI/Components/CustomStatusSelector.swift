//
//  CustomStatusSelector.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/19/25.
//

import SwiftUI

struct CustomStatusSelector<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == String {
    @Binding var selectedStatus: T
    let onChange: (T) -> Void
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(T.allCases), id: \.self) { status in
                    Button {
                        selectedStatus = status
                        onChange(status)
                    } label: {
                        Text(status.rawValue.lowercased())
                            .font(Theme.Fonts.bakeryBody)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedStatus == status ? .white : .flavorlyPink)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(selectedStatus == status ? Color.flavorlyPink : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.flavorlyPink, lineWidth: selectedStatus == status ? 0 : 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
}

