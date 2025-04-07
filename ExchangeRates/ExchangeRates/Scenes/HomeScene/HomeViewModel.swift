//
//  HomeViewModel.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

@Observable
final class HomeViewModel {
    var isLoading: Bool = false
    var models: [CurrencyAsset] = []
    var latestUpdate: Date?
    var error: Error?
    
    private let service: RatesServiceInterface
    private var timer: TimerInterface

    init(service: RatesServiceInterface = RatesService(),
         timer: TimerInterface = DefaultTimer()) {
        self.service = service
        self.timer = timer
        
//        // Oleg: Mocks
//        AssetsStore().mockPreviousDayAssets()
    }

    deinit {
        timer.invalidate()
    }
    
    func getModelsWithAutoRefresh() {
        timer.invalidate()
        getModels()
               
        timer.schedule(timeInterval: 5, repeats: true) { [weak self] in
            self?.getModels()
        }
    }
    
    func delete(at index: Int) {
        let model = models[index]
        do {
            try service.delete(asset: model)
            models.remove(at: index)
        } catch {
            self.error = error
        }
    }
        
    private func getModels() {
        isLoading = true
        models = service.getCachedRates()
        latestUpdate = service.getLastUpdatedDate()
        error = nil
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let rates = try await service.getLatestRates()
                let latestUpdate = service.getLastUpdatedDate()
                
                await MainActor.run {
                    self.isLoading = false
                    self.models = rates
                    self.latestUpdate = latestUpdate
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.error = error
                }
            }
        }
    }
}
