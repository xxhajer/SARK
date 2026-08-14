//
//  StreakManager.swift
//  SARK
//
//  Tracks the user's daily "streak" shown on the Profile screen: consecutive
//  days where the user actually completed at least one roadmap task
//  (objective). Opening the app alone does NOT count — only finishing a
//  task does, since that's the real signal of staying on track.
//

import Foundation
import Combine

final class StreakManager: ObservableObject {
    static let shared = StreakManager()

    @Published private(set) var currentStreak: Int

    private let streakKey = "sark_streak_count"
    private let lastCompletionKey = "sark_streak_last_completion_date"

    private init() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        refreshBrokenStreak()
    }

    private var lastCompletionDay: String? {
        UserDefaults.standard.string(forKey: lastCompletionKey)
    }

    // Call whenever the user checks off a roadmap objective (marks it
    // complete). Extends the streak if yesterday also had a completion,
    // otherwise starts a fresh streak of 1. Only counts once per day.
    func recordTaskCompletion() {
        let today = Self.dayKey(for: Date())
        guard lastCompletionDay != today else { return }

        if let last = lastCompletionDay, Self.isDay(last, theDayBefore: today) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(today, forKey: lastCompletionKey)
    }

    // Call when the app/profile appears. If a full day passed with no
    // completion at all (missed a day), the streak is broken and resets.
    func refreshBrokenStreak() {
        guard let last = lastCompletionDay else { return }
        let today = Self.dayKey(for: Date())
        if last == today { return }
        if Self.isDay(last, theDayBefore: today) { return }
        currentStreak = 0
        UserDefaults.standard.set(0, forKey: streakKey)
    }

    // Used by "Delete Your Account" so a full reset also clears the streak.
    func reset() {
        currentStreak = 0
        UserDefaults.standard.removeObject(forKey: streakKey)
        UserDefaults.standard.removeObject(forKey: lastCompletionKey)
    }

    private static func dayKey(for date: Date) -> String {
        dayFormatter.string(from: date)
    }

    private static func isDay(_ dayKey: String, theDayBefore todayKey: String) -> Bool {
        guard let dayDate = dayFormatter.date(from: dayKey),
              let todayDate = dayFormatter.date(from: todayKey) else { return false }
        let calendar = Calendar(identifier: .gregorian)
        guard let expectedYesterday = calendar.date(byAdding: .day, value: -1, to: todayDate) else { return false }
        return calendar.isDate(dayDate, inSameDayAs: expectedYesterday)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
