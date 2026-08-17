//
//  EditProfileView.swift
//  SARK
//
//  Created by hajer almejel on 26/02/1448 AH.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {

    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var profileImageData: Data?

    @Environment(\.dismiss) var dismiss

    // نسخة مؤقتة نعدل عليها لين يضغط Save
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    @State private var tempImageData: Data? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    // CHANGE: تحقق حقيقي من صيغة الإيميل — فاضي مسموح (يعني ما بعد حط ايميل)،
    // لكن أي نص غير فاضي لازم يكون فعليًا شكل إيميل صحيح.
    private var isEmailValid: Bool {
        let trimmed = tempEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: emailRegex, options: .regularExpression) != nil
    }

    var body: some View {

            VStack(alignment: .leading, spacing: 20) {

                // الهيدر
                ZStack {
                    Text("Edit Profile")
                        .font(.system(size: 22, weight: .bold))
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
                .padding(.top, 10)

                // الصورة + أيقونة الكاميرا (اختيار صورة حقيقية)
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let data = tempImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image("profilePic")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(Color.greeen))
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                .frame(maxWidth: .infinity)
                .onChange(of: selectedPhotoItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            tempImageData = data
                        }
                    }
                }

                // حقل الاسم
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.system(size: 14))
                        .foregroundColor(.fadedText)
                    TextField("Name", text: $tempName)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.greeen, lineWidth: 1.5)
                        )
                }

                // حقل الإيميل
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.system(size: 14))
                        .foregroundColor(.fadedText)
                    TextField("e.g. leena@gmail.com", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isEmailValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: isEmailValid ? 1 : 1.5)
                        )
                    // CHANGE: تحقق فعلي من صيغة الإيميل بدل قبول أي نص
                    if !isEmailValid {
                        Text("Please enter a valid email address.")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }

                Spacer()

                // زر الحفظ
                Button(action: {
                    guard isEmailValid else { return }
                    let trimmedEmail = tempEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                    userName = tempName
                    userEmail = trimmedEmail
                    profileImageData = tempImageData
                    UserDefaults.standard.set(tempName, forKey: "userName")
                    UserDefaults.standard.set(trimmedEmail, forKey: "userEmail")
                    dismiss()
                }) {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(isEmailValid ? Color.greeen : Color.greeen.opacity(0.4)))
                }
                .disabled(!isEmailValid)
            }
            .padding(.horizontal, 20)
            .onAppear {
                tempName = userName
                tempEmail = userEmail
                tempImageData = profileImageData
            }
        }
    }


#Preview {
    EditProfileView(userName: .constant("Leena"), userEmail: .constant(""), profileImageData: .constant(nil))
}
