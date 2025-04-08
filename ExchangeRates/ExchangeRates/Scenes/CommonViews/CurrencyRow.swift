//
//  CurrencyRow.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import SwiftUI

struct CurrencyRow: View {
    let asset: CurrencyAsset
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.black.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(asset.symbol.prefix(2))
                        .font(.system(size: 14, weight: .medium))
                )
                .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedSymbol)
                    .font(.system(size: 16, weight: .medium))
                Text(asset.name)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var formattedSymbol: String {
        asset.symbol == BaseAsset.symbol ? "\(asset.symbol) (Base)" : asset.symbol
    }
}

#Preview {
    CurrencyRow(asset: .init(symbol: "USD", name: "Dollar"))
    CurrencyRow(asset: .init(symbol: "EUR", name: "Euro"))
}
