//
//  ContentView.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    var body: some View {
        Group {
            if onboardingCompleted {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
