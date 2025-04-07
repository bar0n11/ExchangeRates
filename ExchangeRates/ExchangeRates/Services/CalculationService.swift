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
            copy.rate = asset.symbol == BaseAsset.symbol ? 1.0 : currentRate
            
            let newDelta = calculatePercentageChange(current: currentRate, previous: previousRate)

            if !isApproximatelyEqual(copy.delta, newDelta) {
                copy.delta = newDelta
            }
            
            return copy
        }
    }
    
    private func calculatePercentageChange(current: Double?, previous: Double?) -> Double {
        guard let current, let previous, previous != 0 else { return 0 }
        return ((current - previous) / previous) * 100
    }
    
    private func isApproximatelyEqual(_ a: Double?, _ b: Double?, epsilon: Double = 0.01) -> Bool {
        guard let a, let b else { return false }
        return abs(a - b) < epsilon
    }
}
