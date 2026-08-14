import SwiftUI

// MARK: - Shown right after the user taps "Accept" on Idea Evaluation.
// Lets them confirm/change the AI-suggested business name before moving on
// to Roadmap generation.
struct NameYourProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID
    var onFinishCreation: ((UUID) -> Void)? = nil

    @State private var projectName: String = ""
    @State private var navigateToRoadmap = false

    private var isFormValid: Bool {
        !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color("priemary texts"))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What do you want to\nname your project?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        Text("We picked a name based on your idea — feel free to change it.")
                            .font(.system(size: 15))
                            .foregroundColor(Color("faded text"))
                    }
                    .padding(.top, 4)

                    TextField("Project name", text: $projectName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("priemary texts"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color("boxes"))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                    Button(action: {
                        guard isFormValid, let idx = store.index(of: businessID) else { return }
                        store.businesses[idx].name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
                        navigateToRoadmap = true
                    }) {
                        HStack(spacing: 8) {
                            Text("Continue to Roadmap")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .buttonStyle(PrimaryAppButtonStyle(isEnabled: isFormValid))
                    .disabled(!isFormValid)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color("Background").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToRoadmap) {
            RoadmapView(businessID: businessID, onFinishCreation: onFinishCreation)
        }
        .onAppear {
            if projectName.isEmpty, let idx = store.index(of: businessID) {
                projectName = store.businesses[idx].name
            }
        }
    }
}

#Preview {
    NavigationStack {
        NameYourProjectView(businessID: UUID())
    }
}
