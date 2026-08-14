//
//  TipManager.swift
//  SARK
//
//  Created by hajer almejel on 27/02/1448 AH.
//

//
//  TipManager.swift
//  Sark
//
//  Created by ربى خالد الدوسري on 23/02/1448 AH.
//

import Foundation

struct TipsData: Codable {
    let tips: [Tip]
}

struct Tip: Codable, Identifiable {
    let id: Int
    let text: String
    let category: String
}

class TipManager {
    static let shared = TipManager()
    private var tips: [Tip] = []
    
    init() {
        loadTips()
    }
    
    private func loadTips() {
        guard let url = Bundle.main.url(forResource: "tips", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let tipsData = try? JSONDecoder().decode(TipsData.self, from: data) else {
            print("Failed to load tips.json")
            return
        }
        self.tips = tipsData.tips
        print("Successfully loaded \(tips.count) tips")
    }
    
    func getTodaysTip() -> String {
        guard !tips.isEmpty else {
            return "Focus on solving a real\nproblem for your customers"
        }
        
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let tipIndex = (dayOfYear - 1) % tips.count
        
        return tips[tipIndex].text
    }
    
    func getTipByCategory(_ category: String) -> String? {
        return tips.first(where: { $0.category == category })?.text
    }
    
    func getRandomTip() -> String {
        return tips.randomElement()?.text ?? "Keep growing your business!"
    }
}
