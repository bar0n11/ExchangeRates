//
//  UnitTestHelpers.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Testing
import Foundation
@testable import ExchangeRates

func waitForAsyncOperation(timeout: UInt64 = 2_000_000_000) async {
    let interval: UInt64 = 100_000_000
    var waited: UInt64 = 0

    while waited < timeout {
        try? await Task.sleep(nanoseconds: interval)
        waited += interval
    }
}

extension CurrencyAsset: @retroactive Equatable {
    public static func == (lhs: CurrencyAsset, rhs: CurrencyAsset) -> Bool {
        lhs.id == rhs.id && lhs.symbol == rhs.symbol && lhs.name == rhs.name
    }
}

