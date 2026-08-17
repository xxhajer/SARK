//
//  EnterNameView.swift
//  SARK
//
//  Created by hajer almejel on 27/02/1448 AH.
//

//
//  EnterNameView.swift
//  Sarkn
//
//  Created by ربى خالد الدوسري on 22/02/1448 AH.
//

import SwiftUI

struct EnterNameView: View {
    @State private var name = ""
    @State private var shouldNavigateToHome = false
    @State private var contentOpacity = 1.0
    @State private var homeOpacity = 0.0
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            // Current screen content (EnterName)
            VStack(spacing: 0) {
                backButton

                Spacer().frame(height: 60)

                illustrationImage

                Spacer().frame(height: 50)

                titleText

                Spacer().frame(height: 16)

                subtitleText

                Spacer().frame(height: 40)

                nameTextField

                Spacer()

                letsGoButton
            }
            .background(Color("Background"))
            .navigationBarHidden(true)
            .opacity(contentOpacity)

            // New screen (Home)
            if shouldNavigateToHome {
                MainTabView()
                    .opacity(homeOpacity)
            }
        }
    }

    // MARK: - Back Button
    private var backButton: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
                    .foregroundColor(Color("priemary texts"))
            }
            .padding(.leading, 24)
            .padding(.top, 16)

            Spacer()
        }
    }

    // MARK: - Illustration
    private var illustrationImage: some View {
        Image("hello_card")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: 250)
            .padding(.horizontal, 40)
    }

    // MARK: - Title
    private var titleText: some View {
        VStack(spacing: 0) {
            Text("What should we")
            Text("call you?")
        }
        .font(.custom("SF Pro", size: 36))
        .fontWeight(.bold)
        .foregroundColor(Color("priemary texts"))
    }

    // MARK: - Subtitle
    private var subtitleText: some View {
        Text("We'll use this to personalize your journey.")
            .font(.custom("SF Pro", size: 16))
            .fontWeight(.regular)
            .foregroundColor(Color("long texts"))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
    }

    // MARK: - Name TextField
    private var nameTextField: some View {
        TextField("Enter your name", text: $name)
            .font(.custom("SF Pro", size: 18))
            .fontWeight(.regular)
            .foregroundColor(Color("priemary texts"))
            .padding()
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color("boxes"))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal, 24)
            .textInputAutocapitalization(.sentences)
            .disableAutocorrection(false)
    }

    // MARK: - Let's Go Button
    private var letsGoButton: some View {
        Button(action: handleLetsGoAction) {
            Text("Let's go!")
                .font(.custom("SF Pro", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color("inside the green"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    trimmedName.isEmpty
                    ? Color("appGreen").opacity(0.5)
                    : Color("appGreen")
                )
                .cornerRadius(28)
        }
        .disabled(trimmedName.isEmpty)
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    // MARK: - Helpers
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func handleLetsGoAction() {
        guard !trimmedName.isEmpty else { return }

        // Save data
        UserDefaults.standard.set(trimmedName, forKey: "userName")
        hasCompletedOnboarding = true

        // Step 1: Fade out current screen
        withAnimation(.easeOut(duration: 0.4)) {
            contentOpacity = 0
        }

        // Step 2: Wait a bit, then show new screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            shouldNavigateToHome = true

            // Step 3: Fade in new screen
            withAnimation(.easeIn(duration: 0.5)) {
                homeOpacity = 1.0
            }
        }
    }
}

#Preview {
    EnterNameView()
}
