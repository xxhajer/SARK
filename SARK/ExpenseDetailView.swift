//
//  ExpenseDetailView.swift
//  SARK
//

import SwiftUI

struct ExpenseDetailView: View {
    let expense: Expense

    var body: some View {
        ScrollView {
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
                    Text("Status: \(expense.status)")
                    if !expense.notes.isEmpty {
                        Text("Notes: \(expense.notes)")
                    }
                    if !expense.attachmentName.isEmpty {
                        Text("Attachment: \(expense.attachmentName) (\(expense.attachmentSize))")
                    }
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ExpenseDetailView(
            expense: Expense(
                title: "Logo Design",
                category: "Design",
                date: "May 12, 2025",
                amount: 500,
                paymentMethod: "Card",
                status: "Paid",
                assetName: "PaintBrush"
            )
        )
    }
}
