import SwiftUI

struct StartFromScratchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var loc = LocalizationManager.shared
    var onFinishCreation: ((UUID) -> Void)? = nil
    var onReject: (() -> Void)? = nil

    // MARK: - State Properties
    @State private var ideaText: String = ""
    @State private var selectedIndustry: String? = nil
    @State private var navigateToNext: Bool = false

    private let characterLimit = 1000
    // CHANGE: أضفنا حد أدنى لعدد الكلمات — كانت الفكرة ممكن تنكتب بكلمة أو
    // كلمتين بس، وهذا مايكفي للـ AI يفهم المشروع صح ويعطي تقييم/رود ماب/
    // بجت دقيق. الحين لازم ٢٠ كلمة على الأقل قبل ما يقدر يكمل.
    private let minWordCount = 20

    private var wordCount: Int {
        ideaText
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .filter { !$0.isEmpty }
            .count
    }

    private var isFormValid: Bool {
        wordCount >= minWordCount && selectedIndustry != nil
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                // زر إغلاق الفلو
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("priemary texts"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // 1. Titles Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("What's your\nbusiness idea?"))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color("priemary texts"))
                                .fixedSize(horizontal: false, vertical: true)

                            Text(L("Describe your idea in a few sentences."))
                                .font(.system(size: 16))
                                .foregroundColor(Color("faded text"))
                        }
                        .padding(.top, 20)

                        // 2. Text Input Box
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("boxes"))

                            VStack(alignment: .leading) {
                                ZStack(alignment: .topLeading) {
                                    if ideaText.isEmpty {
                                        Text(L("Describe your business idea..."))
                                            .foregroundColor(Color("faded text"))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 8)
                                    }

                                    TextEditor(text: $ideaText)
                                        .scrollContentBackground(.hidden)
                                        .foregroundColor(Color("long texts"))
                                        .font(.body)
                                        .textInputAutocapitalization(.sentences)
                                        .frame(minHeight: 140)
                                        .onChange(of: ideaText) { newValue in
                                            if newValue.count > characterLimit {
                                                ideaText = String(newValue.prefix(characterLimit))
                                            }
                                        }
                                }

                                Spacer()

                                HStack {
                                    // CHANGE: عداد الكلمات الحين يبين وشو ينقص
                                    // أو يأكد إنه كافي (يتلون أخضر لما يكفي).
                                    Text(wordCount >= minWordCount
                                         ? "✓ \(wordCount) \(L("words"))"
                                         : "\(wordCount)/\(minWordCount) \(L("words minimum"))")
                                        .font(.caption)
                                        .foregroundColor(wordCount >= minWordCount ? Color("appGreen") : Color("appOrange"))

                                    Spacer()
                                    Text("\(ideaText.count)/\(characterLimit)")
                                        .font(.caption)
                                        .foregroundColor(Color("faded text"))
                                }
                            }
                            .padding(16)
                        }
                        .frame(height: 200)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)

                        // CHANGE: رسالة توضيحية تحت المربع تفهّم اليوزر ليه
                        // فيه حد أدنى — عشان الـ AI يقدر يشرح المشروع صح.
                        if wordCount < minWordCount {
                            Text("\(L("Write at least")) \(minWordCount) \(L("words so the AI can understand and explain your project accurately."))")
                                .font(.system(size: 12))
                                .foregroundColor(Color("faded text"))
                                .padding(.top, -12)
                        }

                        // 3. Industry Selection
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("Select your industry"))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("priemary texts"))

                            HStack(spacing: 16) {
                                IndustryCard(
                                    title: "Food &\nBeverage",
                                    imageName: "foodIcon",
                                    isSelected: selectedIndustry == "Food & Beverage"
                                ) {
                                    selectedIndustry = "Food & Beverage"
                                }

                                IndustryCard(
                                    title: "Retail",
                                    imageName: "retailIcon",
                                    isSelected: selectedIndustry == "Retail"
                                ) {
                                    selectedIndustry = "Retail"
                                }
                            }
                        }

                        // 4. Continue Button
                        Button(action: {
                            if isFormValid {
                                navigateToNext = true
                            }
                        }) {
                            HStack {
                                Text(L("Continue"))
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(Color("inside the green"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                isFormValid ? Color("appGreen") : Color("appGreen").opacity(0.4)
                            )
                            .cornerRadius(28)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                }
            }
            .padding(.horizontal, 24)
            .background(Color("Background").ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToNext) {
                TellUsAboutYouView(
                    ideaText: ideaText,
                    industry: selectedIndustry ?? "General",
                    onFinishCreation: onFinishCreation,
                    onReject: onReject
                )
            }
        }
    }
}

// MARK: - Subview for Industry Cards
struct IndustryCard: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)

                Text(L(title))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("priemary texts"))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(Color("boxes"))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color("appGreen") : Color.clear, lineWidth: 2)
                    .padding(1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
    }
}

#Preview {
    StartFromScratchView()
}
