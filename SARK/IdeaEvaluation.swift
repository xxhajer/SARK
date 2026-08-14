import SwiftUI

// MARK: - SCREEN 2: IdeaEvaluationView (Standalone UI View)
struct IdeaEvaluationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID
    var onFinishCreation: ((UUID) -> Void)? = nil
    var onReject: (() -> Void)? = nil

    // متغير للتحكم بفتح صفحة تسمية المشروع (بعد Accept) أو الرود ماب مباشرة
    // (لو البزنس متقبل مسبقًا وجايين من صفحة الداشبورد)
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

                        // Metrics Grid (4 Cards - Updated Unified Shadow)
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
                            // بزنس متقبل مسبقًا (رود ماب موجود أو راجعين له من الداشبورد)
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
                            // أول مرة يشوف التقييم — يقرر يتقبل الفكرة أو يرفضها
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
        // Accept → صفحة تسمية المشروع، ثم من هناك للرود ماب
        .navigationDestination(isPresented: $navigateToNaming) {
            NameYourProjectView(businessID: businessID, onFinishCreation: onFinishCreation)
        }
        // بزنس متقبل مسبقًا → الرود ماب مباشرة
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

    // MARK: - استدعاء Gemini API (أو استخدام النتيجة المخزنة سابقًا لهذا المشروع)
    private func loadEvaluation() async {
        guard let idx = businessIndex else {
            isLoading = false
            errorMessage = "Couldn't find this business."
            return
        }

        // إذا كانت النتيجة محفوظة مسبقًا لهذا المشروع، اعرضها مباشرة بدون نداء جديد.
        // (نستثني النتائج القديمة اللي محفوظة من قبل ما نضيف اسم البزنس، عشان
        // تنعاد وتاخذ اسم نظيف من الـ AI بدل الاسم المقصوص من نص الفكرة.)
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
                // CHANGE: نستبدل الاسم المؤقت (أول جزء من نص الفكرة) باسم
                // نظيف يصيغه الـ AI نفسه بناءً على فكرة المستخدم.
                let cleanName = result.suggestedBusinessName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleanName.isEmpty {
                    store.businesses[idx].name = cleanName
                }
            }
            isLoading = false
        } catch {
            isLoading = false
            // CHANGE: رجعناها رسالة نظيفة لليوزر بعد ما شخصنا السبب الحقيقي
            // (كان 429 rate limit من Gemini، مو مشكلة نت أو مفتاح).
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

// MARK: - Private Helper Component: Metric Card (Fixed Shadow)
private struct EvaluationMetricCard: View {
    let title: String
    let score: Int

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color("priemary texts"))
                .multilineTextAlignment(.center)
                .frame(height: 28)

            // CHANGE: هالأرقام (Market Demand, Feasibility, Competition,
            // Risk Level) هي أصلاً نسب من 0-100 — أضفنا علامة % عشان توضح
            // إنها نسبة مو رقم عادي، بدل ما تفهم غلط.
            Text("\(score)%")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("priemary texts"))
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
