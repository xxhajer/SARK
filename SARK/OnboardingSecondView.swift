//
//  Untitled.swift
//  SARK
//
//  Created by hajer almejel on 27/02/1448 AH.
//

//
//  OnboardingSecondView.swift
//  Sarkn
//
//  Created by ربى خالد الدوسري on 22/02/1448 AH.
//

import SwiftUI

struct OnboardingSecondView: View {
    @Environment(\.dismiss) private var dismiss
    // CHANGE: شالت المنتورة صفحة "وش اسمك" — Next/Skip الحين يخلصون
    // الأونبوردنق مباشرة ويودون للهوم.
    @State private var navigateToHome = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24))
                        .foregroundColor(Color("priemary texts"))
                }
                .padding(.leading, 24)
                .padding(.top, 16)
                
                Spacer()
            }
            
            // Illustration area
            Image("on2")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding(.horizontal)
                .padding(.top)
            
            Spacer()
                .frame(height: 40)
            
            // Title
            VStack(spacing: 8) {
                Text("Roadmap &")
                    .font(.custom("SF Pro", size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(Color("priemary texts"))
                
                Text("Actionable Steps")
                    .font(.custom("SF Pro", size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(Color("priemary texts"))
            }
            .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: 16)
            
            // Subtitle
            Text("Follow clear, step-by-step guidance to execute your startup goals.")
                .font(.custom("SF Pro", size: 16))
                .fontWeight(.regular)
                .foregroundColor(Color("long texts"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 40)
            
            // Feature cards
            VStack(spacing: 16) {
                OnboardingFeatureCardView(
                    starIcon: "star",
                    title: "Hands-on Learning:",
                    description: "Practical resources to build real skills"
                )
                
                OnboardingFeatureCardView(
                    starIcon: "star",
                    title: "Clear Next Steps:",
                    description: "Know exactly what to execute next"
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Page indicators
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                
                Circle()
                    .fill(Color("appOrange"))
                    .frame(width: 12, height: 12)
                
               
            }
            .padding(.bottom, 20)
            
            // Next button
            Button(action: {
                hasCompletedOnboarding = true
                navigateToHome = true
            }) {
                HStack(spacing: 8) {
                    Text("Next")
                        .font(.custom("SF Pro", size: 20))
                        .fontWeight(.bold)
                    
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(Color("inside the green"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("appGreen"))
                .cornerRadius(28)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            // Skip button
            Button(action: {
                hasCompletedOnboarding = true
                navigateToHome = true
            }) {
                Text("skip")
                    .font(.custom("SF Pro", size: 18))
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                    .underline()
            }
            .padding(.bottom, 40)
        }
        .background(Color("Background"))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToHome) {
            MainTabView()
        }
    }
}

#Preview {
    OnboardingSecondView()
}
