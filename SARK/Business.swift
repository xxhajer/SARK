//
//  Business.swift
//  SARK
//
//  Shared, persisted model for a user's business/project.
//  Holds the original idea inputs plus everything the AI generates for it
//  (evaluation, roadmap, budget) so every screen shows THIS project's real
//  data instead of shared mock data.
//

import Foundation
import Combine

// MARK: - Business Model
struct Business: Identifiable, Codable {
    let id: UUID
    var name: String
    var iconName: String
    var lastUpdated: String

    // Original idea inputs (used to generate the AI content below)
    var ideaText: String
    var industry: String
    var location: String
    // CHANGE: حاليًا التطبيق يشتغل بس على السوق المحلي، فحفظنا هالحقل مع كل
    // مشروع — قيمة وحيدة الحين "Local (Saudi Arabia)" وجاهز نضيف له خيارات
    // ثانية بالمستقبل بدون تغيير التصميم.
    var marketScope: String
    var budgetRange: String
    var experience: String
    var goal: String
    var timeline: String
    var riskTolerance: String

    // Set true once the user taps "Accept" on the Idea Evaluation screen.
    // Before that, the business is still a pending draft the user can Reject.
    var isAccepted: Bool = false

    // AI-generated data. nil/empty until each screen generates it the first time.
    var evaluation: IdeaEvaluationResult?
    var roadmapStages: [RoadmapStage]?

    var budgetTotal: Double = 0
    var expenses: [Expense] = []

    // CHANGE: نحفظ تقييم كفاية الميزانية اللي يرجعه الـ AI مع البجت، عشان
    // التحذير يضل ظاهر حتى لو المستخدم سكر التطبيق وفتحه مرة ثانية، بدل
    // ما يختفي لأنه كان بس بالذاكرة المؤقتة.
    var isBudgetSufficient: Bool = true
    var budgetFeasibilityNote: String = ""
    // CHANGE: نحفظ قراءة الـ AI الرقمية لميزانية اليوزر (مو بس النص) عشان
    // نقدر نعرض رقم العجز الحقيقي بالواجهة، مثل "عندك عجز SAR 25,000".
    var statedBudget: Double = 0

    init(
        id: UUID = UUID(),
        name: String,
        ideaText: String,
        industry: String,
        location: String = "",
        marketScope: String = "Local (Saudi Arabia)",
        budgetRange: String = "",
        experience: String = "",
        goal: String = "",
        timeline: String = "",
        riskTolerance: String = "",
        isAccepted: Bool = false,
        iconName: String = "briefcase.fill",
        lastUpdated: String = "Just now"
    ) {
        self.id = id
        self.name = name
        self.ideaText = ideaText
        self.industry = industry
        self.location = location
        self.marketScope = marketScope
        self.budgetRange = budgetRange
        self.experience = experience
        self.goal = goal
        self.timeline = timeline
        self.riskTolerance = riskTolerance
        self.isAccepted = isAccepted
        self.iconName = iconName
        self.lastUpdated = lastUpdated
    }

