//
//  MainViewModel.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: ProductCategory?
    @Published var searchResults: [Product] = []
    @Published var featuredProducts: [Product] = []
    @Published var bestDeals: [Product] = []
    @Published var shoppingTips: [ShoppingTip] = []
    @Published var showingSearchResults = false
    @Published var isRefreshing = false
    
    private let productService = ProductService.shared
    private let tipsService = ShoppingTipsService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadInitialData()
    }
    
    private func setupBindings() {
        // Bind to product service
        productService.$products
            .sink { [weak self] _ in
                self?.loadInitialData()
            }
            .store(in: &cancellables)
        
        // Search functionality
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.performSearch(query: searchText)
            }
            .store(in: &cancellables)
        
        // Category selection
        $selectedCategory
            .sink { [weak self] category in
                self?.performSearch(query: self?.searchText ?? "")
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        featuredProducts = productService.getFeaturedProducts()
        bestDeals = productService.getBestDeals()
        shoppingTips = tipsService.tips.prefix(3).map { $0 }
    }
    
    private func performSearch(query: String) {
        if query.isEmpty && selectedCategory == nil {
            searchResults = []
            showingSearchResults = false
        } else {
            searchResults = productService.searchProducts(query: query, category: selectedCategory)
            showingSearchResults = true
        }
    }
    
    func clearSearch() {
        searchText = ""
        selectedCategory = nil
        searchResults = []
        showingSearchResults = false
    }
    
    func refreshData() {
        isRefreshing = true
        productService.updatePrices()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadInitialData()
            self.isRefreshing = false
        }
    }
    
    func selectCategory(_ category: ProductCategory?) {
        selectedCategory = category
    }
    
    func getTipsForCurrentCategory() -> [ShoppingTip] {
        if let category = selectedCategory {
            return tipsService.getTipsForCategory(category)
        }
        return shoppingTips
    }
}
