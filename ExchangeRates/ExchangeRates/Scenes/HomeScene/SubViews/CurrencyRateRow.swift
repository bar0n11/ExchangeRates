//
//  CurrencyRateRow.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import SwiftUI

struct CurrencyRateRow: View {
    let asset: CurrencyAsset
    let isLoading: Bool
        
    var body: some View {
        HStack {
            CurrencyRow(asset: asset)
                .overlay(alignment: .trailing) {
                    rateIndicator
                        .padding(.trailing, 16)
                }
        }
    }
    
    @ViewBuilder
    private var rateIndicator: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text(formattedRate)
                .font(.system(size: 14, weight: .medium))
            
            HStack(spacing: 2) {
                Text(formattedDelta)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .opacity(isLoading ? 0 : 1)
        .scaleEffect(isLoading ? 0.9 : 1)
        .animation(
            .easeInOut(duration: 0.6).delay(0.4),
            value: isLoading
        )
    }
    
    private var formattedRate: String {
        asset.rate?.formatted(.number.precision(.fractionLength(4))) ?? ""
    }
    
    private var formattedDelta: String {
        let delta = asset.delta ?? 0
        let sign = delta >= 0 ? "+" : ""
        let value = delta.formatted(.number.precision(.fractionLength(2)))
        return "\(sign)\(value)%"
    }
}

#Preview {
    CurrencyRateRow(
        asset: .init(symbol: "USD", name: "Dollar", rate: 1.2, delta: 0.0534444), isLoading: false
    )
    CurrencyRateRow(
        asset: .init(symbol: "EUR", name: "Euro", rate: 1.6, delta: -0.083), isLoading: false
    )
}
