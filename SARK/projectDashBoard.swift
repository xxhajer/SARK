import SwiftUI

struct projectDashBoard: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID

    // CHANGE: بالتجربة، المستخدمين ما فهمو إن أيقونات "Quick Actions" كلها
    // قابلة للضغط (بس اللي جربوا البجت فهموا بالصدفة). أول محاولة كانت
    // حركة ضغط (scale/opacity) بس المستخدمة ما عجبتها الحركة نفسها.
    // الحين بدّلناها بتصميم "مرفوع" ثابت (ظل أعمق + مسافة أكبر تحت
    // البطاقة) يخلي كل أيقونة تبين زي زر حقيقي بارز عن الخلفية، بدون
    // أي حركة أو كتابة إضافية على البطاقة نفسها.
    @AppStorage("hasSeenQuickActionsHint") private var hasSeenQuickActionsHint = false
    @ObservedObject private var loc = LocalizationManager.shared

    private var business: Business? {
        store.businesses.first(where: { $0.id == businessID })
    }

    private var progressPercent: Int {
        Int((business?.progress ?? 0) * 100)
    }

    // Derived from the AI-generated roadmap, so this is no longer mock text.
    private var nextMilestoneTitle: String {
        guard let stages = business?.roadmapStages, !stages.isEmpty else {
            return "Generate your roadmap to see next steps"
        }
        if let next = stages.first(where: { $0.state != .completed }) {
            return next.title
        }
        return "All stages complete 🎉"
    }

    private var todaysGoalTitle: String {
        guard let stages = business?.roadmapStages, !stages.isEmpty else {
            return "Open Roadmap to generate your plan"
        }
        for stage in stages {
            if let objective = stage.objectives.first(where: { !$0.isCompleted }) {
                return objective.title
            }
        }
        return "All objectives complete!"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 0) {

                    // Header
                    HStack(spacing: 20) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                        }

                        Text(business?.name ?? "My Business")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    // Card 1: Current Stage & Progress
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.greeen)
                                .frame(width: 55, height: 60)
                                .overlay(
                                    Image("document")
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading, spacing: 6) {
                                Text(L("Current Stage"))
                                    .foregroundColor(.fadedText)
                                    .font(.system(size: 15, weight: .medium))
                                ExpandableText(
                                    text: business?.stageLabel ?? "Getting Started",
                                    collapsedLimit: 40,
                                    font: .system(size: 18, weight: .bold),
                                    color: .black
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .trailing, spacing: 6) {
                                Text(L("Overall Progress"))
                                    .foregroundColor(.black)
                                    .font(.system(size: 15, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                Text("\(progressPercent)%")
                                    .foregroundColor(.black)
                                    .font(.system(size: 32, weight: .bold))
                            }
                            .layoutPriority(1)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.orangee)
                                    .frame(width: geo.size.width * CGFloat(business?.progress ?? 0), height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: progressPercent)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    // Card 2: Today's Goal
                    HStack(alignment: .top, spacing: 16) {
                        Image("goal")

                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("Today's Goal"))
                                .foregroundColor(.insideTheGreen)
                                .font(.system(size: 16, weight: .medium))
                            ExpandableText(
                                text: todaysGoalTitle,
                                collapsedLimit: 70,
                                font: .system(size: 16, weight: .bold),
                                color: Color("inside the green"),
                                linkColor: .white
                            )
                        }

                        Spacer()
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.greeen)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    // Card 3: Milestone & Health
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L("Next Milestone"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)

                            ExpandableText(
                                text: nextMilestoneTitle,
                                collapsedLimit: 40,
                                font: .system(size: 15, weight: .bold),
                                color: .black
                            )

                            Spacer(minLength: 8)

                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.fadedText)
                                    .font(.system(size: 18))
                                Text(business?.timeline.isEmpty == false ? business!.timeline : "—")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.fadedText)
                                    .lineLimit(1)
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        )

                        // CHANGE: بدّلنا "Business Health" (كانت ثابتة تقول
                        // "Good" دايمًا بدون معنى) بكارد "Trend Insight" —
                        // نصيحة قصيرة من الـ AI مبنية على ترندات السوشيال
                        // ميديا بمجال المشروع (استفيدي منه / ابتعدي عنه).
                        NavigationLink(destination: TrendTipView(businessID: businessID)) {
                            VStack(spacing: 8) {
                                Text(L("Trend Insight"))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)

                                Spacer()

                                Image(systemName: (business?.trendTip?.stance ?? "leverage") == "avoid" ? "exclamationmark.triangle.fill" : "flame.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor((business?.trendTip?.stance ?? "leverage") == "avoid" ? Color("appOrange") : Color("appGreen"))

                                Spacer()

                                Text(business?.trendTip?.trendTitle ?? L("Tap for a tip"))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.75)
                            }
                            .padding(18)
                            .frame(width: 130) .frame (minHeight: 140)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 22)

                    // Card 4: Quick Actions (Unified Dimensions)
                    VStack(alignment: .leading, spacing: 14) {
                        Text(L("Quick Actions"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)

                        // CHANGE: تلميح يبين مرة وحدة بس أول ما تفتحين
                        // الداشبورد، يفهّم إن الأيقونات تحت تُضغط وتفتح
                        // صفحات — يختفي تلقائي أول ما تضغطين أي وحدة منهم.
                        if !hasSeenQuickActionsHint {
                            HStack(spacing: 6) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 12))
                                Text(L("Tap any icon below to open it"))
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(Color("appGreen"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color("appGreen").opacity(0.1))
                            .cornerRadius(12)
                        }

                        HStack(spacing: 12) {
                            NavigationLink(destination: IdeaEvaluationView(businessID: businessID)) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white)
                                        .frame(height: 88)
                                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                        .overlay(
                                            Image("ideaEva")
                                        )
                                    Text(L("Idea Evaluation"))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded { hasSeenQuickActionsHint = true })

                            NavigationLink(destination: BudgetOverviewView(businessID: businessID)) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white)
                                        .frame(height: 88)
                                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                        .overlay(
                                            Image("Wallet")
                                        )
                                    Text(L("Budget"))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded { hasSeenQuickActionsHint = true })

                            NavigationLink(destination: RoadmapView(businessID: businessID)) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white)
                                        .frame(height: 88)
                                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                        .overlay(
                                            Image("Roadmap")
                                        )
                                    Text(L("Roadmap"))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded { hasSeenQuickActionsHint = true })
                        }

                        Rectangle()
                            .fill(Color.insideTheGreen)
                            .frame(height: 1)
                            .padding(.top, 8)
                            .shadow(color: Color.insideTheGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadTrendTipIfNeeded()
        }
    }

    // CHANGE: نولّد الـ Trend Insight عشان يبين على الداشبورد مباشرة، وكل
    // فترة (لو مرت ٣ أيام) نجدده تلقائيًا عشان يحس إنه فعليًا مرتبط بترند
    // متغير مو جملة ثابتة للأبد.
    private func loadTrendTipIfNeeded() async {
        guard let idx = store.index(of: businessID) else { return }
        guard store.businesses[idx].trendTip == nil || store.businesses[idx].trendTipIsStale else { return }
        if let tip = try? await GeminiService.generateTrendTip(
            ideaText: store.businesses[idx].ideaText,
            industry: store.businesses[idx].industry,
            location: store.businesses[idx].location
        ) {
            store.businesses[idx].trendTip = tip
            store.businesses[idx].trendTipGeneratedAt = Date()
        }
    }
}

#Preview {
    NavigationStack {
        projectDashBoard(businessID: UUID())
    }
}

