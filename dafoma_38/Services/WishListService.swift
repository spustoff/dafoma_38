//
//  WishListService.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class WishListService: ObservableObject {
    static let shared = WishListService()
    
    @Published var wishLists: [WishList] = []
    @Published var userPreferences = UserPreferences()
    
    private let userDefaultsKey = "WishLists"
    private let preferencesKey = "UserPreferences"
    
    init() {
        loadWishLists()
        loadUserPreferences()
    }
    
    // MARK: - WishList Management
    
    func createWishList(name: String) {
        let newWishList = WishList(
            name: name,
            products: [],
            createdDate: Date()
        )
        wishLists.append(newWishList)
        saveWishLists()
    }
    
    func deleteWishList(_ wishList: WishList) {
        wishLists.removeAll { $0.id == wishList.id }
        saveWishLists()
    }
    
    func addProductToWishList(_ product: Product, wishListId: UUID) {
        if let index = wishLists.firstIndex(where: { $0.id == wishListId }) {
            wishLists[index].addProduct(product)
            saveWishLists()
        }
    }
    
    func removeProductFromWishList(_ product: Product, wishListId: UUID) {
        if let index = wishLists.firstIndex(where: { $0.id == wishListId }) {
            wishLists[index].removeProduct(product)
            saveWishLists()
        }
    }
    
    func isProductInAnyWishList(_ product: Product) -> Bool {
        return wishLists.contains { wishList in
            wishList.products.contains { $0.id == product.id }
        }
    }
    
    func getWishListsContaining(_ product: Product) -> [WishList] {
        return wishLists.filter { wishList in
            wishList.products.contains { $0.id == product.id }
        }
    }
    
    func shareWishList(_ wishList: WishList) -> String? {
        if let index = wishLists.firstIndex(where: { $0.id == wishList.id }) {
            wishLists[index].toggleShare()
            saveWishLists()
            return wishLists[index].shareURL
        }
        return nil
    }
    
    // MARK: - Price Alerts
    
    func checkForPriceDrops() -> [PriceAlert] {
        var alerts: [PriceAlert] = []
        
        for wishList in wishLists {
            for product in wishList.products {
                // Simulate price drop detection
                if product.savingsPercentage > userPreferences.priceAlertThreshold {
                    alerts.append(PriceAlert(
                        product: product,
                        oldPrice: product.highestPrice,
                        newPrice: product.lowestPrice,
                        savings: product.priceSavings,
                        savingsPercentage: product.savingsPercentage
                    ))
                }
            }
        }
        
        return alerts
    }
    
    // MARK: - Data Persistence
    
    private func saveWishLists() {
        if let encoded = try? JSONEncoder().encode(wishLists) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadWishLists() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([WishList].self, from: data) {
            wishLists = decoded
        } else {
            // Create default wish list
            createDefaultWishList()
        }
    }
    
    func saveUserPreferences() {
        if let encoded = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
    
    private func loadUserPreferences() {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            userPreferences = decoded
        }
    }
    
    private func createDefaultWishList() {
        let defaultWishList = WishList(
            name: "My Favorites",
            products: [],
            createdDate: Date()
        )
        wishLists = [defaultWishList]
        saveWishLists()
    }
    
    // MARK: - Account Management
    
    func resetAllData() {
        wishLists = []
        userPreferences = UserPreferences()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: preferencesKey)
        createDefaultWishList()
    }
    
    func updateUserProfile(name: String, email: String) {
        userPreferences.userName = name
        userPreferences.userEmail = email
        saveUserPreferences()
    }
}

struct PriceAlert: Identifiable {
    let id = UUID()
    let product: Product
    let oldPrice: Double
    let newPrice: Double
    let savings: Double
    let savingsPercentage: Double
    let timestamp = Date()
}
