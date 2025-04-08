//
//  HomeSceneView.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import SwiftUI

struct HomeSceneView: View {
    @State private var viewModel = HomeViewModel()
    @State private var isShowingAddAssetView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                loadedStateView
            }
            .animation(.easeIn(duration: 0.4), value: viewModel.isLoading)
            .navigationTitle("Exchange Rates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .navigationDestination(isPresented: $isShowingAddAssetView) {
                AddAssetSceneView()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "Unknown error")
        }
    }
    
    @ViewBuilder
    private var loadedStateView: some View {
        if viewModel.models.isEmpty {
            emptyStateView
        } else {
            filledStateView
        }
    }
    
    private var emptyStateView: some View {
        EmptyView(title: "No assets added")
            .onAppear(perform: onAppearLoad)
    }
    
    private var filledStateView: some View {
        List {
            Section(header: lastUpdatedView) {
                ForEach(Array(viewModel.models.enumerated()), id: \.element.id) { index, asset in
                    CurrencyRateRow(asset: asset, isLoading: viewModel.isLoading)
                        .listRowInsets(EdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            removeButton(for: index)
                        }
                }
            }
        }
        .listStyle(.plain)
        .padding(.horizontal, 0)
        .onAppear(perform: onAppearLoad)
        .refreshable {
            viewModel.getModelsWithAutoRefresh()
        }
    }
    
    private var lastUpdatedView: some View {
        let time = viewModel.latestUpdate?.formatted(date: .abbreviated, time: .standard) ?? "N/A"
        return Text("Last updated: \(time)")
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.clear)
    }
    
    private var addButton: some View {
        Button {
            isShowingAddAssetView = true
        } label: {
            Image(systemName: "plus")
        }
    }
    
    private func removeButton(for index: Int) -> some View {
        Button {
            withAnimation {
                viewModel.delete(at: index)
            }
        } label: {
            Image(systemName: "trash")
                .symbolVariant(.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.black, .clear)
        }
        .tint(.clear)
    }
    
    private func onAppearLoad() {
        viewModel.getModelsWithAutoRefresh()
    }
}

#Preview {
    HomeSceneView()
}
