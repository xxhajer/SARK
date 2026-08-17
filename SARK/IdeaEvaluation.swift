import SwiftUI

// MARK: - SCREEN 2: IdeaEvaluationView (Standalone UI View)
struct IdeaEvaluationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID
    var onFinishCreation: ((UUID) -> Void)? = nil
    var onReject: (() -> Void)? = nil

    // متغير للتحكم بفتح صفحة تسمية المشروع (بعد Accept) أو الرود ماب مباشرة
    @State private var navigateToNaming: Bool = false
    @State private var navigateToRoadmap: Bool = false

    // حالة تحميل نتائج الذكاء الاصطناعي
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    // بيانات العرض (تتعبى من Gemini API)
    @State private var overallScore: Int = 0
    @State private var scoreFeedback: String = ""
    @State private var marketDemand: Int = 0
    @State private var feasibility: Int = 0
    @State private var competition: Int = 0
    @State private var riskLevel: Int = 0
    @State private var strengths: [String] = []
    @State private var weaknesses: [String] = []
    @State private var aiRecommendation: String = ""

    private var businessIndex: Int? { store.index(of: businessID) }
    private var isAccepted: Bool { businessIndex.map { store.businesses[$0].isAccepted } ?? false }

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color("priemary texts"))
                }
                Spacer()
                Text("Idea Evaluation")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("priemary texts"))
                Spacer()
                Color.clear.frame(width: 20, height: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            if isLoading {
                Spacer()
                ProgressView("Analyzing your idea...")
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            } else if let errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(Color("appOrange"))
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Color("faded text"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    Button(action: {
                        Task { await loadEvaluation() }
                    }) {
                        Text("Try Again")
                    }
                    .buttonStyle(PrimaryAppButtonStyle())
                    .frame(maxWidth: 200)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Overall Score Box
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Overall Score")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color("priemary texts"))

                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(overallScore)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(Color("appOrange"))

                                Text("/100")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color("priemary texts"))
                            }

                            Text(scoreFeedback)
                                .font(.system(size: 13))
                                .foregroundColor(Color("faded text"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color("boxes"))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                        // Metrics Grid (4 Cards مع التلوين: أحمر، أصفر، أخضر)
                        HStack(spacing: 10) {
                            EvaluationMetricCard(title: "Market Demand", score: marketDemand)
                            EvaluationMetricCard(title: "Feasibility", score: feasibility)
                            EvaluationMetricCard(title: "Competition", score: competition)
                            EvaluationMetricCard(title: "Risk Level", score: riskLevel)
                        }

                        // Strengths & Weaknesses
                        HStack(alignment: .top, spacing: 12) {
                            EvaluationAnalysisBox(title: "Strengths", items: strengths)
                            EvaluationAnalysisBox(title: "Weaknesses", items: weaknesses)
                        }

                        // AI Recommendation Box
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("AI Recommendation")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color("priemary texts"))

                                Spacer()

                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("appOrange"))
                            }

                            Text(aiRecommendation)
                                .font(.system(size: 13))
                                .foregroundColor(Color("faded text"))
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(Color("boxes"))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                        // Action Buttons
                        if isAccepted {
                            Button(action: {
                                navigateToRoadmap = true
                            }) {
                                HStack(spacing: 8) {
                                    Text("Open Roadmap")
                                        .font(.system(size: 16, weight: .semibold))

                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                            .buttonStyle(PrimaryAppButtonStyle())
                            .padding(.top, 8)
                        } else {
                            HStack(spacing: 12) {
                                Button(action: {
                                    rejectIdea()
                                }) {
                                    Text("Reject")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 52)
                                        .background(
                                            RoundedRectangle(cornerRadius: 26)
                                                .stroke(Color.red, lineWidth: 1)
                                        )
                                }

                                Button(action: {
                                    acceptIdea()
                                }) {
                                    HStack(spacing: 6) {
                                        Text("Accept")
                                            .font(.system(size: 16, weight: .semibold))
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                                .buttonStyle(PrimaryAppButtonStyle())
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color("Background").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToNaming) {
            NameYourProjectView(businessID: businessID, onFinishCreation: onFinishCreation)
        }
        .navigationDestination(isPresented: $navigateToRoadmap) {
            RoadmapView(businessID: businessID, onFinishCreation: onFinishCreation)
        }
        .task {
            await loadEvaluation()
        }
    }

    private func acceptIdea() {
        guard let idx = businessIndex else { return }
        store.businesses[idx].isAccepted = true
        navigateToNaming = true
    }

    private func rejectIdea() {
        store.removeBusiness(businessID)
        if let onReject {
            onReject()
        } else {
            dismiss()
        }
    }

    // MARK: - استدعاء Gemini API
    private func loadEvaluation() async {
        guard let idx = businessIndex else {
            isLoading = false
            errorMessage = "Couldn't find this business."
            return
        }

        if let cached = store.businesses[idx].evaluation, !cached.suggestedBusinessName.isEmpty {
            populate(from: cached)
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        let business = store.businesses[idx]
        do {
            let result = try await GeminiService.evaluateIdea(
                ideaText: business.ideaText,
                industry: business.industry,
                location: business.location,
                budget: business.budgetRange,
                experience: business.experience,
                goal: business.goal,
                timeline: business.timeline,
                riskTolerance: business.riskTolerance
            )
            populate(from: result)
            if let idx = businessIndex {
                store.businesses[idx].evaluation = result
                let cleanName = result.suggestedBusinessName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleanName.isEmpty {
                    store.businesses[idx].name = cleanName
                }
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = GeminiServiceError.userFacingMessage(for: error, action: "analyze your idea")
        }
    }

    private func populate(from result: IdeaEvaluationResult) {
        overallScore = result.overallScore
        scoreFeedback = result.scoreFeedback
        marketDemand = result.marketDemand
        feasibility = result.feasibility
        competition = result.competition
        riskLevel = result.riskLevel
        strengths = result.strengths
        weaknesses = result.weaknesses
        aiRecommendation = result.aiRecommendation
    }
}

// MARK: - Metric Card Component (تلوين الأرقام: أحمر، أصفر، أخضر)
private struct EvaluationMetricCard: View {
    let title: String
    let score: Int

    private var scoreColor: Color {
        switch score {
        case 0...49:
            return .red
        case 50...79:
            return .yellow
        case 80...100:
            return Color("appGreen")
        default:
            return Color("priemary texts")
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color("priemary texts"))
                .multilineTextAlignment(.center)
                .frame(height: 28)

            Text("\(score)%")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(scoreColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(Color("boxes"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Private Helper Component: Analysis Box
private struct EvaluationAnalysisBox: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color("priemary texts"))

            VStack(alignment: .leading, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("faded text"))

                        Text(item)
                            .font(.system(size: 12))
                            .foregroundColor(Color("faded text"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color("boxes"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        IdeaEvaluationView(businessID: UUID())
    }
}
