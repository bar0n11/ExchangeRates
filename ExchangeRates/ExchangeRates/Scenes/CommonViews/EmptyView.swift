//
//  EmptyView.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import SwiftUI

struct EmptyView: View {
    var title = ""
    var image = "square.stack"
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundStyle(.gray)
            Text(title)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea()
    }
}

#Preview {
    EmptyView()
}
