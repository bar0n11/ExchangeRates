//
//  CalculationService.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

protocol CalculationServiceInterface {
    func calculate(cahcedAssets: [CurrencyAsset], with newRates: LatestRates) -> [CurrencyAsset]
}

final class CalculationService: CalculationServiceInterface {
    func calculate(cahcedAssets: [CurrencyAsset], with newRates: LatestRates) -> [CurrencyAsset] {
        return cahcedAssets.map { asset in
            let currentRate = newRates.rates.first { $0.symbol == asset.symbol }?.rate
            let previousRate = asset.rate

            guard currentRate != previousRate else { return asset }
            
            var copy = asset
            copy.rate = currentRate
            copy.delta = 0.0
            return copy
        }
    }
}
