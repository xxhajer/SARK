//
//  ُشزؤهرع.swift
//  SARK
//
//  Created by hajer almejel on 26/02/1448 AH.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {

            // المحتوى يتغير حسب التاب المختار
            Group {
                switch selectedTab {
                case 0:
                    Text("Hello, World!")
                case 1:
                    projectDashBoard()// مؤقت لين تبنينها
                case 2:
                    profile()
                default:
                    projectDashBoard()
                }
            }

            // التاب بار ثابت فوق كل شي، مرة وحدة بس
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 10)
        }
    }
}

#Preview {
    MainTabView()
}
