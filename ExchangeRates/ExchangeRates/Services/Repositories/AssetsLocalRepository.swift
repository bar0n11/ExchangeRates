//
//  AssetsLocalRepository.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

protocol AssetsLocalRepositoryInterface {
    func add(assets: [CurrencyAsset]) throws
}

final class AssetsLocalRepository: AssetsLocalRepositoryInterface {
    private let store: AssetsStoreInterface

    init(store: AssetsStoreInterface) {
        self.store = store
    }
    
    func add(assets: [CurrencyAsset]) throws {
        try store.add(assets: assets)
    }
}
