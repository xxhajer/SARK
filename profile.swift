//
//  profile.swift
//  SARK
//
//  Created by hajer almejel on 26/02/1448 AH.
//
import SwiftUI

struct profile: View {
    @State private var selectedTab = 2
    @State private var showEditProfile = false
    @State private var showNotifications = false
    @State private var profileImageData: Data? = nil
    
    @State private var userName: String = "Leena"
    @State private var userEmail: String = ""
    
    var body: some View {
        ZStack(alignment: .bottom){
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView() {
                // صف الهيدر
                ZStack() {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        // زر الجرس (رجعناه لشكله الأصلي بدون أي كود صورة)
                        Button(action: {
                            showNotifications = true
                        }) {
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
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // كرت البروفايل
                VStack(spacing: 13) {
                    // الصورة الشخصية (تعرض صورة المستخدم لو موجودة، وإلا الافتراضية)
                    Group {
                        if let data = profileImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image("profilePic")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    Text(userName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(userEmail.isEmpty ? "enter your email" : userEmail)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(userEmail.isEmpty ? .fadedText : .black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 380, height: 220)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    Button(action: {
                        showEditProfile = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 24))
                            .foregroundColor(.greeen)
                            .frame(width: 45, height: 45)
                            .background(
                                Circle()
                                    .fill(Color.background)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                    }
                    .padding(.leading, 30)
                    .padding(.bottom, 25),
                    alignment: .bottomLeading
                )
                .padding(.bottom, 15)
                
                // خط فاصل رمادي
                Rectangle()
                    .fill(Color.fadedText.opacity(0.4))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.fadedText.opacity(0.2), radius: 80, x: 80, y: 80)
                    .padding(.bottom, 10)
                
                // صف الإحصائيات
                HStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("Businesses")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.insideTheGreen)
                        Text("2")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.insideTheGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.greeen)
                    )

                    VStack(spacing: 8) {
                        Text("Current Streak")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.insideTheGreen)
                        HStack(spacing: 4) {
                            Text("12")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.insideTheGreen)
                            Text("🔥")
                                .font(.system(size: 24))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.greeen)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                
                // عنوان Upcoming Features
                Text("Upcoming Features")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.fadedText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)

                // كرت Premium Membership
                VStack(alignment: .leading, spacing: 10) {

                    Text("Premium Membership ✨")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.orangee)

                    Text("These features are in the works - join the waitlist to get early access")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.fadedText)
                        .multilineTextAlignment(.leading)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.greeen)
                            Text("Personalized AI Coaching")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.greeen)
                            Text("Deeper Business Research")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.greeen)
                            Text("Unlimited Coaching Conversations")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                        .frame(width: 380, height: 190)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                )
                .padding(.bottom, 100)
            }
            
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 10)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(userName: $userName, userEmail: $userEmail, profileImageData: $profileImageData)
        }
        .fullScreenCover(isPresented: $showNotifications) {
            NotificationsView()
        }
    }
}

#Preview {
    profile()
}
