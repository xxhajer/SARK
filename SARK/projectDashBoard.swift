import SwiftUI

struct projectDashBoard: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID

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
                VStack(spacing: 20) {

                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.black)
                        }

                        Text(business?.name ?? "My Business")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)

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
                                Text("Current Stage")
                                    .foregroundColor(.fadedText)
                                    .font(.system(size: 13, weight: .medium))
                                ExpandableText(
                                    text: business?.stageLabel ?? "Getting Started",
                                    collapsedLimit: 40,
                                    font: .system(size: 15, weight: .bold),
                                    color: .black
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .trailing, spacing: 6) {
                                Text("Overall Progress")
                                    .foregroundColor(.black)
                                    .font(.system(size: 13, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                Text("\(progressPercent)%")
                                    .foregroundColor(.black)
                                    .font(.system(size: 26, weight: .bold))
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
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )

                    // Card 2: Today's Goal
                    HStack(alignment: .top, spacing: 16) {
                        Image("goal")

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Goal")
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
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.greeen)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )

                    // Row: Next Milestone & Business Health
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Next Milestone")
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
                                    .font(.system(size: 14))
                                Text(business?.timeline.isEmpty == false ? business!.timeline : "—")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.fadedText)
                                    .lineLimit(1)
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .frame(height: 145)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        )

                        // Business Health Box
                        VStack(spacing: 12) {
                            Text("Business Health")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Image("smileFace")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)

                            Text("Good")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(width: 130, height: 145)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        )
                    }
                    .frame(maxWidth: .infinity)

                    // Quick Actions Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Quick Actions")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)

                        HStack(spacing: 12) {
                            NavigationLink(destination: IdeaEvaluationView(businessID: businessID)) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white)
                                        .frame(height: 88)
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                        .overlay(
                                            Image("ideaEva")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 36, height: 36)
                                        )
                                    Text("Idea Evaluation")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())

                            NavigationLink(destination: BudgetOverviewView(businessID: businessID)) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white)
                                        .frame(height: 88)
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                        .overlay(
                                            Image("Wallet")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 36, height: 36)
                                        )
                                    Text("Budget")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())

                            NavigationLink(destination: RoadmapView(businessID: businessID)) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white)
                                        .frame(height: 88)
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                        .overlay(
                                            Image("Roadmap")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 36, height: 36)
                                        )
                                    Text("Roadmap")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Rectangle()
                            .fill(Color.insideTheGreen)
                            .frame(height: 1)
                            .padding(.top, 6)
                            .shadow(color: Color.insideTheGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        projectDashBoard(businessID: UUID())
    }
}
