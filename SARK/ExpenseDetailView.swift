//
//  ExpenseDetailView.swift
//  SARK
//

import SwiftUI

// CHANGE: صارت الشاشة تقدر تعدّل حالة المصروف (نفّذتها / ماذفّذتها) وتحذفه
// — قبل كذا كانت للعرض بس، فما كان فيه أي طريقة تحددين فيها إن الفاتورة
// لسه مخططة ومو مصروفة فعليًا، ولا طريقة تشيلينها لو ما ودك فيها.
struct ExpenseDetailView: View {
    let businessID: UUID
    let expenseID: UUID

    @ObservedObject private var store = BusinessStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    private var businessIndex: Int? { store.index(of: businessID) }
    private var expenseIndex: Int? {
        guard let bIdx = businessIndex else { return nil }
        return store.businesses[bIdx].expenses.firstIndex(where: { $0.id == expenseID })
    }
    private var expense: Expense? {
        guard let bIdx = businessIndex, let eIdx = expenseIndex else { return nil }
        return store.businesses[bIdx].expenses[eIdx]
    }

    private var isPaid: Bool { expense?.status == "Paid" }

    var body: some View {
        ScrollView {
            if let expense {
                VStack(alignment: .leading, spacing: 16) {
                    Image(expense.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)

                    Text(expense.title)
                        .font(.system(size: 22, weight: .bold))

                    Text(expense.amountFormatted)
                        .font(.system(size: 20, weight: .bold))

                    Group {
                        Text("Category: \(expense.category)")
                        Text("Date: \(expense.date)")
                        Text("Payment Method: \(expense.paymentMethod)")
                        if !expense.notes.isEmpty {
                            Text("Notes: \(expense.notes)")
                        }
                        if !expense.attachmentName.isEmpty {
                            Text("Attachment: \(expense.attachmentName) (\(expense.attachmentSize))")
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                    // MARK: - Executed / Not Executed toggle
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        HStack(spacing: 10) {
                            statusButton(title: "Executed", isSelected: isPaid) {
                                setStatus("Paid")
                            }
                            statusButton(title: "Not Executed", isSelected: !isPaid) {
                                setStatus("Planned")
                            }
                        }
                    }
                    .padding(.top, 8)

                    Button(role: .destructive, action: {
                        showDeleteConfirm = true
                    }) {
                        Text("Delete Expense")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(14)
                    }
                    .padding(.top, 16)
                }
                .padding()
            } else {
                Text("This expense no longer exists.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete this expense?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteExpense()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func statusButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color("priemary texts"))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? Color("appGreen") : Color("boxes"))
                .cornerRadius(12)
        }
    }

    private func setStatus(_ newStatus: String) {
        guard let bIdx = businessIndex, let eIdx = expenseIndex else { return }
        store.businesses[bIdx].expenses[eIdx].status = newStatus
    }

    private func deleteExpense() {
        guard let bIdx = businessIndex, let eIdx = expenseIndex else { return }
        store.businesses[bIdx].expenses.remove(at: eIdx)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ExpenseDetailView(businessID: UUID(), expenseID: UUID())
    }
}
