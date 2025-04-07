//
//  RatesRemoteRepository.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

enum BaseAsset {
    static let symbol = "USD"
}

protocol RatesRemoteRepositoryInterface {
    func getLatestRates(target: [String]) async throws -> LatestRates
}

final class RatesRemoteRepository: RatesRemoteRepositoryInterface {
    enum Error: LocalizedError {
        case emptyTargetCurrencies
        
        var errorDescription: String? {
            switch self {
            case .emptyTargetCurrencies: return "No target currencies provided"
            }
        }
    }

    private let client: HTTPClient
    
    init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }
    
    func getLatestRates(target: [String]) async throws -> LatestRates {
        guard !target.isEmpty else {
            throw Error.emptyTargetCurrencies
        }
        
        let response: LatestRatesResponse = try await client.request(
            endpoint: "/latest",
            queryItems: [
                URLQueryItem(name: "base", value: BaseAsset.symbol),
                URLQueryItem(name: "symbols", value: target.joined(separator: ","))
            ]
        )
        
        return response.toLatestRates()
    }
}
