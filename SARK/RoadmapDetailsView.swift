//
//  Untitled.swift
//  SARK
//
//  Created by hajer almejel on 27/02/1448 AH.
//

//
//  RoadmapDetailsView.swift
//  SARK
//
//  Created by Hadeel Yahya Awaji on 24/02/1448 AH.
//

import SwiftUI
import UIKit

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
    // CHANGE: تتبع أي ريسورس انضغط عليه آخر مرة، عشان نعطي فيدباك واضح إنه
    // فعليًا استجاب للمس (كانت مجرد نص ثابت بدون أي تفاعل).
    @State private var copiedResource: String? = nil

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

            VStack(alignment: .leading, spacing: 2) {
                if !currentStage.monthLabel.isEmpty {
                    Text(currentStage.monthLabel.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color("appOrange"))
                        .tracking(0.6)
                }
                // CHANGE: عنوان المرحلة بالعربي أطول من الإنجليزي — نحده
                // بسطرين بحد أقصى بدل ما يطول بزيادة ويكسر الهيدر.
                Text(currentStage.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("priemary texts"))
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

                // CHANGE: كانت العلامة والنص جنب بعض بسطر واحد (HStack)، وهذا
                // كان يتكسر بشكل عشوائي لما السبب (priorityReason) يطلع جملة
                // طويلة بالعربي. الحين العلامة بسطر لحالها والسبب تحته، وله
                // مساحة كاملة يلف فيها بشكل مرتب.
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "link")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("priemary texts"))
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

                // CHANGE: العناصر بالعربي أطول وتلف لسطرين-ثلاثة، وكانت
                // الأيقونة تتوسط رأسي مع النص (HStack افتراضي .center) مما
                // يخليها تطلع بمكان عشوائي وسط الكلام. الحين الأيقونة تثبت
                // بأعلى النص دايمًا (alignment: .top)، وزودنا المسافة بين
                // كل عنصر وبين أسطر النص نفسه عشان يصير مرتب وواضح مو مزحوم.
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(currentStage.objectives.indices, id: \.self) { index in
                        Button(action: {
                            // CHANGE: toggle the objective AND immediately
                            // resync progress/subtitle/state on the stage.
                            withAnimation(.spring()) {
                                currentStage.objectives[index].isCompleted.toggle()
                                syncStageProgressFromObjectives()
                                // CHANGE: خلّص تاسك فعليًا اليوم → يحسب للستريك.
                                // ما نحسبها لو رجع وسوى Uncheck.
                                if currentStage.objectives[index].isCompleted {
                                    StreakManager.shared.recordTaskCompletion()
                                }
                            }
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: currentStage.objectives[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(currentStage.objectives[index].isCompleted ? Color("appGreen") : Color("faded text"))

                                Text(currentStage.objectives[index].title)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color("priemary texts"))
                                    .strikethrough(currentStage.objectives[index].isCompleted, color: Color("faded text"))
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        if index < currentStage.objectives.count - 1 {
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
    // CHANGE: كانت فاضية دايمًا (بس عنوان بدون محتوى). الحين تعرض فعليًا
    // الريسورسس اللي يقترحها الـ AI لهذي المرحلة عشان اليوزر يرجع لها.
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

            if isResourcesExpanded {
                Divider()

                if currentStage.resources.isEmpty {
                    Text("No resources yet for this stage.")
                        .font(.system(size: 13))
                        .foregroundColor(Color("faded text"))
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(currentStage.resources, id: \.self) { resource in
                            // CHANGE: كل ريسورس الحين قابل للضغط فعليًا — يضغطها
                            // اليوزر تنسخ له النص عشان يستخدمه (يبحث عنه، يفتحه
                            // بمتصفح، إلخ)، مع فيدباك واضح (Copied) إنها استجابت.
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
                    monthLabel: "Month 1",
                    iconName: "magnifyingglass",
                    description: "Understand your target market, study competitors, and gather insights to build a strong foundation.",
                    priorityReason: "High initial competition",
                    objectives: [
                        StageObjective(title: "Validate market demand.", isCompleted: true),
                        StageObjective(title: "Analyze competitors", isCompleted: true),
                        StageObjective(title: "Identify primary user persona", isCompleted: false)
                    ],
                    resources: ["Saudi MISA business registration portal", "Local municipality licensing office"]
                )
            )
        )
    }
}
