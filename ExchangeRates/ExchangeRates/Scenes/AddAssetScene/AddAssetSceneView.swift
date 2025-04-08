//
//  AddAssetSceneView.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import SwiftUI

struct AddAssetSceneView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddAssetViewModel()
    @State private var searchText = ""
    @State private var selected: [String] = []
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.isLoading {
                loadingStateView
            } else {
                loadedStateView
            }
        }
        .animation(.easeIn(duration: 0.4), value: viewModel.isLoading)
        .navigationTitle("Add Asset")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !viewModel.models.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        addSymbols()
                        dismiss()
                    }
                    .disabled(selected.isEmpty)
                }
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search assets"
        )
        .onChange(of: searchText) { _, newValue in
            viewModel.filterModels(searchText: newValue)
        }
        .onAppear {
            getAvailableAssets()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "Unknown error")
        }
    }
    
    private var loadingStateView: some View {
        ProgressView()
            .scaleEffect(1.5)
    }
    
    @ViewBuilder
    private var loadedStateView: some View {
        if viewModel.models.isEmpty {
            emptyStateView
        } else {
            filledStateView
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        let title = searchText == "" ? "No assets available" : "No assets found"
        EmptyView(title: title)
    }
    
    private var filledStateView: some View {
        List {
            Section {
                ForEach(viewModel.models) { asset in
                    CurrencyAssetRow(
                        asset: asset,
                        isSelected: selected.contains(asset.symbol)
                    ) {
                        toggleSelection(for: asset.symbol)
                    }
                    .listRowInsets(EdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .opacity(viewModel.isLoading ? 0 : 1)
        .animation(.easeIn(duration: 0.4), value: viewModel.isLoading)
    }
    
    private func toggleSelection(for symbol: String) {
        if let index = selected.firstIndex(of: symbol) {
            selected.remove(at: index)
        } else {
            selected.append(symbol)
        }
    }
    
    private func getAvailableAssets() {
        viewModel.getAvailableAssets()
    }
    
    private func addSymbols() {
        viewModel.add(symbols: selected)
    }
}

#Preview {
    AddAssetSceneView()
}
