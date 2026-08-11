import SwiftUI

// MARK: - SCREEN 2: IdeaEvaluationView (Standalone UI View)
struct IdeaEvaluationView: View {
    @Environment(\.dismiss) private var dismiss
    var onFinishCreation: (() -> Void)? = nil
    
    // متغير للتحكم بفتح صفحة الـ Roadmap
    @State private var navigateToRoadmap: Bool = false
    
    // بيانات العرض الحالية (Dummy / Mock Data)
    let overallScore: Int = 84
    let scoreFeedback: String = "Great potential! keep going!"
    let marketDemand: Int = 85
    let feasibility: Int = 80
    let competition: Int = 70
    let riskLevel: Int = 40
    
    let strengths: [String] = [
        "Strong market demand",
        "Clear target audience",
        "Good profit potential"
    ]
    
    let weaknesses: [String] = [
        "High initial competition",
        "Requires good location",
        "Marketing is critical"
    ]
    
    let aiRecommendation: String = "Focus on unique offering and local marketing strategies to stand out from competitors."

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

                    // Action Button
                    Button(action: {
                        navigateToRoadmap = true
                    }) {
                        HStack(spacing: 8) {
                            Text("Generate Roadmap")
                                .font(.system(size: 16, weight: .semibold))

                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .buttonStyle(PrimaryAppButtonStyle())
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color("Background").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        // ربط الضغطة بالانتقال إلى RoadmapView
        .navigationDestination(isPresented: $navigateToRoadmap) {
            RoadmapView(onFinishCreation: onFinishCreation)
        }
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

            Text("\(score)")
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
        IdeaEvaluationView()
    }
}
