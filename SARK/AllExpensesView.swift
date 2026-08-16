
//
//  AllExpensesView.swift
//  SARK
//
//  Created by Danah yousef Almansour on 22/02/1448 AH.
//

import SwiftUI

struct AllExpensesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID

    // Search & Filter States
    @State private var searchText = ""
    @State private var selectedFilter = "This Month"
    @State private var showingAddExpense = false

    private var business: Business? {
        store.businesses.first(where: { $0.id == businessID })
    }

    private var allExpenses: [Expense] {
        business?.expenses ?? []
    }

    var filteredExpenses: [Expense] {
        if searchText.isEmpty {
            return allExpenses
        } else {
            return allExpenses.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private var categoryCount: Int {
        Set(allExpenses.map { $0.category }).count
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("priemary text"))
                        }

                        Spacer()

                        Text("All Expenses")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("priemary text"))

                        Spacer()

                        Button(action: {
                            showingAddExpense = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color("priemary text"))
                                .frame(width: 18, height: 18)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // MARK: - Search Bar & Filter Button
                    HStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(Color("faded text"))

                            TextField("Search expenses..", text: $searchText)
                                .font(.system(size: 15))
                                .foregroundColor(Color("priemary text"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color("boxes"))
                        .cornerRadius(20)

                        Menu {
                            Button("This Month") { selectedFilter = "This Month" }
                            Button("Last Month") { selectedFilter = "Last Month" }
                            Button("All Time") { selectedFilter = "All Time" }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color("priemary text"))
                                .frame(width: 50, height: 50)
                                .background(Color("boxes"))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Total Spent Summary Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Total Spent")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("faded text"))

                                Text(business.map { "SAR \(Int($0.spent.rounded()))" } ?? "SAR 0")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(Color("priemary text"))
                            }

                            Spacer()

                            HStack(spacing: 4) {
                                Text(selectedFilter)
                                    .font(.system(size: 13, weight: .semibold))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(Color("priemary text"))
                        }
                    }
                    .padding(20)
                    .background(Color("boxes"))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // MARK: - Expenses List with Navigation Links
                    if filteredExpenses.isEmpty {
                        Text("No expenses yet.")
                            .font(.system(size: 14))
                            .foregroundColor(Color("faded text"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(filteredExpenses.enumerated()), id: \.element.id) { index, expense in
                                NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                                    HStack(spacing: 14) {
                                        Image(expense.assetName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(expense.title)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color("priemary text"))
                                                .multilineTextAlignment(.leading)
                                            Text(expense.date)
                                                .font(.system(size: 12))
                                                .foregroundColor(Color("faded text"))
                                                .multilineTextAlignment(.leading)
                                        }

                                        Spacer()

                                        Text(expense.amountFormatted)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color("priemary text"))

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color("faded text"))
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                }

                                if index < filteredExpenses.count - 1 {
                                    Divider()
                                        .padding(.leading, 62)
                                }
                            }
                        }
                        .background(Color("boxes"))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }

                    Spacer()
                        .frame(height: 40)
                }
            }
            // CHANGE: removed the local CustomTabBar — this screen is pushed
            // from Budget Overview, not a tab-bar page. Only MainTabView
            // should ever draw the tab bar.
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(businessID: businessID)
        }
    }
}

#Preview {
    NavigationStack {
        AllExpensesView(businessID: UUID())
    }
}
