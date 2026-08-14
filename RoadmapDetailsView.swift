//
//  RoadmapDetailsView.swift
//  SARK
//
//  Created by Hadeel Yahya Awaji on 24/02/1448 AH.
//

import SwiftUI

struct RoadmapDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    // Binding to the stage living in RoadmapView's `stages` array.
    // Any change made here (objectives, progress, subtitle, state)
    // writes straight back into that array.
    @Binding var currentStage: RoadmapStage

    // Local UI State
    @State private var isDescriptionExpanded: Bool = true
    @State private var isObjectivesExpanded: Bool = true
    @State private var isResourcesExpanded: Bool = false

    init(stage: Binding<RoadmapStage>) {
        _currentStage = stage
    }

    // Computed property to calculate current percentage dynamically
    // from objectives — used for the live progress bar/text on this screen.
    private var calculatedPercentage: Int {
        guard !currentStage.objectives.isEmpty else { return currentStage.progressPercentage }
        let completedCount = currentStage.objectives.filter { $0.isCompleted }.count
        return Int((Double(completedCount) / Double(currentStage.objectives.count)) * 100)
    }

    // CHANGE: This is the actual fix. Whenever an objective is toggled,
    // this recalculates the percentage AND writes it — plus a matching
    // subtitle and state — back onto `currentStage` itself. Because
    // `currentStage` is a Binding into RoadmapView's `stages` array,
    // this update is visible immediately on the timeline (progress bar,
    // circular gauge, stage card subtitle) as soon as you navigate back.
    private func syncStageProgressFromObjectives() {
        guard !currentStage.objectives.isEmpty else { return }

        let completedCount = currentStage.objectives.filter { $0.isCompleted }.count
        let percentage = Int((Double(completedCount) / Double(currentStage.objectives.count)) * 100)

        currentStage.progressPercentage = percentage

        if percentage == 100 {
            currentStage.state = .completed
            currentStage.subtitle = "completed"
        } else if percentage > 0 {
            currentStage.state = .inProgress
            currentStage.subtitle = "In progress - \(percentage)%"
        } else {
            currentStage.state = .upcoming
            currentStage.subtitle = "Upcoming"
        }
    }

    var body: some View {
        // CHANGE: removed the local ZStack + BottomNavBarView.
        // CustomTabBar is rendered once, globally, by MainTabView —
        // this screen just scrolls its content underneath it.
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    headerSegmentSection
                    progressCard
                    descriptionCard
                    objectivesCard
                    resourcesCard

                    // Keeps content clear of the floating CustomTabBar
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header
    // Was: back arrow + title + a "Timeline / Details" segment control.
    // The "Timeline" button just called dismiss() — same thing the back
    // arrow already does — so it was a redundant second way to go back.
    // Removed it; back arrow is now the only way back to the timeline.
    private var headerSegmentSection: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("priemary texts"))
            }

            Text(currentStage.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("priemary texts"))

            Spacer()
        }
    }

    // MARK: - Dynamic Progress Card
    private var progressCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.04))
                    .frame(width: 48, height: 48)
                Image(systemName: currentStage.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("priemary texts"))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(calculatedPercentage)% complete")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("priemary texts"))
                    .animation(.default, value: calculatedPercentage)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black.opacity(0.08))
                            .frame(height: 8)

                        Capsule()
                            .fill(Color("appOrange"))
                            .frame(width: geo.size.width * CGFloat(calculatedPercentage) / 100.0, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: calculatedPercentage)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }

    // MARK: - Description Card
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: { isDescriptionExpanded.toggle() }) {
                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(Color("priemary texts"))

                    Text("Description")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("priemary texts"))

                    Spacer()

                    Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("priemary texts"))
                }
            }

            if isDescriptionExpanded {
                Divider()

                Text(currentStage.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color("long texts"))
                    .lineSpacing(4)

                HStack(spacing: 10) {
                    Image(systemName: "link")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("priemary texts"))

                    HStack(spacing: 4) {
                        Text("Prioritized based on:")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("long texts"))

                        Text(currentStage.priorityReason)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color("appOrange"))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color("boxes"))
                        .overlay(
                            Rectangle()
                                .fill(Color("appOrange"))
                                .frame(width: 4),
                            alignment: .leading
                        )
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }

    // MARK: - Interactive Objectives Card
    private var objectivesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: { isObjectivesExpanded.toggle() }) {
                HStack {
                    Image(systemName: "target")
                        .font(.system(size: 18))
                        .foregroundColor(Color("priemary texts"))

                    Text("Objectives")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("priemary texts"))

                    Spacer()

                    Image(systemName: isObjectivesExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("priemary texts"))
                }
            }

            if isObjectivesExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(currentStage.objectives.indices, id: \.self) { index in
                        Button(action: {
                            // CHANGE: toggle the objective AND immediately
                            // resync progress/subtitle/state on the stage.
                            withAnimation(.spring()) {
                                currentStage.objectives[index].isCompleted.toggle()
                                syncStageProgressFromObjectives()
                            }
                        }) {
                                    HStack(spacing: 12) {
                                                        Image(systemName: currentStage.objectives[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                                            .font(.system(size: 22))
                                                            .foregroundColor(currentStage.objectives[index].isCompleted ? Color("appGreen") : Color("faded text"))

                                                        Text(currentStage.objectives[index].title)
                                                            .font(.system(size: 15, weight: .medium))
                                                            .foregroundColor(Color("priemary texts"))
                                                            .strikethrough(currentStage.objectives[index].isCompleted, color: Color("faded text"))

                                                        Spacer()
                                                    }
                                                    .contentShape(Rectangle())   // ← NEW LINE
                                                }
                                                .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }

    // MARK: - Resources Card
    private var resourcesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: { isResourcesExpanded.toggle() }) {
                HStack {
                    Image(systemName: "paperclip")
                        .font(.system(size: 18))
                        .foregroundColor(Color("priemary texts"))

                    Text("Resources")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("priemary texts"))

                    Spacer()

                    Image(systemName: isResourcesExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("priemary texts"))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }
}

// MARK: - Canvas Preview
// Wrapped in a NavigationStack so the back arrow's dismiss() actually
// has something to pop — without this wrapper, dismiss() silently does
// nothing because there's no navigation stack in an isolated preview.
#Preview {
    NavigationStack {
        RoadmapDetailsView(
            stage: .constant(
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
                )
            )
        )
    }
}