    // Custom decode so businesses saved BEFORE `location`/`isAccepted` existed
    // still load instead of silently wiping out everything in BusinessStore.
    enum CodingKeys: String, CodingKey {
        case id, name, iconName, lastUpdated, ideaText, industry, location,
             marketScope,
             budgetRange, experience, goal, timeline, riskTolerance, isAccepted,
             evaluation, roadmapStages, budgetTotal, expenses,
             isBudgetSufficient, budgetFeasibilityNote, statedBudget
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        iconName = try container.decode(String.self, forKey: .iconName)
        lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        ideaText = try container.decode(String.self, forKey: .ideaText)
        industry = try container.decode(String.self, forKey: .industry)
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        marketScope = try container.decodeIfPresent(String.self, forKey: .marketScope) ?? "Local (Saudi Arabia)"
        budgetRange = try container.decode(String.self, forKey: .budgetRange)
        experience = try container.decode(String.self, forKey: .experience)
        goal = try container.decode(String.self, forKey: .goal)
        timeline = try container.decode(String.self, forKey: .timeline)
        riskTolerance = try container.decode(String.self, forKey: .riskTolerance)
        // Businesses saved before Accept/Reject existed already have real
        // roadmap/evaluation data, so treat them as accepted by default.
        isAccepted = try container.decodeIfPresent(Bool.self, forKey: .isAccepted) ?? true
        evaluation = try container.decodeIfPresent(IdeaEvaluationResult.self, forKey: .evaluation)
        roadmapStages = try container.decodeIfPresent([RoadmapStage].self, forKey: .roadmapStages)
        budgetTotal = try container.decodeIfPresent(Double.self, forKey: .budgetTotal) ?? 0
        expenses = try container.decodeIfPresent([Expense].self, forKey: .expenses) ?? []
        isBudgetSufficient = try container.decodeIfPresent(Bool.self, forKey: .isBudgetSufficient) ?? true
        budgetFeasibilityNote = try container.decodeIfPresent(String.self, forKey: .budgetFeasibilityNote) ?? ""
        statedBudget = try container.decodeIfPresent(Double.self, forKey: .statedBudget) ?? 0
    }

    // MARK: Derived progress (drives the Dashboard + My Businesses card)
    // Average of every roadmap stage's progress. Increases automatically the
    // moment an objective is checked off inside RoadmapDetailsView, because
    // that view writes straight back into this same stored roadmapStages array.
    var progress: Double {
        guard let stages = roadmapStages, !stages.isEmpty else { return 0.0 }
        let sum = stages.reduce(0) { $0 + $1.progressPercentage }
        return (Double(sum) / Double(stages.count)) / 100.0
    }

    var stageLabel: String {
        guard let stages = roadmapStages, !stages.isEmpty else { return "Getting Started" }
        if let inProgress = stages.first(where: { $0.state == .inProgress }) {
            return inProgress.title
        }
        if stages.allSatisfy({ $0.state == .completed }) { return "Completed" }
        return stages.first(where: { $0.state == .upcoming })?.title ?? stages[0].title
    }

    // MARK: Derived budget numbers
    var spent: Double { expenses.reduce(0) { $0 + $1.amount } }
    var remaining: Double { budgetTotal - spent }
    var usedPercentage: Int {
        guard budgetTotal > 0 else { return 0 }
        return Int((spent / budgetTotal) * 100)
    }

    // كم ينقص المستخدم فعليًا عشان يوصل للتكلفة الواقعية (0 لو ميزانيته كافية)
    var budgetShortfall: Double {
        max(0, budgetTotal - statedBudget)
    }
}

// MARK: - Shared, persisted store
// A single source of truth for every business, used by MyBusinessesView,
// projectDashBoard, RoadmapView, BudgetOverviewView, and profile. Any screen
// that edits `businesses` (e.g. checking off a roadmap objective, or adding
// an expense) is reflected everywhere else immediately, and is saved to
// UserDefaults as JSON so it survives an app relaunch.
final class BusinessStore: ObservableObject {
    static let shared = BusinessStore()

    @Published var businesses: [Business] = [] {
        didSet {
            guard !isLoading else { return }
            save()
        }
    }

    private let storageKey = "sark_businesses_v1"
    private var isLoading = false

    private init() {
        load()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Business].self, from: data) else { return }
        isLoading = true
        businesses = decoded
        isLoading = false
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(businesses) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func addBusiness(_ business: Business) {
        businesses.append(business)
    }

    func index(of id: UUID) -> Int? {
        businesses.firstIndex(where: { $0.id == id })
    }

    // Used when the user Rejects an idea on the Idea Evaluation screen —
    // the pending draft business is discarded entirely.
    func removeBusiness(_ id: UUID) {
        businesses.removeAll(where: { $0.id == id })
    }

    // Used by "Delete Your Account" so a full account reset also clears businesses.
    func removeAll() {
        businesses.removeAll()
    }
}
