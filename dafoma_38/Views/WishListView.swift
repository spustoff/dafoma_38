//
//  WishListView.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct WishListView: View {
    @StateObject private var viewModel = WishListViewModel()
    @State private var showingCreateWishList = false
    @State private var selectedProduct: Product?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.wishLists.isEmpty {
                    EmptyWishListView {
                        showingCreateWishList = true
                    }
                } else {
                    // Summary Stats
                    WishListStatsView(viewModel: viewModel)
                    
                    // Wish Lists
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.wishLists) { wishList in
                                WishListCardView(
                                    wishList: wishList,
                                    onProductTapped: { product in
                                        selectedProduct = product
                                    },
                                    onShareTapped: {
                                        _ = viewModel.shareWishList(wishList)
                                    },
                                    onDeleteTapped: {
                                        viewModel.deleteWishList(wishList)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Wish Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateWishList = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "147B45"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateWishList) {
            CreateWishListView(viewModel: viewModel)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
        .alert("Price Alerts", isPresented: $viewModel.showingPriceAlerts) {
            Button("View Deals") {
                viewModel.dismissPriceAlerts()
            }
            Button("Dismiss") {
                viewModel.dismissPriceAlerts()
            }
        } message: {
            Text("Great news! \(viewModel.priceAlerts.count) items in your wish lists have price drops!")
        }
    }
}

struct WishListStatsView: View {
    @ObservedObject var viewModel: WishListViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCardView(
                    title: "Total Value",
                    value: viewModel.getTotalWishListValue().currencyWhole,
                    icon: "dollarsign.circle.fill",
                    color: Color(hex: "147B45")
                )
                
                StatCardView(
                    title: "Potential Savings",
                    value: viewModel.getTotalPotentialSavings().currencyWhole,
                    icon: "arrow.down.circle.fill",
                    color: .orange
                )
            }
            
            if let category = viewModel.getMostSavedCategory() {
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(Color(hex: "147B45"))
                    
                    Text("Best savings in \(category.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.05))
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct WishListCardView: View {
    let wishList: WishList
    let onProductTapped: (Product) -> Void
    let onShareTapped: () -> Void
    let onDeleteTapped: () -> Void
    
    @State private var showingOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(wishList.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("\(wishList.products.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if wishList.isShared {
                            Image(systemName: "link")
                                .font(.caption)
                                .foregroundColor(Color(hex: "147B45"))
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    if wishList.totalValue > 0 {
                        VStack(alignment: .trailing) {
                            Text(wishList.totalValue.currencyWhole)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "147B45"))
                            
                            if wishList.averageSavings > 0 {
                                Text("\(wishList.averageSavings.percentage) avg savings")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Button(action: { showingOptions = true }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Products Preview
            if wishList.products.isEmpty {
                Text("No items yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(wishList.products.prefix(5)) { product in
                            WishListProductView(product: product) {
                                onProductTapped(product)
                            }
                        }
                        
                        if wishList.products.count > 5 {
                            Button(action: {}) {
                                VStack {
                                    Text("+\(wishList.products.count - 5)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Text("more")
                                        .font(.caption)
                                }
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .confirmationDialog("Wish List Options", isPresented: $showingOptions) {
            Button("Share") {
                onShareTapped()
            }
            
            Button("Delete", role: .destructive) {
                onDeleteTapped()
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct WishListProductView: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: product.category.icon)
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
                
                VStack(spacing: 2) {
                    Text(product.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text(product.lowestPrice.currencyWhole)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "147B45"))
                }
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyWishListView: View {
    let onCreateTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Wish Lists Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Create your first wish list to start saving on your favorite products")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button("Create Wish List") {
                onCreateTapped()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: "147B45"))
            .cornerRadius(25)
            
            Spacer()
        }
    }
}

struct CreateWishListView: View {
    @ObservedObject var viewModel: WishListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Create New Wish List")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    TextField("Wish List Name", text: $viewModel.newWishListName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.newWishListName = ""
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        viewModel.createWishList()
                        dismiss()
                    }
                    .disabled(viewModel.newWishListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    WishListView()
}
