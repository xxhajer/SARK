import SwiftUI
import UIKit

struct RoadmapDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    let businessID: UUID
    @Binding var stages: [RoadmapStage]

    // CHANGE: كانت currentIndex عبارة عن Binding<Int> توصل من RoadmapView
    // كـ ".constant(index)" — وهذا نوع Binding "ثابت" ما يقدر يتغيّر أبدًا،
    // فلما زر "Proceed to Next Stage" يحاول يزيدها (currentIndex += 1)،
    // التغيير ما يوصل لأي مكان ولا تعيد الشاشة رسم نفسها بالمرحلة الجاية —
    // عشان كذا الزر كان "يضغط بس ما يودي". الحين currentIndex قيمة حالة
    // (@State) حقيقية جوه هذي الشاشة نفسها، تقدر تتغيّر فعليًا.
    @State private var currentIndex: Int

    @State private var isDescriptionExpanded: Bool = true
    @State private var isObjectivesExpanded: Bool = true
    @State private var isResourcesExpanded: Bool = false
    @State private var copiedResource: String? = nil

    init(businessID: UUID, stages: Binding<[RoadmapStage]>, startIndex: Int) {
        self.businessID = businessID
        self._stages = stages
        self._currentIndex = State(initialValue: startIndex)
    }

    // MARK: - Computed Properties
    private var currentStage: RoadmapStage {
        guard stages.indices.contains(currentIndex) else {
            return RoadmapStage(
                id: UUID(),
                title: "",
                subtitle: "",
                progressPercentage: 0,
                state: .upcoming,
                monthLabel: "",
                iconName: "",
                description: "",
                priorityReason: "",
                objectives: [],
                resources: []
            )
        }
        return stages[currentIndex]
    }

    private var calculatedPercentage: Int {
        guard !currentStage.objectives.isEmpty else { return currentStage.progressPercentage }
        let completedCount = currentStage.objectives.filter { $0.isCompleted }.count
        return Int((Double(completedCount) / Double(currentStage.objectives.count)) * 100)
    }

    private var areAllObjectivesCompleted: Bool {
        guard !currentStage.objectives.isEmpty else { return true }
        return currentStage.objectives.allSatisfy { $0.isCompleted }
    }

    // MARK: - Helper Methods
    private func syncStageProgressFromObjectives() {
        guard stages.indices.contains(currentIndex), !currentStage.objectives.isEmpty else { return }

        let completedCount = currentStage.objectives.filter { $0.isCompleted }.count
        let percentage = Int((Double(completedCount) / Double(currentStage.objectives.count)) * 100)

        stages[currentIndex].progressPercentage = percentage

        if percentage == 100 {
            stages[currentIndex].state = .completed
            stages[currentIndex].subtitle = "completed"
        } else if percentage > 0 {
            stages[currentIndex].state = .inProgress
            stages[currentIndex].subtitle = "In progress - \(percentage)%"
        } else {
            stages[currentIndex].state = .upcoming
            stages[currentIndex].subtitle = "Upcoming"
        }
    }

    private func completeAndProceed() {
        withAnimation(.easeInOut) {
            guard stages.indices.contains(currentIndex) else { return }

            // 1. Mark all objectives in current stage as completed
            for i in 0..<stages[currentIndex].objectives.count {
                stages[currentIndex].objectives[i].isCompleted = true
            }
            
            // 2. Mark current stage as completed
            stages[currentIndex].progressPercentage = 100
            stages[currentIndex].state = .completed
            stages[currentIndex].subtitle = "completed"

            // 3. Sync state back to BusinessStore
            if let idx = BusinessStore.shared.index(of: businessID) {
                BusinessStore.shared.businesses[idx].roadmapStages = stages
            }

            // 4. Move to next stage or dismiss if final stage
            if currentIndex < stages.count - 1 {
                currentIndex += 1
                if stages[currentIndex].state == .upcoming {
                    stages[currentIndex].state = .inProgress
                    stages[currentIndex].subtitle = "In progress - 0%"
                    if let idx = BusinessStore.shared.index(of: businessID) {
                        BusinessStore.shared.businesses[idx].roadmapStages = stages
                    }
                }
            } else {
                dismiss()
            }
        }
    }

    var body: some View {
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

                    // MARK: - Action Button
                    actionButton

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Action Button View
    private var actionButton: some View {
        Button(action: completeAndProceed) {
            HStack(spacing: 8) {
                Text(currentIndex < stages.count - 1 ? "Proceed to Next Stage" : "Finish Stage")
                    .font(.system(size: 18, weight: .bold))
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color("appGreen"))
            .cornerRadius(28)
        }
        // Subtle blur and light opacity drop when locked
        .blur(radius: areAllObjectivesCompleted ? 0 : 1)
        .opacity(areAllObjectivesCompleted ? 1.0 : 0.7)
        .disabled(!areAllObjectivesCompleted)
        .animation(.easeInOut(duration: 0.25), value: areAllObjectivesCompleted)
        .padding(.top, 8)
    }

    // MARK: - Header
    private var headerSegmentSection: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("priemary text"))
            }

            VStack(alignment: .leading, spacing: 2) {
                if !currentStage.monthLabel.isEmpty {
                    Text(currentStage.monthLabel.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color("appOrange"))
                        .tracking(0.6)
                }
                Text(currentStage.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("priemary text"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

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
                    .foregroundColor(Color("priemary text"))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(calculatedPercentage)% complete")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("priemary text"))
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
                        .foregroundColor(Color("priemary text"))

                    Text("Description")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("priemary text"))

                    Spacer()

                    Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("priemary text"))
                }
            }

            if isDescriptionExpanded {
                Divider()

                Text(currentStage.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color("long texts"))
                    .lineSpacing(4)

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "link")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("priemary text"))
                        .padding(.top, 1)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prioritized based on:")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("long texts"))

                        Text(currentStage.priorityReason)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color("appOrange"))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
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
                        .foregroundColor(Color("priemary text"))

                    Text("Objectives")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("priemary text"))

                    Spacer()

                    Image(systemName: isObjectivesExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("priemary text"))
                }
            }

            if isObjectivesExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(stages[currentIndex].objectives.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring()) {
                                stages[currentIndex].objectives[index].isCompleted.toggle()
                                syncStageProgressFromObjectives()
                                if stages[currentIndex].objectives[index].isCompleted {
                                    StreakManager.shared.recordTaskCompletion()
                                }
                            }
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: stages[currentIndex].objectives[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(stages[currentIndex].objectives[index].isCompleted ? Color("appGreen") : Color("faded text"))

                                Text(stages[currentIndex].objectives[index].title)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color("priemary text"))
                                    .strikethrough(stages[currentIndex].objectives[index].isCompleted, color: Color("faded text"))
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        if index < stages[currentIndex].objectives.count - 1 {
                            Divider().padding(.leading, 34)
                        }
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
                        .foregroundColor(Color("priemary text"))

                    Text("Resources")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("priemary text"))

                    Spacer()

                    Image(systemName: isResourcesExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("priemary text"))
                }
            }

            if isResourcesExpanded {
                Divider()

                if currentStage.resources.isEmpty {
                    Text("No resources yet for this stage.")
                        .font(.system(size: 13))
                        .foregroundColor(Color("faded text"))
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(currentStage.resources, id: \.self) { resource in
                            Button(action: {
                                UIPasteboard.general.string = resource
                                withAnimation { copiedResource = resource }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    if copiedResource == resource {
                                        withAnimation { copiedResource = nil }
                                    }
                                }
                            }) {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: copiedResource == resource ? "checkmark.circle.fill" : "link.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color("appGreen"))

                                    Text(resource)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("long texts"))
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer(minLength: 0)

                                    if copiedResource == resource {
                                        Text("Copied")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(Color("appGreen"))
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(copiedResource == resource ? Color("appGreen").opacity(0.1) : Color.clear)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }
}
