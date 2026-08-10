//
//  SplashView.swift
//  Sark
//
//  Created by ربى خالد الدوسري on 23/02/1448 AH.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if isActive {
            destinationView
        } else {
            splashContent
        }
    }
    
    // MARK: - Destination View
    @ViewBuilder
    private var destinationView: some View {
        if hasCompletedOnboarding {
            NavigationStack {
                MainTabView()
            }
        } else {
            OnboardingFirstView()
        }
    }
    
    // MARK: - Splash Content
    private var splashContent: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                Image(systemName: "star")
                    .font(.system(size: 60))
                    .foregroundColor(Color("priemary texts"))
                    .padding(.bottom, 40)
                
                taglineText
                
                Spacer()
                Spacer()
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear(perform: animateSplash)
    }
    
    // MARK: - Tagline
    private var taglineText: some View {
        Text("\"An All-In-One Interactive Platform That Guides Aspiring Entrepreneurs From Idea To Execution.\"")
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color("priemary texts"))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
    }
    
    // MARK: - Animation
    private func animateSplash() {
        withAnimation(.easeIn(duration: 0.8)) {
            opacity = 1.0
            scale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                isActive = true
            }
        }
    }
}

#Preview {
    SplashView()
}
