
//
//  AddExpenseView.swift
//  SARK
//
//  Created by Danah yousef Almansour on 22/02/1448 AH.
//

import SwiftUI

// Category item model
struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let assetName: String
}

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID

    // Form States
    @State private var amount: String = ""
    @State private var expenseName: String = ""
    @State private var selectedCategory: String = "Design"
    @State private var selectedDate = Date()
    @State private var notes: String = ""

    let categories = [
        CategoryItem(name: "Design", assetName: "PaintBrush"),
        CategoryItem(name: "Marketing", assetName: "speakers"),
        CategoryItem(name: "Supplies", assetName: "World"),
        CategoryItem(name: "Other", assetName: "Box")
    ]

    private var assetName: String {
        categories.first(where: { $0.name == selectedCategory })?.assetName ?? "Box"
    }

    // CHANGE: كان الفورم يعلق بدون أي رسالة خطأ لو كتبتِ الرقم بفواصل
    // (زي "200,000") — لأن Double("200,000") يرجع nil بسويفت، فالزر
    // يضل رمادي مايشتغل من غير أي تفسير ليه. هذا كان يصير خصوصًا لما
    // تكتبين من كيبورد الماك الفيزيائي بالسيميوليتر (يسمح بحرف الفاصلة
    // حتى لو الحقل decimalPad). الحين ننظف الفاصلة والمسافات قبل التحقق.
    private var sanitizedAmount: String {
        amount.filter { $0.isNumber || $0 == "." }
    }

    private var isFormValid: Bool {
        !expenseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(sanitizedAmount) != nil
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 22))
                                .foregroundColor(Color("PrimaryText"))
                        }

                        Spacer()

                        Text("Add Expense")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        Spacer()

                        Color.clear
                            .frame(width: 22, height: 22)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // MARK: - Amount Input Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        HStack(spacing: 8) {
                            Text("SAR")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("faded text"))

                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(Color("priemary texts"))
                                // CHANGE: نمنع أي حرف غير رقم أو نقطة عشرية
                                // وقت الكتابة نفسها، عشان ما نوصل لحالة يعلّق
                                // فيها الفورم بدون سبب واضح.
                                .onChange(of: amount) { newValue in
                                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                    if filtered != newValue {
                                        amount = filtered
                                    }
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color("Boxes"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // MARK: - Expense Name Input Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expense Name")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        TextField("e.g Logo Design", text: $expenseName)
                            .font(.system(size: 15))
                            .foregroundColor(Color("priemary texts"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color("Boxes"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // MARK: - Category Selection Grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Category")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        HStack(spacing: 12) {
                            ForEach(categories) { category in
                                Button(action: {
                                    selectedCategory = category.name
                                }) {
                                    VStack(spacing: 8) {
                                        Image(category.assetName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 28, height: 28)

                                        Text(category.name)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color("priemary texts"))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 76)
                                    .background(Color("Boxes"))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                selectedCategory == category.name ? Color("appGreen") : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Date Picker Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        HStack {
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .accentColor(Color("appGreen"))

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color("Boxes"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // MARK: - Notes Input Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (optional)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        TextField("Add a note...", text: $notes, axis: .vertical)
                            .lineLimit(3...4)
                            .font(.system(size: 15))
                            .foregroundColor(Color("priemary texts"))
                            .padding(16)
                            .background(Color("Boxes"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // MARK: - Save Expense Button
                    Button(action: {
                        saveExpense()
                    }) {
                        Text("Save Expense")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(isFormValid ? Color("appGreen") : Color("appGreen").opacity(0.4))
                            .cornerRadius(26)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal)
                    .padding(.top, 4)

                    Spacer()
                        .frame(height: 40)
                }
            }
            // CHANGE: removed the local CustomTabBar — this is a sub-screen
            // presented as a sheet from Budget Overview, not a tab-bar page.
            // Only MainTabView should ever draw the tab bar.
        }
    }

    private func saveExpense() {
        guard let amountValue = Double(sanitizedAmount) else { return }
        let formattedDate = DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .none)

        let newExpense = Expense(
            title: expenseName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            date: formattedDate,
            amount: amountValue,
            status: "Paid",
            notes: notes,
            assetName: assetName
        )

        if let idx = store.index(of: businessID) {
            store.businesses[idx].expenses.append(newExpense)
            if store.businesses[idx].budgetTotal < store.businesses[idx].spent {
                store.businesses[idx].budgetTotal = store.businesses[idx].spent
            }
        }

        dismiss()
    }
}

#Preview {
    AddExpenseView(businessID: UUID())
}
