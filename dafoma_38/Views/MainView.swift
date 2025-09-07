//
//  MainView.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedProduct: Product?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HeaderView()
                    
                    // Search Bar
                    SearchBarView(searchText: $viewModel.searchText)
                    
                    // Category Filter
                    CategoryFilterView(
                        selectedCategory: $viewModel.selectedCategory,
                        onCategorySelected: viewModel.selectCategory
                    )
                    
                    if viewModel.showingSearchResults {
                        // Search Results
                        SearchResultsView(
                            products: viewModel.searchResults,
                            onProductTapped: selectProduct
                        )
                    } else {
                        // Main Content
                        VStack(spacing: 32) {
                            // Best Deals Section
                            if !viewModel.bestDeals.isEmpty {
                                ProductSectionView(
                                    title: "Best Deals",
                                    products: viewModel.bestDeals,
                                    onProductTapped: selectProduct
                                )
                            }
                            
                            // Featured Products
                            if !viewModel.featuredProducts.isEmpty {
                                ProductSectionView(
                                    title: "Featured Products",
                                    products: viewModel.featuredProducts,
                                    onProductTapped: selectProduct
                                )
                            }
                            
                            // Shopping Tips
                            ShoppingTipsView(tips: viewModel.getTipsForCurrentCategory())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100) // Account for tab bar
            }
            .navigationBarHidden(true)
            .refreshable {
                viewModel.refreshData()
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
    
    private func selectProduct(_ product: Product) {
        selectedProduct = product
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("ShopSmart Uni")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Find the best deals")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(Color(hex: "147B45"))
            }
        }
        .padding(.top, 8)
    }
}

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search products...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: ProductCategory?
    let onCategorySelected: (ProductCategory?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    onCategorySelected(nil)
                }
                
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        onCategorySelected(category)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "147B45") : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct ProductSectionView: View {
    let title: String
    let products: [Product]
    let onProductTapped: (Product) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("See All") {
                    // TODO: Navigate to full product list
                }
                .font(.subheadline)
                .foregroundColor(Color(hex: "147B45"))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(products) { product in
                        ProductCardView(product: product) {
                            onProductTapped(product)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ProductCardView: View {
    let product: Product
    let action: () -> Void
    @StateObject private var wishListService = WishListService.shared
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Product Image Placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 160, height: 120)
                    .overlay(
                        Image(systemName: product.category.icon)
                            .font(.title)
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(product.lowestPrice.currency)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "147B45"))
                        
                        if product.savingsPercentage > 0 {
                            Text("\(product.savingsPercentage.percentage) off")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack {
                        ForEach(0..<5) { star in
                            Image(systemName: star < Int(product.averageRating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("(\(product.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .frame(width: 160)
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct SearchResultsView: View {
    let products: [Product]
    let onProductTapped: (Product) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(products.count) Results")
                .font(.headline)
                .padding(.horizontal, 16)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(products) { product in
                    ProductCardView(product: product) {
                        onProductTapped(product)
                    }
                }
            }
        }
    }
}

struct ShoppingTipsView: View {
    let tips: [ShoppingTip]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shopping Tips")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(tips) { tip in
                        ShoppingTipCard(tip: tip)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ShoppingTipCard: View {
    let tip: ShoppingTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: tip.icon)
                .font(.title2)
                .foregroundColor(Color(hex: "147B45"))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(tip.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(tip.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .frame(width: 240)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    MainView()
}
