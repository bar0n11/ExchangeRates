//
//  AssetsStore.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

protocol AssetsStoreInterface {
    func getAllAssets() throws -> [CurrencyAsset]
    func add(assets: [CurrencyAsset]) throws
    func delete(asset: CurrencyAsset) throws
}

final class AssetsStore: AssetsStoreInterface {
    enum StoreError: LocalizedError {
        case alreadyExists([String])
        case notFound(String)
        case decodingError
        case encodingError
        
        var errorDescription: String? {
            switch self {
            case .alreadyExists(let symbols):
                return "Currencies already exist: \(symbols.joined(separator: ", "))"
            case .notFound(let symbol):
                return "Currency '\(symbol)' not found"
            case .decodingError:
                return "Failed to decode saved data"
            case .encodingError:
                return "Failed to encode data for saving"
            }
        }
    }
    
    private let fileURL: URL
    private let fileManager = FileManager.default
    private let jsonEncoder = JSONEncoder()
    
    init() {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documentsDirectory.appendingPathComponent("SavedAssets.json")
    }
    
    func getAllAssets() throws -> [CurrencyAsset] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([CurrencyAsset].self, from: data)
    }
    
    func add(assets: [CurrencyAsset]) throws {
        let currentAssets = try getAllAssets()
        var assetDict = Dictionary(uniqueKeysWithValues: currentAssets.map { ($0.symbol, $0) })
        for asset in assets {
            assetDict[asset.symbol] = asset
        }
        let updatedAssets = assetDict.values.sorted { $0.symbol.localizedCaseInsensitiveCompare($1.symbol) == .orderedAscending }
        try save(assets: updatedAssets)
    }
    
    func delete(asset: CurrencyAsset) throws {
        var currentAssets = try getAllAssets()
        guard let index = currentAssets.firstIndex(where: { $0.symbol == asset.symbol }) else {
            throw StoreError.notFound(asset.symbol)
        }
        
        currentAssets.remove(at: index)
        try save(assets: currentAssets)
    }
    
    private func save(assets: [CurrencyAsset]) throws {
        do {
            let data = try jsonEncoder.encode(assets)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            throw StoreError.encodingError
        }
    }
}
