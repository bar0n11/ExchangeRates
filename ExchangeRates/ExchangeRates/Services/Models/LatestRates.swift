//
//  LatestRates.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

struct LatestRates {
    struct Rate {
        let symbol: String
        let rate: Double
    }
    
    let base: String
    let date: Date
    let rates: [Rate]
}
