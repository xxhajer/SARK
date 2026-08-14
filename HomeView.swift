//
//  HomeView.swift
//  SARK
//
//  Created by hajer almejel on 27/02/1448 AH.
//

//
//  HomeView.swift
//  Sark
//
//  Created by ربى خالد الدوسري on 23/02/1448 AH.
//

import SwiftUI

struct HomeView: View {
    @State private var userName = UserDefaults.standard.string(forKey: "userName") ?? "User"
    
    private var todaysTip: String {
        TipManager.shared.getTodaysTip()
    }
    
    var body: some View {
        NavigationStack {
              homeContent
                  .navigationBarHidden(true)
                  .ignoresSafeArea(.keyboard)
          }
      }
    
    // MARK: - Home Content
    private var homeContent: some View {
        VStack(spacing: 0) {
            notificationButton
            Spacer().frame(height: 40)
            greetingSection
            Spacer().frame(height: 50)
            businessCardsSection
            Spacer().frame(height: 30)
            todaysTipCard
            Spacer()
            Spacer().frame(height: 100)
        }
        .background(Color("Background"))
    }
    
    // MARK: - Notification Button
    private var notificationButton: some View {
        HStack {
            NavigationLink(destination: NotificationsView()) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white).shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3))
                    .overlay(
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 9)
                            .offset(x: 13, y: -13)
                    )
            }
            .padding(.leading, 24)
            .padding(.top, 16)
            
            Spacer()
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Text("Hello, \(userName)!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color("priemary texts"))
                
                Image("wave")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
            
            Text("Ready to grow\nyour business?")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color("long texts"))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Business Cards Section
    private var businessCardsSection: some View {
        HStack(spacing: 12) {
            BusinessCardView1(
                icon: "bag",
                title: "My Businesses",
                description: "View and manage\nyour businesses",
                destination: AnyView(MyBusinessesView())
            )
            
            BusinessCardView1(
                icon: "plus",
                title: "New Business",
                description: "Start a new business\nwith AI guidance",
                destination: AnyView(MyBusinessesView())
            )
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Today's Tip Card
    private var todaysTipCard: some View {
        HStack(spacing: 12) {
            Image("ideaEva")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Today's Tip")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("priemary texts"))
                
                Text(todaysTip)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color("long texts"))
                    .lineSpacing(3)
            }
            
            Spacer()
            
            Image("leaf")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("boxes"))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }
}

// MARK: - Business Card Component
struct BusinessCardView1: View {
    let icon: String
    let title: String
    let description: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 10) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("priemary texts"))
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color("long texts"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("boxes"))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}
