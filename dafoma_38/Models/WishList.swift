//
//  WishList.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation

struct WishList: Identifiable, Codable {
    let id = UUID()
    var name: String
    var products: [Product]
    var createdDate: Date
    var isShared: Bool = false
    var shareURL: String?
    
    var totalValue: Double {
        products.reduce(0) { $0 + $1.lowestPrice }
    }
    
    var averageSavings: Double {
        guard !products.isEmpty else { return 0 }
        return products.reduce(0) { $0 + $1.savingsPercentage } / Double(products.count)
    }
    
    mutating func addProduct(_ product: Product) {
        if !products.contains(where: { $0.id == product.id }) {
            var newProduct = product
            newProduct.isInWishList = true
            products.append(newProduct)
        }
    }
    
    mutating func removeProduct(_ product: Product) {
        products.removeAll { $0.id == product.id }
    }
    
    mutating func toggleShare() {
        isShared.toggle()
        if isShared {
            shareURL = "https://shopsmart.app/wishlist/\(id.uuidString)"
        } else {
            shareURL = nil
        }
    }
}

struct UserPreferences: Codable {
    var preferredCurrency: String = "USD"
    var notificationsEnabled: Bool = true
    var priceAlertThreshold: Double = 10.0 // percentage
    var favoriteCategories: [ProductCategory] = []
    var maxShippingCost: Double = 50.0
    var onboardingCompleted: Bool = false
    var userName: String = ""
    var userEmail: String = ""
}
