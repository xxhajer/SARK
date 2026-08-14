//
//  SplashView.swift
//  SARK
//
//  Created by hajer almejel on 27/02/1448 AH.
//

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
    private var splashContent: some View {
            ZStack {
                // خلفية الشاشة بكروم اللون المطلوب #FFFCF8
                Color(red: 255/255, green: 252/255, blue: 248/255)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Image("splashPic")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 16)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .padding(.bottom, 35) // رفع الصورة قليلاً لتوسيط الشعار ونزول النجمة
                    
                    Spacer()
                }
            }
            .onAppear(perform: animateSplash)
        }
        
}

#Preview {
    SplashView()
}
