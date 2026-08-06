import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 48) {
            // Home - Index 0
            TabBarItem(icon: "house", title: "Home", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            // Projects - Index 1
            TabBarItem(icon: "folder", title: "Projects", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            // Profile - Index 2
            TabBarItem(icon: "person", title: "Profile", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
        .background(Color("boxes"))
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
            .frame(width: 54) // Keeps hit targets consistent and items centered
            .foregroundColor(isSelected ? Color("appGreen") : Color("faded text"))
        }
    }
}

            
           
