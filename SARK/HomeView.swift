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
    // CHANGE: المنتورة قالت لا تحطون "My Businesses" بالهوم، خلوا بس
    // "New Business" — ولما تضغطينها تفتح مباشرة فورم فكرة بزنس جديد
    // (StartFromScratchView) مو تدخلك My Businesses.
    @State private var showNewBusiness = false
    @State private var navigateToNewDashboardID: UUID? = nil
    @State private var navigateToNewDashboard = false

    private var todaysTip: String {
        TipManager.shared.getTodaysTip()
    }

    var body: some View {
        NavigationStack {
              homeContent
                  .navigationBarHidden(true)
                  .ignoresSafeArea(.keyboard)
                  .navigationDestination(isPresented: $navigateToNewDashboard) {
                      if let id = navigateToNewDashboardID {
                          projectDashBoard(businessID: id)
                      }
                  }
                  .fullScreenCover(isPresented: $showNewBusiness) {
                      StartFromScratchView(
                          onFinishCreation: { finishedBusinessID in
                              showNewBusiness = false
                              navigateToNewDashboardID = finishedBusinessID
                              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                  navigateToNewDashboard = true
                              }
                          },
                          onReject: {
                              showNewBusiness = false
                          }
                      )
                  }
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
    // CHANGE: بطاقة "My Businesses" انشالت (متوفرة أصلاً من تاب Projects
    // بالأسفل) — بقيت بس "New Business" وتفتح مباشرة فورم فكرة بزنس جديد.
    private var businessCardsSection: some View {
        Button(action: { showNewBusiness = true }) {
            HStack(spacing: 16) {
                Image("plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text("New Business")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("priemary texts"))

                    Text("Start a new business with AI guidance")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color("long texts"))
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("priemary texts"))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("boxes"))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
