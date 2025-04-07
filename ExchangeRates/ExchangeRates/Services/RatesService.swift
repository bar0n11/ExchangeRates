//
//  RatesService.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

protocol RatesServiceInterface {
    func getCachedRates() -> [CurrencyAsset]
    func getLatestRates() async throws -> [CurrencyAsset]
    func getLastUpdatedDate() -> Date?
    func delete(asset: CurrencyAsset) throws
}

final class RatesService: RatesServiceInterface {
    private let localRepository: RatesLocalRepositoryInterface
    private let remoteRepository: RatesRemoteRepositoryInterface
    private let calculationService: CalculationServiceInterface
    
    init() {
        self.localRepository = RatesLocalRepository(store: AssetsStore())
        self.remoteRepository = RatesRemoteRepository()
        self.calculationService = CalculationService()
    }
    
    func getCachedRates() -> [CurrencyAsset] {
        let all = try? localRepository.getAllAssets()
        return all ?? []
    }
    
    func getLatestRates() async throws -> [CurrencyAsset] {
        let cached = getCachedRates()
        guard !cached.isEmpty else { return [] }
        let target = cached.map { $0.symbol }
        
        do {
            let newRates = try await remoteRepository.getLatestRates(target: target)
            let newAssets = calculationService.calculate(cahcedAssets: cached, with: newRates)
            try localRepository.save(assets: newAssets)
            return newAssets
        } catch {
            if !cached.isEmpty {
                return cached
            }
            throw error
        }
    }
    
    func getLastUpdatedDate() -> Date? {
        localRepository.getLastUpdatedDate()
    }
        
    func delete(asset: CurrencyAsset) throws {
        try localRepository.delete(asset: asset)
    }
}
