//
//  CurrencyAsset.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

struct CurrencyAsset: Identifiable, Codable {
    var id: UUID = UUID()
    let symbol: String
    let name: String
    var rate: Double?
    var delta: Double?
}
