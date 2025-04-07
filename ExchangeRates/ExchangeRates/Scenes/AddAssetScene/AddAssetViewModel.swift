//
//  AddAssetViewModel.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

@Observable
final class AddAssetViewModel {
    var isLoading: Bool = false
    var models: [CurrencyAsset] = []
    var error: Error?

    private var allModels: [CurrencyAsset] = []
    private let service: AssetsServiceInterface

    init(service: AssetsServiceInterface = AssetsService()) {
        self.service = service
    }

    func getAvailableAssets() {
        isLoading = true
        error = nil
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let models = try await service.getAllAvailableAssets()
                
                await MainActor.run {
                    self.isLoading = false
                    self.allModels = models
                    self.models = models
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.error = error
                }
            }
        }
    }
    
    func add(symbols: [String]) {
        do {
            let assets = allModels.filter { symbols.contains($0.symbol) }
            try service.add(assets: assets)
        } catch {
            self.error = error
        }
    }
    
    func filterModels(searchText: String) {
        if searchText.isEmpty {
            models = allModels
        } else {
            models = allModels.filter {
                $0.symbol.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
