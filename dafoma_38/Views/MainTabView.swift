//
//  MainTabView.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            WishListView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "heart.fill" : "heart")
                    Text("Wish Lists")
                }
                .tag(1)
            
            InsightsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                    Text("Insights")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "147B45"))
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "147B45"))
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color(hex: "147B45"))
            ]
            
            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct InsightsView: View {
    @StateObject private var productService = ProductService.shared
    @StateObject private var wishListService = WishListService.shared
    @StateObject private var tipsService = ShoppingTipsService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Savings Summary
                    SavingsSummaryView()
                    
                    // Category Breakdown
                    CategoryBreakdownView()
                    
                    // Shopping Tips
                    AllShoppingTipsView()
                    
                    // Price Trends (Mock)
                    PriceTrendsView()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .navigationTitle("Shopping Insights")
        }
    }
}

struct SavingsSummaryView: View {
    @StateObject private var wishListService = WishListService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Savings")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                SavingsCardView(
                    title: "This Month",
                    amount: getTotalSavings(),
                    subtitle: "Potential savings",
                    color: Color(hex: "147B45")
                )
                
                SavingsCardView(
                    title: "Best Deal",
                    amount: getBestSavingPercentage(),
                    subtitle: "on single item",
                    color: .orange,
                    isPercentage: true
                )
            }
            
            if let bestCategory = getBestSavingCategory() {
                HStack {
                    Image(systemName: bestCategory.icon)
                        .foregroundColor(Color(hex: "147B45"))
                    
                    Text("Best savings in \(bestCategory.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
    }
    
    private func getTotalSavings() -> Double {
        return wishListService.wishLists.reduce(0) { total, wishList in
            total + wishList.products.reduce(0) { $0 + $1.priceSavings }
        }
    }
    
    private func getBestSavingPercentage() -> Double {
        let allProducts = wishListService.wishLists.flatMap { $0.products }
        return allProducts.map { $0.savingsPercentage }.max() ?? 0
    }
    
    private func getBestSavingCategory() -> ProductCategory? {
        var categorySavings: [ProductCategory: Double] = [:]
        
        for wishList in wishListService.wishLists {
            for product in wishList.products {
                categorySavings[product.category, default: 0] += product.priceSavings
            }
        }
        
        return categorySavings.max(by: { $0.value < $1.value })?.key
    }
}

struct SavingsCardView: View {
    let title: String
    let amount: Double
    let subtitle: String
    let color: Color
    let isPercentage: Bool
    
    init(title: String, amount: Double, subtitle: String, color: Color, isPercentage: Bool = false) {
        self.title = title
        self.amount = amount
        self.subtitle = subtitle
        self.color = color
        self.isPercentage = isPercentage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(isPercentage ? amount.percentage : amount.currencyWhole)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CategoryBreakdownView: View {
    @StateObject private var wishListService = WishListService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.title2)
                .fontWeight(.bold)
            
            let categoryData = getCategoryData()
            
            if categoryData.isEmpty {
                Text("Add items to your wish lists to see category insights")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(categoryData, id: \.category) { data in
                        CategoryBreakdownRow(data: data)
                    }
                }
            }
        }
    }
    
    private func getCategoryData() -> [CategoryData] {
        var categoryStats: [ProductCategory: (count: Int, savings: Double)] = [:]
        
        for wishList in wishListService.wishLists {
            for product in wishList.products {
                let current = categoryStats[product.category] ?? (count: 0, savings: 0)
                categoryStats[product.category] = (
                    count: current.count + 1,
                    savings: current.savings + product.priceSavings
                )
            }
        }
        
        return categoryStats.map { category, stats in
            CategoryData(
                category: category,
                itemCount: stats.count,
                totalSavings: stats.savings
            )
        }.sorted { $0.totalSavings > $1.totalSavings }
    }
}

struct CategoryData {
    let category: ProductCategory
    let itemCount: Int
    let totalSavings: Double
}

struct CategoryBreakdownRow: View {
    let data: CategoryData
    
    var body: some View {
        HStack {
            Image(systemName: data.category.icon)
                .foregroundColor(Color(hex: "147B45"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(data.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(data.itemCount) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(data.totalSavings.currencyWhole)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "147B45"))
        }
        .padding(.vertical, 4)
    }
}

struct AllShoppingTipsView: View {
    @StateObject private var tipsService = ShoppingTipsService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shopping Tips")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ForEach(tipsService.tips) { tip in
                    ShoppingTipRowView(tip: tip)
                }
            }
        }
    }
}

struct ShoppingTipRowView: View {
    let tip: ShoppingTip
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: tip.icon)
                .font(.title3)
                .foregroundColor(Color(hex: "147B45"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(tip.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct PriceTrendsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Trends")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                PriceTrendRow(
                    category: .electronics,
                    trend: "↓ 5%",
                    description: "Electronics prices trending down this month",
                    isPositive: true
                )
                
                PriceTrendRow(
                    category: .clothing,
                    trend: "↑ 2%",
                    description: "Clothing prices slightly up due to seasonal demand",
                    isPositive: false
                )
                
                PriceTrendRow(
                    category: .home,
                    trend: "→ 0%",
                    description: "Home goods prices stable",
                    isPositive: nil
                )
            }
        }
    }
}

struct PriceTrendRow: View {
    let category: ProductCategory
    let trend: String
    let description: String
    let isPositive: Bool?
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(Color(hex: "147B45"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(trend)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(
                    isPositive == true ? Color(hex: "147B45") :
                    isPositive == false ? .red : .gray
                )
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MainTabView()
}
