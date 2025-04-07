//
//  AssetsService.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

protocol AssetsServiceInterface {
    func getAllAvailableAssets() async throws -> [CurrencyAsset]
    func add(assets: [CurrencyAsset]) throws
}

final class AssetsService: AssetsServiceInterface {
    private let localRepository: AssetsLocalRepositoryInterface
    private let remoteRepository: AssetsRemoteRepositoryInterface

    init() {
        self.localRepository = AssetsLocalRepository(store: AssetsStore())
        self.remoteRepository = AssetsRemoteRepository()
    }
    
    func getAllAvailableAssets() async throws -> [CurrencyAsset] {
        try await remoteRepository.getAvailableAssets()
    }
    
    func add(assets: [CurrencyAsset]) throws {
        try localRepository.add(assets: assets)
    }
}
