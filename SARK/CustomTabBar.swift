//
//  Untitled.swift
//  SARK
//
//  Created by hajer almejel on 22/02/1448 AH.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        // CHANGE: شالت المنتورة تاب البروفايل كامل — صار الاختيار بس بين
        // Home و Projects. زر حذف الحساب انتقل لـ My Businesses نفسها.
        // كان فيه Spacer() يمدد البار على عرض الشاشة كامل، وهذا كان مناسب
        // لثلاث عناصر بس صار يبين متباعد وغبي مع عنصرين بس. الحين البار
        // يضبط حجمه على المحتوى بمسافة ثابتة بين العنصرين ويتوسط تلقائيًا.
        HStack(spacing: 64) {
            TabBarItem(icon: "house", title: "Home", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            TabBarItem(icon: "folder", title: "Projects", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 12)
        .background(Color("boxes"))
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
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
            .foregroundColor(isSelected ? .greeen : .fadedText)
        }
    }
}
