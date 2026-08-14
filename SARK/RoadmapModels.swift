//
//  RoadmapModels.swift
//  SARK
//
//  Created by hajer almejel on 27/02/1448 AH.
//
//
//  RoadmapModels.swift
//  SARK
//
//  Created by Hadeel Yahya Awaji on 24/02/1448 AH.
//

import SwiftUI

// MARK: - Models
// Codable so a business's AI-generated roadmap can be saved to UserDefaults
// and reloaded after the app relaunches.
struct StageObjective: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct RoadmapStage: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String

    // These three must be `var`, not `let` — RoadmapDetailsView writes
    // updated values into them whenever objectives are checked/unchecked,
    // so the timeline reflects real progress when you navigate back.
    var subtitle: String
    var progressPercentage: Int
    var state: TimelineStepState   // ← reuse the existing enum from RoadmapView.swift

    // e.g. "Month 1" / "Week 2" — how far into the founder's chosen timeline
    // this stage falls. Set by GeminiService.generateRoadmap so the roadmap
    // actually scales with the timeline the user picked.
    var monthLabel: String

    let iconName: String
    let description: String
    let priorityReason: String
    var objectives: [StageObjective]

    // Short reference points/resources the AI suggests for this stage, shown
    // in RoadmapDetailsView so the user has something to come back to.
    var resources: [String]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        progressPercentage: Int,
        state: TimelineStepState,
        monthLabel: String = "",
        iconName: String,
        description: String,
        priorityReason: String,
        objectives: [StageObjective],
        resources: [String]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.progressPercentage = progressPercentage
        self.state = state
        self.monthLabel = monthLabel
        self.iconName = iconName
        self.description = description
        self.priorityReason = priorityReason
        self.objectives = objectives
        self.resources = resources
    }

    // Custom decode so roadmaps saved BEFORE `monthLabel` existed still load
    // instead of failing and wiping the whole business out of the store.
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, progressPercentage, state, monthLabel,
             iconName, description, priorityReason, objectives, resources
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        progressPercentage = try container.decode(Int.self, forKey: .progressPercentage)
        state = try container.decode(TimelineStepState.self, forKey: .state)
        monthLabel = try container.decodeIfPresent(String.self, forKey: .monthLabel) ?? ""
        iconName = try container.decode(String.self, forKey: .iconName)
        description = try container.decode(String.self, forKey: .description)
        priorityReason = try container.decode(String.self, forKey: .priorityReason)
        objectives = try container.decode([StageObjective].self, forKey: .objectives)
        resources = try container.decodeIfPresent([String].self, forKey: .resources) ?? []
    }
}
