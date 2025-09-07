//
//  ProductService.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class ProductService: ObservableObject {
    static let shared = ProductService()
    
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMockData()
    }
    
    func searchProducts(query: String, category: ProductCategory? = nil) -> [Product] {
        var filtered = products
        
        if !query.isEmpty {
            filtered = filtered.filter { product in
                product.name.localizedCaseInsensitiveContains(query) ||
                product.description.localizedCaseInsensitiveContains(query)
            }
        }
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered.sorted { $0.lowestPrice < $1.lowestPrice }
    }
    
    func getProductsByCategory(_ category: ProductCategory) -> [Product] {
        return products.filter { $0.category == category }
    }
    
    func getFeaturedProducts() -> [Product] {
        return products.filter { $0.savingsPercentage > 15 }
            .sorted { $0.savingsPercentage > $1.savingsPercentage }
            .prefix(10)
            .map { $0 }
    }
    
    func getBestDeals() -> [Product] {
        return products.sorted { $0.savingsPercentage > $1.savingsPercentage }
            .prefix(5)
            .map { $0 }
    }
    
    private func loadMockData() {
        // Mock data for demonstration
        let mockProducts = [
            Product(
                name: "iPhone 15 Pro",
                description: "Latest iPhone with titanium design and advanced camera system",
                imageURL: "https://example.com/iphone15.jpg",
                category: .electronics,
                vendors: [
                    Vendor(name: "Apple Store", price: 999.00, currency: "USD", availability: "In Stock", rating: 4.8, shippingCost: 0.00, estimatedDelivery: "2-3 days", productURL: "https://apple.com"),
                    Vendor(name: "Best Buy", price: 979.99, currency: "USD", availability: "In Stock", rating: 4.6, shippingCost: 9.99, estimatedDelivery: "1-2 days", productURL: "https://bestbuy.com"),
                    Vendor(name: "Amazon", price: 989.00, currency: "USD", availability: "In Stock", rating: 4.7, shippingCost: 0.00, estimatedDelivery: "Next day", productURL: "https://amazon.com")
                ],
                averageRating: 4.7,
                reviewCount: 1250
            ),
            Product(
                name: "MacBook Air M3",
                description: "Supercharged by the M3 chip, perfect for work and creativity",
                imageURL: "https://example.com/macbook.jpg",
                category: .electronics,
                vendors: [
                    Vendor(name: "Apple Store", price: 1099.00, currency: "USD", availability: "In Stock", rating: 4.9, shippingCost: 0.00, estimatedDelivery: "3-5 days", productURL: "https://apple.com"),
                    Vendor(name: "Amazon", price: 1049.99, currency: "USD", availability: "In Stock", rating: 4.8, shippingCost: 0.00, estimatedDelivery: "2-3 days", productURL: "https://amazon.com"),
                    Vendor(name: "B&H", price: 1079.00, currency: "USD", availability: "Limited", rating: 4.7, shippingCost: 19.99, estimatedDelivery: "5-7 days", productURL: "https://bhphotovideo.com")
                ],
                averageRating: 4.8,
                reviewCount: 890
            ),
            Product(
                name: "Nike Air Max 270",
                description: "Comfortable running shoes with modern design",
                imageURL: "https://example.com/nike.jpg",
                category: .clothing,
                vendors: [
                    Vendor(name: "Nike", price: 150.00, currency: "USD", availability: "In Stock", rating: 4.5, shippingCost: 0.00, estimatedDelivery: "3-5 days", productURL: "https://nike.com"),
                    Vendor(name: "Foot Locker", price: 139.99, currency: "USD", availability: "In Stock", rating: 4.4, shippingCost: 8.99, estimatedDelivery: "2-4 days", productURL: "https://footlocker.com"),
                    Vendor(name: "Amazon", price: 145.00, currency: "USD", availability: "In Stock", rating: 4.6, shippingCost: 0.00, estimatedDelivery: "Next day", productURL: "https://amazon.com")
                ],
                averageRating: 4.5,
                reviewCount: 567
            ),
            Product(
                name: "Dyson V15 Detect",
                description: "Advanced cordless vacuum with laser dust detection",
                imageURL: "https://example.com/dyson.jpg",
                category: .home,
                vendors: [
                    Vendor(name: "Dyson", price: 749.99, currency: "USD", availability: "In Stock", rating: 4.7, shippingCost: 0.00, estimatedDelivery: "5-7 days", productURL: "https://dyson.com"),
                    Vendor(name: "Best Buy", price: 699.99, currency: "USD", availability: "In Stock", rating: 4.6, shippingCost: 19.99, estimatedDelivery: "3-5 days", productURL: "https://bestbuy.com"),
                    Vendor(name: "Target", price: 729.99, currency: "USD", availability: "Limited", rating: 4.5, shippingCost: 0.00, estimatedDelivery: "7-10 days", productURL: "https://target.com")
                ],
                averageRating: 4.6,
                reviewCount: 423
            )
        ]
        
        self.products = mockProducts
    }
    
    func updatePrices() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // In a real app, this would fetch updated prices from APIs
            self.isLoading = false
        }
    }
}

// MARK: - Shopping Tips Service
class ShoppingTipsService: ObservableObject {
    static let shared = ShoppingTipsService()
    
    @Published var tips: [ShoppingTip] = []
    
    init() {
        loadTips()
    }
    
    private func loadTips() {
        tips = [
            ShoppingTip(
                title: "Best Time to Buy Electronics",
                content: "Electronics are typically cheapest during back-to-school season (August-September) and Black Friday/Cyber Monday.",
                category: .electronics,
                icon: "lightbulb"
            ),
            ShoppingTip(
                title: "Price Tracking Strategy",
                content: "Set up price alerts 2-3 weeks before you need to buy. Prices often fluctuate in cycles.",
                category: nil,
                icon: "chart.line.uptrend.xyaxis"
            ),
            ShoppingTip(
                title: "Compare Total Cost",
                content: "Always factor in shipping, taxes, and return policies when comparing prices across vendors.",
                category: nil,
                icon: "dollarsign.circle"
            ),
            ShoppingTip(
                title: "Seasonal Clothing Sales",
                content: "Buy winter clothes in February-March and summer clothes in August-September for best deals.",
                category: .clothing,
                icon: "tshirt"
            )
        ]
    }
    
    func getTipsForCategory(_ category: ProductCategory) -> [ShoppingTip] {
        return tips.filter { $0.category == category || $0.category == nil }
    }
}

struct ShoppingTip: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let category: ProductCategory?
    let icon: String
}
