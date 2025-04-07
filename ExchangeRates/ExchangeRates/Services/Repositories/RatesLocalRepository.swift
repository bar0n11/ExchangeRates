//
//  RatesLocalRepository.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

protocol RatesLocalRepositoryInterface {
    func getAllAssets() throws -> [CurrencyAsset]
    func save(assets: [CurrencyAsset]) throws
    func delete(asset: CurrencyAsset) throws
    func getLastUpdatedDate() -> Date?
}

final class RatesLocalRepository: RatesLocalRepositoryInterface {
    private let lastUpdatedKey = "lastUpdatedDate"
    private let store: AssetsStoreInterface

    init(store: AssetsStoreInterface) {
        self.store = store
    }

    func getAllAssets() throws -> [CurrencyAsset] {
        try store.getAllAssets()
    }
    
    func save(assets: [CurrencyAsset]) throws {
        try store.add(assets: assets)
        UserDefaults.standard.set(Date(), forKey: lastUpdatedKey)
    }
    
    func delete(asset: CurrencyAsset) throws {
        try store.delete(asset: asset)
    }
    
    func getLastUpdatedDate() -> Date? {
        UserDefaults.standard.object(forKey: lastUpdatedKey) as? Date
    }
}
