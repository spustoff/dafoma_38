//
//  Product.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let imageURL: String
    let category: ProductCategory
    let vendors: [Vendor]
    let averageRating: Double
    let reviewCount: Int
    var isInWishList: Bool = false
    
    var lowestPrice: Double {
        vendors.map { $0.price }.min() ?? 0.0
    }
    
    var highestPrice: Double {
        vendors.map { $0.price }.max() ?? 0.0
    }
    
    var priceSavings: Double {
        highestPrice - lowestPrice
    }
    
    var savingsPercentage: Double {
        guard highestPrice > 0 else { return 0 }
        return (priceSavings / highestPrice) * 100
    }
}

struct Vendor: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
    let currency: String
    let availability: String
    let rating: Double
    let shippingCost: Double
    let estimatedDelivery: String
    let productURL: String
    
    var totalCost: Double {
        price + shippingCost
    }
}

enum ProductCategory: String, CaseIterable, Codable {
    case electronics = "Electronics"
    case clothing = "Clothing"
    case home = "Home & Garden"
    case books = "Books"
    case sports = "Sports & Outdoors"
    case beauty = "Beauty & Health"
    case toys = "Toys & Games"
    case automotive = "Automotive"
    
    var icon: String {
        switch self {
        case .electronics: return "laptopcomputer"
        case .clothing: return "tshirt"
        case .home: return "house"
        case .books: return "book"
        case .sports: return "sportscourt"
        case .beauty: return "heart"
        case .toys: return "gamecontroller"
        case .automotive: return "car"
        }
    }
}
