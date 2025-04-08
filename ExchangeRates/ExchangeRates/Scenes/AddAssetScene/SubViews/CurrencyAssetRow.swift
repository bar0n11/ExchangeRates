//
//  CurrencyAssetRow.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import SwiftUI

struct CurrencyAssetRow: View {
    let asset: CurrencyAsset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            CurrencyRow(asset: asset)
                .overlay(alignment: .trailing) {
                    selectionIndicator
                        .padding(.trailing, 16)
                }
        }
        .buttonStyle(.plain)
    }
    
    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color(.systemBlue) : Color.gray.opacity(0.3), lineWidth: 1.5)
                .frame(width: 24, height: 24)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(.systemBlue))
            }
        }
    }
}

#Preview {
    CurrencyAssetRow(
        asset: .init(symbol: "USD", name: "Dollar"),
        isSelected: true,
        action: {}
    )
}
