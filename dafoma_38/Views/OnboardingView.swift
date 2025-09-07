//
//  OnboardingView.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("userName") private var userName = ""
    @AppStorage("userEmail") private var userEmail = ""
    @AppStorage("preferredCurrency") private var preferredCurrency = "USD"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    @State private var currentPage = 0
    @State private var tempUserName = ""
    @State private var tempUserEmail = ""
    @State private var selectedCategories: Set<ProductCategory> = []
    
    private let onboardingPages = [
        OnboardingPage(
            title: "Welcome to ShopSmart Uni",
            description: "Your premium shopping companion for smart purchases and savings",
            imageName: "bag.fill",
            color: Color(hex: "147B45")
        ),
        OnboardingPage(
            title: "Compare Prices Instantly",
            description: "Find the best deals across multiple vendors with real-time price comparisons",
            imageName: "chart.bar.fill",
            color: Color(hex: "147B45")
        ),
        OnboardingPage(
            title: "Smart Wish Lists",
            description: "Organize your desired items and get alerts when prices drop",
            imageName: "heart.fill",
            color: Color(hex: "147B45")
        ),
        OnboardingPage(
            title: "Shopping Insights",
            description: "Get expert tips and recommendations for smarter shopping decisions",
            imageName: "lightbulb.fill",
            color: Color(hex: "147B45")
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if currentPage < onboardingPages.count {
                // Onboarding pages
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            } else if currentPage == onboardingPages.count {
                // User setup page
                UserSetupView(
                    userName: $tempUserName,
                    userEmail: $tempUserEmail,
                    selectedCategories: $selectedCategories
                )
            } else {
                // Preferences setup page
                PreferencesSetupView(
                    preferredCurrency: $preferredCurrency,
                    notificationsEnabled: $notificationsEnabled
                )
            }
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation(.easeInOut) {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(Color(hex: "147B45"))
                }
                
                Spacer()
                
                Button(currentPage == onboardingPages.count + 1 ? "Get Started" : "Next") {
                    withAnimation(.easeInOut) {
                        if currentPage == onboardingPages.count + 1 {
                            completeOnboarding()
                        } else {
                            currentPage += 1
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "147B45"))
                .cornerRadius(25)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.white)
    }
    
    private func completeOnboarding() {
        // Save user data
        userName = tempUserName
        userEmail = tempUserEmail
        
        // Save to WishListService
        let wishListService = WishListService.shared
        wishListService.updateUserProfile(name: tempUserName, email: tempUserEmail)
        wishListService.userPreferences.preferredCurrency = preferredCurrency
        wishListService.userPreferences.notificationsEnabled = notificationsEnabled
        wishListService.userPreferences.favoriteCategories = Array(selectedCategories)
        wishListService.userPreferences.onboardingCompleted = true
        wishListService.saveUserPreferences()
        
        // Mark onboarding as completed
        onboardingCompleted = true
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(page.color)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct UserSetupView: View {
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var selectedCategories: Set<ProductCategory>
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Tell us about yourself")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Help us personalize your shopping experience")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                TextField("Your name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Email address", text: $userEmail)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding(.horizontal, 32)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("What are you interested in?")
                    .font(.headline)
                    .padding(.horizontal, 32)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategories.contains(category)
                        ) {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding(.top, 40)
    }
}

struct CategoryButton: View {
    let category: ProductCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "147B45") : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct PreferencesSetupView: View {
    @Binding var preferredCurrency: String
    @Binding var notificationsEnabled: Bool
    
    private let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY"]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Preferences")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Customize your shopping experience")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preferred Currency")
                        .font(.headline)
                    
                    Picker("Currency", selection: $preferredCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Price Alert Notifications", isOn: $notificationsEnabled)
                        .font(.headline)
                    
                    Text("Get notified when items in your wish lists go on sale")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding(.top, 40)
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
}
