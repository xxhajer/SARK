//
//  Expenses.swift
//  SARK
//
//  Created by Danah yousef Almansour on 23/02/1448 AH.
//

import SwiftUI

// Codable so a business's AI-generated (or manually added) expenses can be
// saved to UserDefaults alongside the rest of that Business and reloaded
// after the app relaunches. `amount` is a real Double (not a formatted
// string) so totals/spent/remaining can be computed instead of hardcoded.
struct Expense: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var category: String = "General"
    var date: String = "Planned"
    var amount: Double
    var paymentMethod: String = "Bank Transfer"
    var status: String = "Paid"
    var notes: String = ""
    var assetName: String = "Box"
    var attachmentName: String = ""
    var attachmentSize: String = ""

    var amountFormatted: String {
        "SAR \(Int(amount.rounded()))"
    }
}
