//
//  OnboardingFirstView.swift
//  Sarkn
//
//  Created by ربى خالد الدوسري on 22/02/1448 AH.
//

import SwiftUI

struct OnboardingFirstView: View {
    @State private var navigateToSecond = false
    @State private var navigateToName = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Illustration area
                Image("on1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding(.horizontal)
                    .padding(.top)
                
                Spacer()
                    .frame(height: 40)
                
                // Title
                VStack(spacing: 8) {
                    Text("Personalized")
                        .font(.custom("SF Pro", size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(Color("priemary texts"))
                    
                    Text("Business Plan")
                        .font(.custom("SF Pro", size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(Color("priemary texts"))
                }
                .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(height: 16)
                
                // Subtitle
                Text("Turn your unique idea into a structured, custom business plan.")
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
                        title: "Goal-Based Planning:",
                        description: "Tailored to your background "
                    )
                    
                    OnboardingFeatureCardView(
                        starIcon: "star",
                        title: "Actionable Steps:",
                        description: "Clear milestones from idea to launch"
                    )
                }
                .padding(.horizontal, 21)
                
                Spacer()
                
                // Page indicators
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color("appOrange"))
                        .frame(width: 12, height: 12)
                    
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                  
                }
                .padding(.bottom, 20)
                
                // Next button
                Button(action: {
                    navigateToSecond = true
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
                    navigateToName = true
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
            .navigationDestination(isPresented: $navigateToSecond) {
                OnboardingSecondView()
            }
            .navigationDestination(isPresented: $navigateToName) {
                EnterNameView()
            }
        }
    }
}

struct OnboardingFeatureCardView: View {
    let starIcon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: starIcon)
                .font(.system(size: 28))
                .foregroundColor(Color("appOrange"))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("SF Pro", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("priemary texts"))
                
                Text(description)
                    .font(.custom("SF Pro", size: 14))
                    .fontWeight(.regular)
                    .foregroundColor(Color("long texts"))
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("boxes"))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

#Preview {
    OnboardingFirstView()
}
