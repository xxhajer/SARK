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
        ZStack(alignment: .bottom){
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .center, spacing: 0) {

                    HStack(spacing: 35) {

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 25, weight: .semibold))
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
                    .padding(.top, 10)
                    .padding(.bottom, 30)

                    VStack(alignment: .leading, spacing: 20) {
                        HStack {

                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.greeen)
                                .frame(width: 55, height: 65)
                                .overlay(
                                    Image("document")
                                        .foregroundColor(.white)
                                        .font(.system(size:0))
                                )

                            // CHANGE: ما نقص النص بثلاث نقاط تلقائية بعد الآن
                            // (كانت توهم إن فيه كلام ناقص بدون ما توضح وينه) —
                            // الحين النص يبين كامل لو يناسب، ولو طويل فعلاً
                            // يطلع زر "More" صريح يفتحه كامل.
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Stage")
                                    .foregroundColor(.fadedText)
                                    .font(.system(size: 16, weight: .medium))
                                ExpandableText(
                                    text: business?.stageLabel ?? "Getting Started",
                                    collapsedLimit: 40,
                                    font: .system(size: 18, weight: .bold),
                                    color: .black
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // CHANGE: كانت تتقطع بثلاث نقاط لما جنبها "Current
                            // Stage" ياخذ أغلب المساحة. الحين تصغر الخط تلقائيًا
                            // بدل ما تنقص — نفس مبدأ "صغر الخط عادي بس لا تقص".
                            VStack(alignment: .trailing, spacing: 15) {
                                Text("Overall Progress")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                Text("\(progressPercent)%")
                                    .foregroundColor(.black)
                                    .font(.system(size: 35, weight: .bold))
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
                        .frame(height: 1)
                    }
                    .padding(25)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                    )
                    .frame(width: 380)
                    .padding(.bottom, 25)

                    HStack(alignment: .top, spacing: 20) {
                        Image("goal")

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today's Goal")
                                .foregroundColor(.insideTheGreen)
                                .font(.system(size: 18, weight: .medium))
                            ExpandableText(
                                text: todaysGoalTitle,
                                collapsedLimit: 70,
                                font: .system(size: 17, weight: .bold),
                                color: Color("inside the green"),
                                linkColor: .white
                            )
                        }

                        Spacer()
                    }
                    .padding(25)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                        .fill(Color.greeen)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )
                    .frame(width: 380)
                    .padding(.bottom, 30)

                    HStack(alignment: .top, spacing: 5) {

                        VStack(alignment: .leading, spacing: 13) {
                            Text("Next Milestone")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)

                            ExpandableText(
                                text: nextMilestoneTitle,
                                collapsedLimit: 45,
                                font: .system(size: 16, weight: .bold),
                                color: .black
                            )

                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.fadedText)
                                    .font(.system(size: 22))
                                Text(business?.timeline.isEmpty == false ? business!.timeline : "—")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundColor(.fadedText)
                                    .lineLimit(1)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        )
                        .frame(width: 200)

                        VStack(spacing: 10) {
                            Text("Business Health")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            Image("smileFace")
                            Text("Good")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .frame(width: 150, height: 160)
                        )
                    }
                    .padding(.bottom, 25)
                    VStack(spacing:10){
                        Text("Quick Actions")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading,15)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)

                        HStack(spacing: 12) {
                            HStack(spacing: 0) {

                                NavigationLink(destination: IdeaEvaluationView(businessID: businessID)) {
                                    VStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.white)
                                            .frame(width: 120, height: 90)
                                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                            .overlay(
                                                Image("ideaEva")
                                            )
                                        Text("Idea Evaluation")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PlainButtonStyle())

                                NavigationLink(destination: BudgetOverviewView(businessID: businessID)) {
                                    VStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.white)
                                            .frame(width: 120, height: 90)
                                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                            .overlay(
                                                Image("Wallet")
                                            )
                                        Text("Budget")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PlainButtonStyle())


                                NavigationLink(destination: RoadmapView(businessID: businessID)) {
                                    VStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.white)
                                            .frame(width: 120, height: 90)
                                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                            .overlay(
                                                Image("Roadmap")
                                            )
                                        Text("Roadmap")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        Rectangle()
                            .fill(Color.insideTheGreen)
                            .frame(height: 1)
                            .padding(.horizontal, 15)
                            .padding(.top, 10)
                            .shadow(color: Color.insideTheGreen, radius: 8, x: 0, y: 8)
                    }
                }
                .padding(.bottom, 100)
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
