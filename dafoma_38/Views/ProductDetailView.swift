//
//  ProductDetailView.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @StateObject private var wishListService = WishListService.shared
    @StateObject private var tipsService = ShoppingTipsService.shared
    
    @State private var showingWishListSelector = false
    @State private var showingShareSheet = false
    @State private var selectedVendor: Vendor?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Product Image
                    ProductImageView(product: product)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Product Info
                        ProductInfoView(product: product)
                        
                        // Price Comparison
                        PriceComparisonView(
                            vendors: product.vendors,
                            selectedVendor: $selectedVendor
                        )
                        
                        // Savings Information
                        if product.savingsPercentage > 0 {
                            SavingsInfoView(product: product)
                        }
                        
                        // Reviews
                        ReviewsView(product: product)
                        
                        // Category Tips
                        CategoryTipsView(
                            tips: tipsService.getTipsForCategory(product.category)
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 100)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button(action: { showingWishListSelector = true }) {
                            Image(systemName: wishListService.isProductInAnyWishList(product) ? "heart.fill" : "heart")
                                .foregroundColor(wishListService.isProductInAnyWishList(product) ? .red : .primary)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingWishListSelector) {
            WishListSelectorView(product: product)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [createShareText()])
        }
    }
    
    private func createShareText() -> String {
        let bestPrice = product.lowestPrice
        let savings = product.savingsPercentage
        return "Check out \(product.name) starting at $\(String(format: "%.2f", bestPrice)) (save \(String(format: "%.0f", savings))%!) on ShopSmart Uni"
    }
}

struct ProductImageView: View {
    let product: Product
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 300)
                .overlay(
                    Image(systemName: product.category.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                )
            
            if product.savingsPercentage > 0 {
                Text("\(product.savingsPercentage.percentage) OFF")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(16)
            }
        }
    }
}

struct ProductInfoView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(product.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(product.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Text(product.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "147B45").opacity(0.1))
                    .foregroundColor(Color(hex: "147B45"))
                    .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<5) { star in
                        Image(systemName: star < Int(product.averageRating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Text("(\(product.reviewCount) reviews)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct PriceComparisonView: View {
    let vendors: [Vendor]
    @Binding var selectedVendor: Vendor?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Comparison")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(vendors.sorted(by: { $0.totalCost < $1.totalCost })) { vendor in
                    VendorRowView(
                        vendor: vendor,
                        isLowestPrice: vendor.totalCost == vendors.map { $0.totalCost }.min(),
                        isSelected: selectedVendor?.id == vendor.id
                    ) {
                        selectedVendor = vendor
                        // TODO: Open vendor URL
                    }
                }
            }
        }
    }
}

struct VendorRowView: View {
    let vendor: Vendor
    let isLowestPrice: Bool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(vendor.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if isLowestPrice {
                            Text("BEST PRICE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "147B45"))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack {
                        Text(vendor.price.currency)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if vendor.shippingCost > 0 {
                            Text("+ \(vendor.shippingCost.currency) shipping")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Free shipping")
                                .font(.caption)
                                .foregroundColor(Color(hex: "147B45"))
                        }
                    }
                    
                    HStack {
                        Text(vendor.availability)
                            .font(.caption)
                            .foregroundColor(vendor.availability == "In Stock" ? Color(hex: "147B45") : .orange)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(vendor.estimatedDelivery)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text(vendor.totalCost.currency)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isLowestPrice ? Color(hex: "147B45") : .primary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { star in
                            Image(systemName: star < Int(vendor.rating) ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isLowestPrice ? Color(hex: "147B45") : Color.gray.opacity(0.3), lineWidth: isLowestPrice ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color(hex: "147B45").opacity(0.1) : Color.clear)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct SavingsInfoView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Savings Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("You Save")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(product.priceSavings.currency)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "147B45"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Discount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(product.savingsPercentage.percentageDecimal)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "147B45").opacity(0.1))
            )
        }
    }
}

struct ReviewsView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reviews")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("See All") {
                    // TODO: Show all reviews
                }
                .font(.subheadline)
                .foregroundColor(Color(hex: "147B45"))
            }
            
            HStack {
                Text(product.averageRating.formatted(decimalPlaces: 1))
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { star in
                            Image(systemName: star < Int(product.averageRating) ? "star.fill" : "star")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text("\(product.reviewCount) reviews")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
}

struct CategoryTipsView: View {
    let tips: [ShoppingTip]
    
    var body: some View {
        if !tips.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Shopping Tips")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(tips.prefix(2)) { tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: tip.icon)
                            .font(.title3)
                            .foregroundColor(Color(hex: "147B45"))
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tip.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(tip.content)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
        }
    }
}

struct WishListSelectorView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @StateObject private var wishListService = WishListService.shared
    @State private var showingNewWishListForm = false
    @State private var newWishListName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add to Wish List")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(wishListService.wishLists) { wishList in
                            WishListOptionView(
                                wishList: wishList,
                                product: product,
                                isSelected: wishList.products.contains(where: { $0.id == product.id })
                            ) {
                                toggleProductInWishList(wishList)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button("Create New Wish List") {
                    showingNewWishListForm = true
                }
                .font(.headline)
                .foregroundColor(Color(hex: "147B45"))
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("New Wish List", isPresented: $showingNewWishListForm) {
            TextField("Wish List Name", text: $newWishListName)
            Button("Create") {
                createNewWishList()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func toggleProductInWishList(_ wishList: WishList) {
        if wishList.products.contains(where: { $0.id == product.id }) {
            wishListService.removeProductFromWishList(product, wishListId: wishList.id)
        } else {
            wishListService.addProductToWishList(product, wishListId: wishList.id)
        }
    }
    
    private func createNewWishList() {
        guard !newWishListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        wishListService.createWishList(name: newWishListName)
        if let newWishList = wishListService.wishLists.last {
            wishListService.addProductToWishList(product, wishListId: newWishList.id)
        }
        
        newWishListName = ""
    }
}

struct WishListOptionView: View {
    let wishList: WishList
    let product: Product
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(wishList.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(wishList.products.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? Color(hex: "147B45") : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "147B45") : Color.gray.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color(hex: "147B45").opacity(0.1) : Color.clear)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ProductDetailView(product: Product(
        name: "iPhone 15 Pro",
        description: "Latest iPhone with titanium design",
        imageURL: "",
        category: .electronics,
        vendors: [],
        averageRating: 4.7,
        reviewCount: 1250
    ))
}
