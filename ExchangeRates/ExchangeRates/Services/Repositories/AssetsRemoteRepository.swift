//
//  AssetsRemoteRepository.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

protocol AssetsRemoteRepositoryInterface {
    func getAvailableAssets() async throws -> [CurrencyAsset]
}

final class AssetsRemoteRepository: AssetsRemoteRepositoryInterface {
    private let client: HTTPClient
    
    init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }
    
    func getAvailableAssets() async throws -> [CurrencyAsset] {
        let dict: [String: String] = try await client.request(endpoint: "/currencies")
        return dict
            .map { CurrencyAsset(symbol: $0.key, name: $0.value) }
            .sorted { $0.symbol < $1.symbol }
    }
}
