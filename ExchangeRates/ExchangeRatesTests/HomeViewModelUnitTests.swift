//
//  HomeViewModelUnitTests.swift
//  ExchangeRatesTests
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Testing
import Foundation
@testable import ExchangeRates

struct HomeViewModelUnitTests {
    private let testAssets = [
        CurrencyAsset(symbol: "USD", name: "US Dollar", rate: 1.0, delta: 0.0),
        CurrencyAsset(symbol: "EUR", name: "Euro", rate: 0.9, delta: 0.01)
    ]
    
    @Test
    func getModelsWithAutoRefresh_WhenSuccess_ShouldUpdateModels() async {
        // Given
        let (viewModel, mocks) = makeSUT()
        let testDate = Date()
        mocks.service.cachedRatesToReturn = testAssets
        mocks.service.getLatestRatesToReturn = testAssets
        mocks.service.getLastUpdatedDateToReturn = testDate
        
        // When
        viewModel.getModelsWithAutoRefresh()
        
        // Then
        await waitForAsyncOperation()
        #expect(!viewModel.isLoading)
        #expect(viewModel.models == testAssets)
        #expect(viewModel.latestUpdate == testDate)
        #expect(viewModel.error == nil)

        sleep(5)
        #expect(!viewModel.isLoading)
        #expect(viewModel.models == testAssets)
        #expect(viewModel.latestUpdate == testDate)
        #expect(viewModel.error == nil)
        #expect(mocks.service.getLatestRatesCallCounter == 2)
    }
    
    @Test
    func getModelsWithAutoRefresh_ShouldInvalidatePreviousTimer() {
        // Given
        let (viewModel, mocks) = makeSUT()
        
        // When
        viewModel.getModelsWithAutoRefresh()
        
        // Then
        #expect(mocks.timer.invalidateCalled)
    }
    
    @Test
    func getModelsWithAutoRefresh_ShouldFirstSetCachedThenLatest() async {
        // Given
        let (viewModel, mocks) = makeSUT()
        let cachedRates = [
            CurrencyAsset(symbol: "EUR", name: "Euro", rate: 0.9, delta: 0.01)
        ]
        let latestRates = [
            CurrencyAsset(symbol: "EUR", name: "Euro", rate: 0.9, delta: 0.02)
        ]
        mocks.service.cachedRatesToReturn = cachedRates
        mocks.service.getLatestRatesToReturn = latestRates
        
        // When
        viewModel.getModelsWithAutoRefresh()
        
        // Then
        #expect(viewModel.models == cachedRates)
        #expect(mocks.service.getCachedRatesCalled)
        await waitForAsyncOperation()
        #expect(viewModel.models == latestRates)
    }
    
    @Test
    func getModelsWithAutoRefresh_WhenError_ShouldSetError() async {
        // Given
        let (viewModel, mocks) = makeSUT()
        let testError = NSError(domain: "test", code: 500)
        mocks.service.getLatestRatesError = testError
        
        // When
        viewModel.getModelsWithAutoRefresh()
        
        // Then
        await waitForAsyncOperation()
        #expect(!viewModel.isLoading)
        #expect(viewModel.models.isEmpty)
        #expect(viewModel.error != nil)
        #expect(viewModel.error?.localizedDescription == testError.localizedDescription)
    }
    
    @Test
    func getModelsWithAutoRefresh_ShouldStartTimer() {
        // Given
        let (viewModel, mocks) = makeSUT()
        
        // When
        viewModel.getModelsWithAutoRefresh()
        
        // Then
        #expect(mocks.timer.scheduleCalled)
        #expect(mocks.timer.scheduledTimeInterval == 5)
        #expect(mocks.timer.scheduledRepeats == true)
    }
    
    @Test
    func delete_WhenSuccess_ShouldRemoveAssetFromModels() {
        // Given
        let (viewModel, _) = makeSUT()
        viewModel.models = [testAssets[0]]

        // When
        viewModel.delete(at: 0)

        // Then
        #expect(viewModel.models.isEmpty)
        #expect(viewModel.error == nil)
    }

    @Test
    func delete_WhenError_ShouldSetError() {
        // Given
        let (viewModel, mocks) = makeSUT()
        let testError = NSError(domain: "DeleteError", code: 1)
        viewModel.models = [testAssets[0]]
        mocks.service.deleteError = testError

        // When
        viewModel.delete(at: 0)

        // Then
        #expect(viewModel.models.count == 1)
        #expect(viewModel.error != nil)
        #expect(viewModel.error?.localizedDescription == testError.localizedDescription)
    }
    
    struct Mocks {
        let service: MockRatesService
        let timer: MockTimer
    }
    
    func makeSUT(file: StaticString = #file,
                 line: UInt = #line) -> (HomeViewModel, Mocks) {
        let mockTimer = MockTimer()
        let mockService = MockRatesService()
        let sut = HomeViewModel(service: mockService, timer: mockTimer)
        let mocks = Mocks(service: mockService, timer: mockTimer)
        return (sut, mocks)
    }
}

// MARK: - Mocks

final class MockRatesService: RatesServiceInterface {
    var cachedRatesToReturn: [CurrencyAsset] = []

    var getCachedRatesCalled = false
    
    func getCachedRates() -> [CurrencyAsset] {
        getCachedRatesCalled = true
        return cachedRatesToReturn
    }

    var getLatestRatesCallCounter = 0
    var getLatestRatesToReturn: [CurrencyAsset] = []
    var getLatestRatesError: Error? = nil
    
    func getLatestRates() async throws -> [CurrencyAsset] {
        if let error = getLatestRatesError { throw error }
        getLatestRatesCallCounter += 1
        return getLatestRatesToReturn
    }
    
    var getLastUpdatedDateToReturn: Date? = nil

    func getLastUpdatedDate() -> Date? {
        getLastUpdatedDateToReturn
    }
    
    var deleteError: Error? = nil
    
    func delete(asset: CurrencyAsset) throws {
        if let error = deleteError { throw error }
    }
}

final class MockTimer: TimerInterface {
    var scheduleCalled = false
    var scheduledTimeInterval: TimeInterval?
    var scheduledRepeats: Bool?
    var scheduledBlock: (() -> Void)?

    func schedule(timeInterval: TimeInterval, repeats: Bool, closure: @escaping () -> Void) {
        scheduleCalled = true
        scheduledTimeInterval = timeInterval
        scheduledRepeats = repeats
        scheduledBlock = closure
        sleep(5)
        scheduledBlock?()
    }

    var invalidateCalled = false

    func invalidate() {
        invalidateCalled = true
    }
}
