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
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            Spacer()

            // زر الحفظ
            Button(action: {
                userName = tempName
                userEmail = tempEmail
                profileImageData = tempImageData
                dismiss()
            }) {
                Text("Save Changes")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.greeen))
            }
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
