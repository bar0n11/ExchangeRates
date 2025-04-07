//
//  LatestRatesResponse.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

struct LatestRatesResponse: Decodable {
    let base: String
    let date: String
    let rates: [String: Double]
    
    func toLatestRates() -> LatestRates {
        LatestRates(
            base: base,
            date: date.toDate() ?? Date(),
            rates: rates.map { LatestRates.Rate(symbol: $0.key, rate: $0.value) }
        )
    }
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
}
