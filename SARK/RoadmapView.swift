import SwiftUI

// MARK: - Main Roadmap View
struct RoadmapView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID
    var onFinishCreation: ((UUID) -> Void)? = nil

    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showCompletionSheet = false

    // MARK: - Store access
    private var businessIndex: Int? { store.index(of: businessID) }
    private var business: Business? {
        guard let idx = businessIndex else { return nil }
        return store.businesses[idx]
    }
    private var stages: [RoadmapStage] {
        business?.roadmapStages ?? []
    }

    private var stagesBinding: Binding<[RoadmapStage]> {
        Binding<[RoadmapStage]>(
            get: {
                guard let idx = self.businessIndex,
                      let stages = self.store.businesses[idx].roadmapStages else { return [] }
                return stages
            },
            set: { newValue in
                guard let idx = self.businessIndex else { return }
                self.store.businesses[idx].roadmapStages = newValue
                self.checkIfAllCompleted()
            }
        )
    }

    // MARK: - Computed values

    private var totalStages: Int {
        stages.count
    }

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

    private var currentStageDisplayNumber: Int {
        currentStageIndex + 1
    }

    private var overallPercentage: Int {
        guard totalStages > 0 else { return 0 }
        let sum = stages.reduce(0) { $0 + $1.progressPercentage }
        return Int(Double(sum) / Double(totalStages))
    }

    private var completedStagesCount: Int {
        stages.filter { $0.state == .completed }.count
    }
    
    private var isAllCompleted: Bool {
        !stages.isEmpty && stages.allSatisfy { $0.state == .completed }
    }

    private func checkIfAllCompleted() {
        if isAllCompleted {
            showCompletionSheet = true
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if let errorMessage {
                errorView(message: errorMessage)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerBar
                        topProgressBarSection
                        circularGaugeSection
                        timelineSection

                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadRoadmapIfNeeded()
            normalizeStageProgression()
            checkIfAllCompleted()
        }
        .sheet(isPresented: $showCompletionSheet) {
            RoadmapCompletionSheet(onDismiss: {
                showCompletionSheet = false
                
                // Return to Project Dashboard
                if let onFinishCreation {
                    onFinishCreation(businessID)
                } else {
                    dismiss()
                }
            })
            .presentationDetents([.height(520)])
            .presentationCornerRadius(32)
        }
    }

    private func normalizeStageProgression() {
        guard let idx = businessIndex,
              var currentStages = store.businesses[idx].roadmapStages,
              !currentStages.isEmpty else { return }

        var changed = false
        for i in 0..<(currentStages.count - 1) {
            if currentStages[i].state == .completed && currentStages[i + 1].state == .upcoming {
                currentStages[i + 1].state = .inProgress
                currentStages[i + 1].subtitle = "In progress - 0%"
                changed = true
            }
        }

        if changed {
            store.businesses[idx].roadmapStages = currentStages
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Building your roadmap...")
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(Color("appOrange"))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color("faded text"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button(action: {
                Task { await loadRoadmapIfNeeded(forceReload: true) }
            }) {
                Text("Try Again")
            }
            .buttonStyle(PrimaryAppButtonStyle())
            .frame(maxWidth: 200)
            Spacer()
        }
    }

    private func loadRoadmapIfNeeded(forceReload: Bool = false) async {
        guard let idx = businessIndex else { return }
        let alreadyGenerated = store.businesses[idx].roadmapStages?.isEmpty == false
        guard forceReload || !alreadyGenerated else { return }

        isLoading = true
        errorMessage = nil
        do {
            let generatedStages = try await GeminiService.generateRoadmap(
                ideaText: store.businesses[idx].ideaText,
                industry: store.businesses[idx].industry,
                location: store.businesses[idx].location,
                timeline: store.businesses[idx].timeline,
                goal: store.businesses[idx].goal
            )
            store.businesses[idx].roadmapStages = generatedStages
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = GeminiServiceError.userFacingMessage(for: error, action: "build your roadmap")
        }
    }

    // MARK: Header Bar
    private var headerBar: some View {
        HStack(spacing: 16) {
            Button(action: {
                if let onFinishCreation {
                    onFinishCreation(businessID)
                } else {
                    dismiss()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("priemary texts"))
            }

            Text(business?.name ?? "Roadmap")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("priemary texts"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()
        }
    }

    // MARK: Top Progress Bar Section
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
    private var circularGaugeSection: some View {
        let percentage = currentStage?.progressPercentage ?? 0
        let trimEnd = 0.1 + (0.75 * Double(percentage) / 100.0)

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
                Text(currentStage?.monthLabel.isEmpty == false ? currentStage!.monthLabel.uppercased() : "STAGE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("faded text"))
                    .tracking(1.2)
                    .lineLimit(1)

                Text(currentStage?.title ?? "—")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("priemary texts"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(width: 130)

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
            ForEach(Array(stages.indices.enumerated()), id: \.element) { (index: Int, _) in
                if index == currentStageIndex + 1, stages[index].state == .upcoming {
                    Text("Up next")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("faded text"))
                        .padding(.top, 6)
                }

                NavigationLink(
                    destination: RoadmapDetailsView(
                        businessID: businessID,
                        stages: stagesBinding,
                        currentIndex: .constant(index)
                    )
                ) {
                    TimelineStepView(
                        title: stages[index].title,
                        subtitle: stages[index].subtitle,
                        monthLabel: stages[index].monthLabel,
                        state: stages[index].state,
                        iconName: stages[index].iconName
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Completion Sheet View
struct RoadmapCompletionSheet: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color("appGreen").opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 54))
                    .foregroundColor(Color("appGreen"))
            }

            VStack(spacing: 12) {
                Text("Congratulations! 🎉")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color("priemary texts"))

                Text("You've completed all stages in your business roadmap. Your project is ready for launch!")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color("faded text"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Spacer()

            Button(action: onDismiss) {
                Text("Go to Dashboard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("appOrange"))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(.top, 10)
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
            return Color("appGreen")
        } else if index == currentStage {
            return Color("appOrange")
        } else {
            return Color("faded text").opacity(0.3)
        }
    }
}

enum TimelineStepState: String, Codable {
    case completed
    case inProgress
    case upcoming
}

struct TimelineStepView: View {
    let title: String
    let subtitle: String
    var monthLabel: String = ""
    let state: TimelineStepState
    let iconName: String

    var body: some View {
        HStack(spacing: 16) {
            leftStatusIcon

            VStack(alignment: .leading, spacing: 3) {
                if !monthLabel.isEmpty {
                    Text(monthLabel.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(subtitleColor.opacity(0.8))
                        .tracking(0.6)
                }

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
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 32, height: 32)
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
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
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
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
            return .white
        case .inProgress:
            return Color("appOrange")
        case .upcoming:
            return Color("faded text")
        }
    }

    private var subtitleColor: Color {
        switch state {
        case .completed:
            return .white.opacity(0.85)
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

// MARK: - Xcode Canvas Previews
struct RoadmapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RoadmapView(businessID: UUID())
        }
    }
}
