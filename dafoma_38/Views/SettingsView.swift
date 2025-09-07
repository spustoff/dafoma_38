//
//  SettingsView.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var wishListService = WishListService.shared
    @AppStorage("userName") private var userName = ""
    @AppStorage("userEmail") private var userEmail = ""
    
    @State private var showingDeleteConfirmation = false
    @State private var showingProfileEdit = false
    @State private var tempUserName = ""
    @State private var tempUserEmail = ""
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    ProfileHeaderView(
                        name: userName.isEmpty ? "Guest User" : userName,
                        email: userEmail.isEmpty ? "No email set" : userEmail
                    ) {
                        tempUserName = userName
                        tempUserEmail = userEmail
                        showingProfileEdit = true
                    }
                } header: {
                    Text("Profile")
                }
                
                // Preferences Section
                Section {
                    PreferenceRowView(
                        title: "Currency",
                        value: wishListService.userPreferences.preferredCurrency,
                        icon: "dollarsign.circle"
                    ) {
                        // TODO: Show currency picker
                    }
                    
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(Color(hex: "147B45"))
                            .frame(width: 24)
                        
                        Toggle("Price Alerts", isOn: Binding(
                            get: { wishListService.userPreferences.notificationsEnabled },
                            set: { newValue in
                                wishListService.userPreferences.notificationsEnabled = newValue
                                wishListService.saveUserPreferences()
                            }
                        ))
                    }
                    
                    PreferenceRowView(
                        title: "Alert Threshold",
                        value: "\(Int(wishListService.userPreferences.priceAlertThreshold))%",
                        icon: "percent"
                    ) {
                        // TODO: Show threshold picker
                    }
                } header: {
                    Text("Preferences")
                }
                
                // Categories Section
                Section {
                    ForEach(wishListService.userPreferences.favoriteCategories, id: \.self) { category in
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(Color(hex: "147B45"))
                                .frame(width: 24)
                            
                            Text(category.rawValue)
                            
                            Spacer()
                        }
                    }
                    
                    if wishListService.userPreferences.favoriteCategories.isEmpty {
                        Text("No favorite categories selected")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                } header: {
                    Text("Favorite Categories")
                } footer: {
                    Text("Categories selected during onboarding")
                }
                
                // Statistics Section
                Section {
                    StatisticRowView(
                        title: "Wish Lists",
                        value: "\(wishListService.wishLists.count)",
                        icon: "heart"
                    )
                    
                    StatisticRowView(
                        title: "Total Items",
                        value: "\(getTotalItems())",
                        icon: "bag"
                    )
                    
                    StatisticRowView(
                        title: "Potential Savings",
                        value: getTotalSavings().currencyWhole,
                        icon: "arrow.down.circle"
                    )
                } header: {
                    Text("Statistics")
                }
                
                // App Information Section
                Section {
                    InfoRowView(
                        title: "Version",
                        value: "1.0.0",
                        icon: "info.circle"
                    )
                    
                    InfoRowView(
                        title: "Session ID",
                        value: "8123",
                        icon: "number.circle"
                    )
                } header: {
                    Text("App Information")
                }
                
                // Account Management Section
                Section {
                    Button(action: { showingDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Account Management")
                } footer: {
                    Text("This will reset all app data including wish lists and preferences.")
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your wish lists, preferences, and account data. This action cannot be undone.")
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView(
                userName: $tempUserName,
                userEmail: $tempUserEmail
            ) {
                saveProfile()
            }
        }
    }
    
    private func getTotalItems() -> Int {
        return wishListService.wishLists.reduce(0) { $0 + $1.products.count }
    }
    
    private func getTotalSavings() -> Double {
        return wishListService.wishLists.reduce(0) { total, wishList in
            total + wishList.products.reduce(0) { $0 + $1.priceSavings }
        }
    }
    
    private func saveProfile() {
        userName = tempUserName
        userEmail = tempUserEmail
        wishListService.updateUserProfile(name: tempUserName, email: tempUserEmail)
    }
    
    private func deleteAccount() {
        // Reset @AppStorage values
        userName = ""
        userEmail = ""
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
        
        // Reset all app data
        wishListService.resetAllData()
    }
}

struct ProfileHeaderView: View {
    let name: String
    let email: String
    let onEditTapped: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .font(.headline)
                
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Edit") {
                onEditTapped()
            }
            .font(.subheadline)
            .foregroundColor(Color(hex: "147B45"))
        }
        .padding(.vertical, 8)
    }
}

struct PreferenceRowView: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "147B45"))
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct StatisticRowView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "147B45"))
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "147B45"))
        }
    }
}

struct InfoRowView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileEditView: View {
    @Binding var userName: String
    @Binding var userEmail: String
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Edit Profile")
                        .font(.title2)
                    
                    VStack(spacing: 12) {
                        TextField("Name", text: $userName)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Email", text: $userEmail)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "147B45"))
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
