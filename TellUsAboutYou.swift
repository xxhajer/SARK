import SwiftUI

struct TellUsAboutYouView: View {
    @Environment(\.dismiss) private var dismiss
    var onFinishCreation: (() -> Void)? = nil
    @State private var navigateToEvaluation = false
    
    // State Variables
    @State private var selectedBudget = "Select budget"
    @State private var selectedExperience = "Select experience"
    @State private var selectedGoal = "Select business goal"
    @State private var selectedTimeline = "Select timeline"
    @State private var selectedRisk = "Select risk tolerance"
    
    // Options Data
    let budgetOptions = ["Under 5,000 SAR", "5,000 SAR - 10,000 SAR", "10,000 SAR - 25,000 SAR", "25,000 SAR - 50,000 SAR", "50,000 SAR+"]
    let experienceOptions = ["Beginner", "Intermediate", "Advanced"]
    let goalOptions = ["Validate a new idea", "Build a scalable business", "Side income / Passive business", "Fast ROI"]
    let timelineOptions = ["Under 1 month", "1 - 3 months", "3 - 6 months", "6+ months"]
    let riskOptions = ["Low", "Medium", "High"]
    
    private var isFormValid: Bool {
        selectedBudget != "Select budget" &&
        selectedExperience != "Select experience" &&
        selectedGoal != "Select business goal" &&
        selectedTimeline != "Select timeline" &&
        selectedRisk != "Select risk tolerance"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar (سهم العودة للشاشة السابقة فقط)
            HStack {
                Button(action: {
                    dismiss() // يرجع للخلف لصفحة StartFromScratchView
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color("priemary texts"))
                        .contentShape(Rectangle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tell us a bit about you")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color("priemary texts"))
                        
                        Text("This helps us personalize your journey.")
                            .font(.system(size: 15))
                            .foregroundColor(Color("faded text"))
                    }
                    .padding(.top, 4)
                    
                    VStack(spacing: 14) {
                        CustomPickerRow(iconType: .asset("budgetIcon", Color("appGreen")), title: "Budget", placeholder: "Select budget", selection: $selectedBudget, options: budgetOptions)
                        CustomPickerRow(iconType: .asset("experienceIcon", Color("appOrange")), title: "Experience", placeholder: "Select experience", selection: $selectedExperience, options: experienceOptions)
                        CustomPickerRow(iconType: .system("target", Color("appGreen")), title: "Business Goal", placeholder: "Select business goal", selection: $selectedGoal, options: goalOptions)
                        CustomPickerRow(iconType: .system("timer", Color("appGreen")), title: "Timeline", placeholder: "Select timeline", selection: $selectedTimeline, options: timelineOptions)
                        CustomPickerRow(iconType: .system("exclamationmark.triangle.fill", Color("appOrange")), title: "Risk Tolerance", placeholder: "Select risk tolerance", selection: $selectedRisk, options: riskOptions)
                    }
                    
                    // الزر الأخضر ينقل للشاشة التالية IdeaEvaluationView
                    Button(action: {
                        if isFormValid {
                            navigateToEvaluation = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Evaluate My Idea")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .buttonStyle(PrimaryAppButtonStyle(isEnabled: isFormValid))
                    .disabled(!isFormValid)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color("Background").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToEvaluation) {
            IdeaEvaluationView(onFinishCreation: onFinishCreation)
        }
    }
}

// MARK: - Primary Button Style
struct PrimaryAppButtonStyle: ButtonStyle {
    var height: CGFloat = 52
    var cornerRadius: CGFloat = 26
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color("inside the green"))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(isEnabled ? Color("appGreen") : Color("appGreen").opacity(0.4))
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

enum RowIconType {
    case asset(String, Color)
    case system(String, Color)
}

private struct CustomPickerRow: View {
    let iconType: RowIconType
    let title: String
    let placeholder: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        } label: {
            HStack(spacing: 16) {
                Group {
                    switch iconType {
                    case .asset(let imageName, let tintColor):
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(tintColor.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                    case .system(let systemName, let tintColor):
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(tintColor.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: systemName)
                                .font(.system(size: 18))
                                .foregroundColor(tintColor)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("priemary texts"))
                    Text(selection)
                        .font(.system(size: 13))
                        .foregroundColor(selection == placeholder ? Color("faded text") : Color("priemary texts"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("faded text"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("boxes"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
    }
}

#Preview {
    NavigationStack {
        TellUsAboutYouView()
    }
}
