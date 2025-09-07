//
//  WishListViewModel.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation
import Combine

class WishListViewModel: ObservableObject {
    @Published var wishLists: [WishList] = []
    @Published var selectedWishList: WishList?
    @Published var showingCreateWishList = false
    @Published var newWishListName = ""
    @Published var priceAlerts: [PriceAlert] = []
    @Published var showingPriceAlerts = false
    
    private let wishListService = WishListService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        checkForPriceAlerts()
    }
    
    private func setupBindings() {
        wishListService.$wishLists
            .assign(to: \.wishLists, on: self)
            .store(in: &cancellables)
    }
    
    func createWishList() {
        guard !newWishListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        wishListService.createWishList(name: newWishListName)
        newWishListName = ""
        showingCreateWishList = false
    }
    
    func deleteWishList(_ wishList: WishList) {
        wishListService.deleteWishList(wishList)
        if selectedWishList?.id == wishList.id {
            selectedWishList = nil
        }
    }
    
    func addProductToWishList(_ product: Product, wishListId: UUID) {
        wishListService.addProductToWishList(product, wishListId: wishListId)
    }
    
    func removeProductFromWishList(_ product: Product, wishListId: UUID) {
        wishListService.removeProductFromWishList(product, wishListId: wishListId)
    }
    
    func shareWishList(_ wishList: WishList) -> String? {
        return wishListService.shareWishList(wishList)
    }
    
    func isProductInWishList(_ product: Product) -> Bool {
        return wishListService.isProductInAnyWishList(product)
    }
    
    func getWishListsContaining(_ product: Product) -> [WishList] {
        return wishListService.getWishListsContaining(product)
    }
    
    func selectWishList(_ wishList: WishList) {
        selectedWishList = wishList
    }
    
    private func checkForPriceAlerts() {
        priceAlerts = wishListService.checkForPriceDrops()
        showingPriceAlerts = !priceAlerts.isEmpty
    }
    
    func dismissPriceAlerts() {
        priceAlerts = []
        showingPriceAlerts = false
    }
    
    func getTotalWishListValue() -> Double {
        return wishLists.reduce(0) { $0 + $1.totalValue }
    }
    
    func getTotalPotentialSavings() -> Double {
        return wishLists.reduce(0) { total, wishList in
            total + wishList.products.reduce(0) { $0 + $1.priceSavings }
        }
    }
    
    func getMostSavedCategory() -> ProductCategory? {
        var categorySavings: [ProductCategory: Double] = [:]
        
        for wishList in wishLists {
            for product in wishList.products {
                categorySavings[product.category, default: 0] += product.priceSavings
            }
        }
        
        return categorySavings.max(by: { $0.value < $1.value })?.key
    }
}
