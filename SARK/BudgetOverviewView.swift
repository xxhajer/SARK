
//
//  BudgetOverviewView.swift
//  SARK
//
//  Created by Danah yousef Almansour on 22/02/1448 AH.
//

import SwiftUI

struct BudgetOverviewView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID

    // State variables
    @State private var isShowingAddExpense = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private var businessIndex: Int? { store.index(of: businessID) }
    private var business: Business? {
        guard let idx = businessIndex else { return nil }
        return store.businesses[idx]
    }

    // CHANGE: كانت تعرض آخر 4 مصاريف بالبيت اوفرفيو، صار مزدحم بالشاشة —
    // اليوزر طلب يبين بس 2 هنا (والباقي يشوفه من "View All").
    private var recentExpenses: [Expense] {
        Array((business?.expenses ?? []).suffix(2).reversed())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if let errorMessage {
                errorView(message: errorMessage)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: Top Navigation Header
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color("priemary text"))
                            }
                            Spacer()
                            Text(business?.name ?? "Budget")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color("priemary text"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                            Color.clear.frame(width: 18, height: 18)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // MARK: Header Titles
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Budget Overview")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color("priemary text"))
                            Text("Track all project expenses in one place.")
                                .font(.system(size: 14))
                                .foregroundColor(Color("faded text"))
                        }
                        .padding(.horizontal)

                        // MARK: Budget Feasibility Warning
                        // CHANGE: لو الـ AI حلل إن الميزانية الي اختارها اليوزر
                        // ماتكفي واقعيًا لفتح هذا المشروع، نعرض تحذير فيه أرقام
                        // العجز الفعلية (ميزانيتك / التكلفة الواقعية / الفرق)
                        // بدل جملة عامة بس — عشان يبين بوضوح إن فيه عجز فعلي.
                        if let business, !business.isBudgetSufficient {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color("appOrange"))
                                    Text(business.budgetFeasibilityNote.isEmpty
                                         ? "Your stated budget may not be enough to realistically launch this business."
                                         : business.budgetFeasibilityNote)
                                        .font(.system(size: 13))
                                        .foregroundColor(Color("priemary text"))
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                HStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Your Budget")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color("faded text"))
                                        Text("SAR \(Int(business.statedBudget.rounded()))")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color("priemary text"))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    Divider().frame(height: 28)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Realistic Cost")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color("faded text"))
                                        Text("SAR \(Int(business.budgetTotal.rounded()))")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color("priemary text"))
                                    }
                                    .padding(.leading, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    Divider().frame(height: 28)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Shortfall")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color("faded text"))
                                        Text("SAR \(Int(business.budgetShortfall.rounded()))")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color("appOrange"))
                                    }
                                    .padding(.leading, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(14)
                            .background(Color("appOrange").opacity(0.12))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }

                        // MARK: Total Budget Summary Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Total Budget")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color("faded text"))
                                    Text("SAR \(Int((business?.budgetTotal ?? 0).rounded()))")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(Color("priemary text"))
                                }
                                Spacer()
                                Image("Wallet")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                            }

                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Spent")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color("faded text"))
                                    Text("SAR \(Int((business?.spent ?? 0).rounded()))")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Color("appOrange"))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Divider().frame(height: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Remaining")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color("faded text"))
                                    Text("SAR \(Int((business?.remaining ?? 0).rounded()))")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Color("appGreen"))
                                }
                                .padding(.leading, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Divider().frame(height: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Used")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color("faded text"))
                                    Text("\(business?.usedPercentage ?? 0)%")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Color("priemary text"))
                                }
                                .padding(.leading, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .background(Color("boxes"))
                        .cornerRadius(20)
                        .padding(.horizontal)

                        // MARK: Recent Expenses Section
                        VStack(spacing: 12) {
                            HStack {
                                Text("Recent Expenses")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("priemary text"))

                                Spacer()

                                NavigationLink(destination: AllExpensesView(businessID: businessID)) {
                                    Text("View All")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color("appGreen"))
                                }
                            }
                            .padding(.horizontal, 4)

                            if recentExpenses.isEmpty {
                                Text("No expenses yet.")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("faded text"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(Color("boxes"))
                                    .cornerRadius(20)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(Array(recentExpenses.enumerated()), id: \.element.id) { index, expense in
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

                                        if index < recentExpenses.count - 1 {
                                            Divider().padding(.leading, 62)
                                        }
                                    }
                                }
                                .background(Color("boxes"))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)

                        // MARK: Add Expense Button
                        Button(action: {
                            isShowingAddExpense = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Add Expense")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color("appGreen"))
                            .cornerRadius(26)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)

                        Spacer().frame(height: 80)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isShowingAddExpense) {
            AddExpenseView(businessID: businessID)
        }
        .task {
            await loadBudgetIfNeeded()
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Building your budget...")
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(Color("appOrange"))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color("faded text"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button(action: {
                Task { await loadBudgetIfNeeded(forceReload: true) }
            }) {
                Text("Try Again")
            }
            .buttonStyle(PrimaryAppButtonStyle())
            .frame(maxWidth: 200)
            Spacer()
        }
    }

    // MARK: - Generate the budget once per business, from its idea + chosen budget range.
    private func loadBudgetIfNeeded(forceReload: Bool = false) async {
        guard let idx = businessIndex else { return }
        let alreadyGenerated = store.businesses[idx].budgetTotal > 0 || !store.businesses[idx].expenses.isEmpty
        guard forceReload || !alreadyGenerated else { return }

        isLoading = true
        errorMessage = nil
        do {
            let result = try await GeminiService.generateBudget(
                ideaText: store.businesses[idx].ideaText,
                industry: store.businesses[idx].industry,
                location: store.businesses[idx].location,
                budgetRange: store.businesses[idx].budgetRange
            )
            store.businesses[idx].budgetTotal = result.totalBudget
            store.businesses[idx].expenses = result.expenses
            store.businesses[idx].isBudgetSufficient = result.isBudgetSufficient
            store.businesses[idx].budgetFeasibilityNote = result.feasibilityNote
            store.businesses[idx].statedBudget = result.statedBudget
            isLoading = false
        } catch {
            isLoading = false
            // CHANGE: رجعناها رسالة نظيفة لليوزر بعد ما شخصنا السبب الحقيقي
            // (كان 429 rate limit من Gemini، مو مشكلة نت أو مفتاح) — الحين
            // الرسالة تتغير تلقائيًا لو صار نفس الموقف مرة ثانية.
            errorMessage = GeminiServiceError.userFacingMessage(for: error, action: "build your budget")
        }
    }
}

#Preview {
    NavigationStack {
        BudgetOverviewView(businessID: UUID())
    }
}
