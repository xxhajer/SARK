
  //
//  CustomTabBar.swift
//  SARK
//
//  Created by Danah yousef Almansour on 22/02/1448 AH.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabBarItem(icon: "house", title: "Home", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            Spacer()
            
            TabBarItem(icon: "bubble.left.and.bubble.right", title: "AI Coach", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            Spacer()
            
            TabBarItem(icon: "folder", title: "Projects", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            Spacer()
            
            TabBarItem(icon: "person", title: "Profile", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
        .background(Color("Boxes"))
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 11, weight: .regular))
            }
            .foregroundColor(isSelected ? Color("appGreen") : Color("FadedText"))
        }
    }
}
