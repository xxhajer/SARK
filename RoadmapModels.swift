//
//  RoadmapModels.swift
//  SARK
//
//  Created by Hadeel Yahya Awaji on 24/02/1448 AH.
//

import SwiftUI

// MARK: - Models
struct StageObjective: Identifiable, Hashable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}

struct RoadmapStage: Identifiable, Hashable {
    let id = UUID()
    let title: String

    // These three must be `var`, not `let` — RoadmapDetailsView writes
    // updated values into them whenever objectives are checked/unchecked,
    // so the timeline reflects real progress when you navigate back.
    var subtitle: String
    var progressPercentage: Int
    var state: TimelineStepState   // ← reuse the existing enum from RoadmapView.swift

    let iconName: String
    let description: String
    let priorityReason: String
    var objectives: [StageObjective]
    var resources: [String]
}
