import SwiftUI

@main
struct SARKApp: App {
    // CHANGE: لما اللغة عربي، كل شاشات التطبيق تنقلب تلقائيًا يمين-لشمال
    // (RTL) — نفس سلوك تطبيقات آبل نفسها. نطبقها هنا فوق أول شاشة عشان
    // تنورث لكل الشاشات تحتها (سبلاش → أونبوردنق → التابات → كل الداخل).
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            SplashView() // أو اسم الشاشة الأولى اللي تفتح عندك
                .preferredColorScheme(.light)
                .environment(\.layoutDirection, loc.language == .ar ? .rightToLeft : .leftToRight)
        }
    }
}
