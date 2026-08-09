//
//  RoadmapView.swift
//  SARK
//
//  Created by Hadeel Yahya Awaji on 24/02/1448 AH.
//

import SwiftUI

// MARK: - Main Roadmap View
struct RoadmapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: BottomTab = .projects

    // Real stage data — everything below (progress bar, circular gauge,
    // "Stage X of Y", "X% overall") is now CALCULATED from this array
    // instead of being typed in by hand. Add/remove/edit a stage here
    // (or later from your data layer / ViewModel) and the whole screen
    // updates on its own.
    @State private var stages: [RoadmapStage] = [
        RoadmapStage(
            title: "Validate Idea",
            subtitle: "completed",
            progressPercentage: 100,
            state: .completed,
            iconName: "lightbulb.fill",
            description: "Confirm there's real demand for your idea before investing further time and resources.",
            priorityReason: "Foundation for all other stages",
            objectives: [
                StageObjective(title: "Interview potential customers", isCompleted: true),
                StageObjective(title: "Define value proposition", isCompleted: true)
            ],
            resources: []
        ),
        RoadmapStage(
            title: "Market Research",
            subtitle: "In progress - 60%",
            progressPercentage: 60,
            state: .inProgress,
            iconName: "magnifyingglass",
            description: "Understand your target market, study competitors, and gather insights to build a strong foundation.",
            priorityReason: "High initial competition",
            objectives: [
                StageObjective(title: "Validate market demand.", isCompleted: true),
                StageObjective(title: "Analyze competitors", isCompleted: true),
                StageObjective(title: "Identify primary user persona", isCompleted: false)
            ],
            resources: []
        ),
        RoadmapStage(
            title: "Pricing Strategy",
            subtitle: "Upcoming",
            progressPercentage: 0,
            state: .upcoming,
            iconName: "wallet.pass",
            description: "Decide how you'll price your product or service based on cost, value, and market positioning.",
            priorityReason: "Depends on market research results",
            objectives: [],
            resources: []
        ),
        RoadmapStage(
            title: "Supplier Selection",
            subtitle: "+ 4 more stages",
            progressPercentage: 0,
            state: .upcoming,
            iconName: "archivebox",
            description: "Identify and vet reliable suppliers for your product or ingredients.",
            priorityReason: "Needed before launch",
            objectives: [],
            resources: []
        )
    ]

    // MARK: - Computed values (derived from `stages`, never hardcoded)

    private var totalStages: Int {
        stages.count
    }

    // The "current" stage = first one still in progress.
    // If none are in progress (e.g. all completed, or all upcoming),
    // fall back to the first upcoming one, or the last stage.
    private var currentStageIndex: Int {
        if let inProgressIndex = stages.firstIndex(where: { $0.state == .inProgress }) {
            return inProgressIndex
        }
        if let upcomingIndex = stages.firstIndex(where: { $0.state == .upcoming }) {
            return upcomingIndex
        }
        return max(stages.count - 1, 0)
    }

    private var currentStage: RoadmapStage? {
        guard stages.indices.contains(currentStageIndex) else { return nil }
        return stages[currentStageIndex]
    }

    // "Stage X of Y" — X is 1-based for display
    private var currentStageDisplayNumber: Int {
        currentStageIndex + 1
    }

    // Overall progress = average completion across all stages
    private var overallPercentage: Int {
        guard totalStages > 0 else { return 0 }
        let sum = stages.reduce(0) { $0 + $1.progressPercentage }
        return Int(Double(sum) / Double(totalStages))
    }

    // How many segments in the top bar should read as "done" vs "current" vs "upcoming"
    private var completedStagesCount: Int {
        stages.filter { $0.state == .completed }.count
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Top Navigation Bar
                    headerBar

                    // Top Segmented Progress Bar & Stage Indicator
                    topProgressBarSection

                    // Circular Progress Gauge Card
                    circularGaugeSection

                    // Timeline Stages List
                    timelineSection

                    // Spacer for bottom tab bar clearing
                    Spacer(minLength: 90)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            // Shared Component: Bottom Navigation Bar
            BottomNavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }

    // MARK: Header Bar
    private var headerBar: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("priemary texts"))
            }

            Text("Lena's coffee shop")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("priemary texts"))

            Spacer()
        }
    }

    // MARK: Top Progress Bar Section
    // Was: ProgressBarView(totalStages: 6, currentStage: 2) + hardcoded "2 of 7" / "28%"
    // Now: everything pulled from `stages`.
    private var topProgressBarSection: some View {
        VStack(spacing: 10) {
            ProgressBarView(totalStages: totalStages, currentStage: completedStagesCount)

            HStack {
                HStack(spacing: 4) {
                    Text("Stage")
                        .foregroundColor(Color("faded text"))
                    Text("\(currentStageDisplayNumber)")
                        .foregroundColor(Color("appOrange"))
                        .bold()
                    Text("of")
                        .foregroundColor(Color("faded text"))
                    Text("\(totalStages)")
                        .foregroundColor(Color("priemary texts"))
                        .bold()
                }
                .font(.system(size: 15, weight: .semibold))

                Spacer()

                Text("\(overallPercentage)% overall")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("appOrange"))
            }
        }
    }

    // MARK: Circular Gauge Section
    // Was: hardcoded "Market Research" / "60%" text.
    // Now: reflects whichever stage is actually in progress.
    private var circularGaugeSection: some View {
        let percentage = currentStage?.progressPercentage ?? 0
        let trimEnd = 0.1 + (0.75 * Double(percentage) / 100.0) // maps 0-100% onto the 0.1...0.85 arc

        return ZStack {
            Circle()
                .trim(from: 0.1, to: 0.85)
                .stroke(
                    Color("faded text").opacity(0.35),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
                .frame(width: 180, height: 180)

            Circle()
                .trim(from: 0.1, to: trimEnd)
                .stroke(
                    Color("appOrange"),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
                .frame(width: 180, height: 180)
                .animation(.easeInOut(duration: 0.3), value: percentage)

            VStack(spacing: 2) {
                Text("STAGE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("faded text"))
                    .tracking(1.2)

                Text(currentStage?.title ?? "—")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("priemary texts"))

                Text("\(percentage)%")
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundColor(Color("appOrange"))
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: Timeline Steps Section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(stages.indices, id: \.self) { index in
                // "Up next" header shown right before the first upcoming stage
                if index == currentStageIndex + 1, stages[index].state == .upcoming {
                    Text("Up next")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("faded text"))
                        .padding(.top, 6)
                }

                NavigationLink(value: stages[index]) {
                    TimelineStepView(
                        title: stages[index].title,
                        subtitle: stages[index].subtitle,
                        state: stages[index].state,
                        iconName: stages[index].iconName
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationDestination(for: RoadmapStage.self) { stage in
            if let bindingIndex = stages.firstIndex(where: { $0.id == stage.id }) {
                RoadmapDetailsView(stage: $stages[bindingIndex])
            }
        }
    }
}



// MARK: - Core Reusable Shared Components

struct ProgressBarView: View {
    let totalStages: Int
    let currentStage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalStages, id: \.self) { index in
                Capsule()
                    .fill(segmentColor(for: index))
                    .frame(height: 8)
            }
        }
    }

    private func segmentColor(for index: Int) -> Color {
        if index < currentStage {
            return Color("appGreen")       // completed segments
        } else if index == currentStage {
            return Color("appOrange")      // current segment
        } else {
            return Color("faded text").opacity(0.3) // upcoming segments
        }
    }
}

enum TimelineStepState {
    case completed
    case inProgress
    case upcoming
}

struct TimelineStepView: View {
    let title: String
    let subtitle: String
    let state: TimelineStepState
    let iconName: String

    var body: some View {
        HStack(spacing: 16) {
            leftStatusIcon

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(textColor)

                Text(subtitle)
                    .font(.system(size: 14, weight: state == .inProgress ? .semibold : .medium))
                    .foregroundColor(subtitleColor)
            }

            Spacer()

            rightFeatureIcon
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(cardBackground)
        .cornerRadius(20)
        .shadow(
            color: state == .upcoming ? Color.black.opacity(0.02) : Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    @ViewBuilder
    private var leftStatusIcon: some View {
        switch state {
        case .completed:
            ZStack {
                Circle()
                    .fill(Color("inside the green"))
                    .frame(width: 32, height: 32)
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("appGreen"))
            }
        case .inProgress:
            Circle()
                .fill(Color("appOrange"))
                .frame(width: 16, height: 16)
                .padding(8)
        case .upcoming:
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.05))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(Color("faded text"))
            }
        }
    }

    @ViewBuilder
    private var rightFeatureIcon: some View {
        if state == .completed {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("inside the green"))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(Color("appGreen"))
            }
        } else if state == .inProgress {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("appOrange").opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("appOrange"))
            }
        }
    }

    private var textColor: Color {
        switch state {
        case .completed:
            return Color("inside the green")
        case .inProgress:
            return Color("appOrange")
        case .upcoming:
            return Color("faded text")
        }
    }

    private var subtitleColor: Color {
        switch state {
        case .completed:
            return Color("inside the green").opacity(0.85)
        case .inProgress:
            return Color("appOrange")
        case .upcoming:
            return Color("faded text").opacity(0.8)
        }
    }

    private var cardBackground: Color {
        switch state {
        case .completed:
            return Color("appGreen")
        case .inProgress, .upcoming:
            return .white
        }
    }
}

enum BottomTab {
    case home
    case projects
    case profile
}

struct BottomNavBarView: View {
    @Binding var selectedTab: BottomTab

    var body: some View {
        HStack {
            Spacer()

            buttonItem(title: "Home", icon: "house", tab: .home)
            Spacer()

            buttonItem(title: "Projects", icon: "folder", tab: .projects)
            Spacer()

            buttonItem(title: "Profile", icon: "person", tab: .profile)
            Spacer()
        }
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 6)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private func buttonItem(title: String, icon: String, tab: BottomTab) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                Text(title)
                    .font(.system(size: 11, weight: selectedTab == tab ? .bold : .medium))
            }
            .foregroundColor(selectedTab == tab ? Color("appGreen") : Color("priemary texts"))
        }
    }
}

// MARK: - Xcode Canvas Previews
struct RoadmapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RoadmapView()
        }
    }
}
