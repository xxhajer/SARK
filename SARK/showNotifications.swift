//
//  showNotifications.swift
//  SARK
//
//  Created by hajer almejel on 26/02/1448 AH.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var dailyReminders = true

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                // الهيدر
                ZStack {
                    Text(L("Notifications"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 25)

                // كرت Daily reminders
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L("Daily reminders"))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                       
                    }
                    Spacer()
                    Toggle("", isOn: $dailyReminders)
                        .labelsHidden()
                        .tint(.greeen)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

                if dailyReminders {
                    // عنوان Recent
                    Text(L("Recent"))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.fadedText)
                        .padding(.bottom, 15)

                    // كروت الإشعارات
                    VStack(spacing: 14) {

                    
                        
                        

                        HStack(spacing: 12) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 18))
                                .foregroundColor(.greeen)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(L("Progress reminder"))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                Text(L("yesterday · your project is one step closer"))
                                    .font(.system(size: 13))
                                    .foregroundColor(.fadedText)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                        )

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(L("Check-in"))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                Text(L("2days ago · Pick Up where you left off"))
                                    .font(.system(size: 13))
                                    .foregroundColor(.fadedText)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: dailyReminders)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NotificationsView()
}
