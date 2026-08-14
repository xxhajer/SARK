//
//  ContentView.swift
//  SARK
//
//  Created by hajer almejel on 26/02/1448 AH.
//

//
//  ContentView.swift
//  SARK
//
//  Created by wafa saifelislam mohamed on 21/02/1448 AH.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 1. التنقل بين الشاشات الرئيسية
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        StartFromScratchView() // شاشة الهوم
                    }
                case 1:
                    NavigationStack {
                        MyBusinessesView() // شاشة المشاريع
                    }
                case 2:
                    NavigationStack {
                        Text("Profile View") // شاشة البروفايل
                    }
                default:
                    NavigationStack {
                        StartFromScratchView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: Floating Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ContentView()
}
