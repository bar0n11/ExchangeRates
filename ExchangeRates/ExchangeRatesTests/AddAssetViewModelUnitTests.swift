//
//  AddAssetViewModelUnitTests.swift
//  ExchangeRatesTests
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Testing
import Foundation
@testable import ExchangeRates

struct AddAssetViewModelUnitTests {
    private let testAssets = [
        CurrencyAsset(symbol: "USD", name: "US Dollar", rate: 1.0, delta: 0.0),
        CurrencyAsset(symbol: "EUR", name: "Euro", rate: 0.9, delta: 0.01)
    ]
    
    @Test
    func getAvailableAssets_WhenSuccess_ShouldUpdateModels() async {
        // Given
        let (viewModel, mockService) = makeSUT()
        mockService.getAllAvailableAssetsToReturn = testAssets
        
        // When
        viewModel.getAvailableAssets()
        await waitForAsyncOperation()
        
        // Then
        #expect(!viewModel.isLoading)
        #expect(viewModel.models == testAssets)
        #expect(viewModel.error == nil)
    }
    
    @Test
    func getAvailableAssets_WhenError_ShouldSetError() async {
        // Given
        let (viewModel, mockService) = makeSUT()
        let testError = NSError(domain: "test", code: 404)
        mockService.getAllAvailableAssetsError = testError
        
        // When
        viewModel.getAvailableAssets()
        await waitForAsyncOperation()

        // Then
        #expect(!viewModel.isLoading)
        #expect(viewModel.models.isEmpty)
        #expect(viewModel.error?.localizedDescription == testError.localizedDescription)
    }
    
    @Test
    func add_WhenSuccess_ShouldNotSetError() async {
        // Given
        let (viewModel, mockService) = makeSUT()
        mockService.getAllAvailableAssetsToReturn = testAssets

        // When
        viewModel.getAvailableAssets()
        await waitForAsyncOperation()
        viewModel.add(symbols: ["USD"])
        
        // Then
        #expect(mockService.addedAssets.map(\.symbol) == ["USD"])
        #expect(viewModel.error == nil)
    }

    @Test
    func add_WhenThrowsError_ShouldSetError() {
        // Given
        let (viewModel, mockService) = makeSUT()
        viewModel.models = [testAssets[0]]
        mockService.addError = NSError(domain: "test", code: 500)

        // When
        viewModel.add(symbols: ["USD"])

        // Then
        #expect(viewModel.error != nil)
        #expect(viewModel.error?.localizedDescription == mockService.addError?.localizedDescription)
    }
    
    @Test
    func filterModels_WhenEmptySearchText_ShouldShowAllModels() async {
        // Given
        let (viewModel, mockService) = makeSUT()
        mockService.getAllAvailableAssetsToReturn = testAssets

        // When
        viewModel.getAvailableAssets()
        await waitForAsyncOperation()
        viewModel.filterModels(searchText: "")

        // Then
        #expect(viewModel.models == testAssets)
    }

    @Test
    func filterModels_WhenTextMatchesSymbol_ShouldFilter() async {
        // Given
        let (viewModel, mockService) = makeSUT()
        mockService.getAllAvailableAssetsToReturn = testAssets

        // When
        viewModel.getAvailableAssets()
        await waitForAsyncOperation()
        viewModel.filterModels(searchText: "usd")

        // Then
        #expect(viewModel.models.count == 1)
        #expect(viewModel.models.first?.symbol == "USD")
    }
    
    @Test
    func filterModels_WhenTextMatchesName_ShouldFilter() async {
        // Given
        let (viewModel, mockService) = makeSUT()
        mockService.getAllAvailableAssetsToReturn = testAssets

        // When
        viewModel.getAvailableAssets()
        await waitForAsyncOperation()
        viewModel.filterModels(searchText: "euro")

        // Then
        #expect(viewModel.models.count == 1)
        #expect(viewModel.models.first?.symbol == "EUR")
    }

    func makeSUT(file: StaticString = #file,
                 line: UInt = #line) -> (AddAssetViewModel, MockAssetsService) {
        let mockService = MockAssetsService()
        let sut = AddAssetViewModel(service: mockService)
        return (sut, mockService)
    }
}

// MARK: - Mock

final class MockAssetsService: AssetsServiceInterface {
    var getAllAvailableAssetsToReturn: [CurrencyAsset] = []
    var getAllAvailableAssetsError: Error?

    func getAllAvailableAssets() async throws -> [CurrencyAsset] {
        if let error = getAllAvailableAssetsError {
            throw error
        }
        return getAllAvailableAssetsToReturn
    }

    var addedAssets: [CurrencyAsset] = []
    var addError: Error?

    func add(assets: [CurrencyAsset]) throws {
        if let error = addError {
            throw error
        }
        self.addedAssets = assets
    }
}
