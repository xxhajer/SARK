import SwiftUI

@main
struct SARKApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView() // أو اسم الشاشة الأولى اللي تفتح عندك
                .preferredColorScheme(.light)
        }
    }
}
