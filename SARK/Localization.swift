//
//  Localization.swift
//  SARK
//
//  CHANGE: سويتش يقلب نصوص واجهة التطبيق الثابتة (عناوين، أزرار، تسميات)
//  بين الإنجليزي والعربي — بدون ما يغيّر أي شي بالتصميم (مقاسات/محاذاة/
//  ألوان كلها زي ما هي، فقط النص نفسه يتغيّر). المحتوى اللي يجيب من الـ
//  AI (اسم المشروع، الفكرة، الرود ماب...) مو داخل بهذا النظام لأنه أصلاً
//  يطلع بنفس لغة الفكرة اللي كتبها المستخدم.
//
//  طريقة الاستخدام: بدل Text("Budget") نكتب Text(L("Budget")) — لو اللغة
//  الحالية عربي، ترجع الترجمة العربية من القاموس تحت؛ لو إنجليزي أو
//  الترجمة غير موجودة بالقاموس، ترجع النص الإنجليزي الأصلي كما هو (يعني
//  ما ينكسر أي مكان حتى لو ما ترجمناه بعد).
//

import SwiftUI
import Combine

enum AppLanguage: String {
    case en
    case ar
}

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.en.rawValue
        language = AppLanguage(rawValue: saved) ?? .en
    }

    func toggle() {
        language = (language == .en) ? .ar : .en
    }
}

// Global helper — call L("Some English UI string") anywhere in the app.
func L(_ key: String) -> String {
    guard LocalizationManager.shared.language == .ar else { return key }
    return arabicStrings[key] ?? key
}

// CHANGE: قاموس الترجمة — كل شاشة نضيف لها الترجمة نضيف مفاتيحها هنا.
// حالياً مغطى: My Businesses + Project Dashboard (أكثر الشاشات استخدامًا).
// باقي الشاشات (Budget/Roadmap/Idea Evaluation التفصيلية) بتتضاف تباعًا.
private let arabicStrings: [String: String] = [
    // MARK: My Businesses
    "My Businesses": "مشاريعي",
    "Manage and track all your ventures.": "تابعي وأديري كل مشاريعك.",
    "Search business..": "ابحثي عن مشروع..",
    "You have no\nbusinesses": "ماعندك\nمشاريع",
    "Start your First!": "ابدئي أول مشروع لك!",
    "Active Businesses": "مشروع نشط",
    "+New Business": "+ مشروع جديد",
    "+ New Business": "+ مشروع جديد",
    "Account": "الحساب",
    "Delete Account": "حذف الحساب",
    "Cancel": "إلغاء",
    "Delete": "حذف",
    "Delete Your Account": "حذف حسابك",
    "This will erase your name and all your businesses, and take you back to the beginning. Are you sure?":
        "هذا بيمسح اسمك وكل مشاريعك، ويرجعك للبداية. متأكدة؟",
    "Switch to Arabic": "التبديل للعربي",
    "Switch to English": "التبديل للإنجليزي",

    // MARK: Project Dashboard
    "Current Stage": "المرحلة الحالية",
    "Overall Progress": "التقدم الكلي",
    "Today's Goal": "هدف اليوم",
    "Next Milestone": "المحطة القادمة",
    "Trend Insight": "نصيحة ترند",
    "Tap for a tip": "اضغطي لنصيحة",
    "Quick Actions": "إجراءات سريعة",
    "Tap any icon below to open it": "اضغطي أي أيقونة تحت عشان تفتحينها",
    "Idea Evaluation": "تقييم الفكرة",
    "Budget": "الميزانية",
    "Roadmap": "خارطة الطريق",

    // MARK: Common
    "Try Again": "حاولي مرة ثانية",
    "View All": "عرض الكل",
    "Status": "الحالة",
    "Category": "الفئة",
    "Date": "التاريخ",
    "Payment Method": "طريقة الدفع",
    "Notes": "ملاحظات",
    "Attachment": "مرفق",
    "Hello": "هلا",

    // MARK: Onboarding / Splash
    "Business Plan": "خطة عمل",
    "Personalized": "مخصصة لك",
    "Turn your unique idea into a structured, custom business plan.": "حوّلي فكرتك الفريدة لخطة عمل منظمة ومخصصة لك.",
    "Next": "التالي",
    "skip": "تخطي",
    "Roadmap &": "خارطة طريق و",
    "Actionable Steps": "خطوات عملية",
    "Follow clear, step-by-step guidance to execute your startup goals.": "اتبعي إرشادات واضحة خطوة بخطوة لتنفيذ أهداف مشروعك.",
    "Start!": "ابدأ!",

    // MARK: Home
    "New Business": "مشروع جديد",
    "Ready to grow\nyour business?": "جاهزة تكبّرين\nمشروعك؟",
    "Start a new business with AI guidance": "ابدئي مشروع جديد بمساعدة الذكاء الاصطناعي",
    "Today's Tip": "نصيحة اليوم",
    "Focus on solving a real\nproblem for your customers": "ركزي على حل مشكلة حقيقية\nلعملائك",
    "Keep growing your business!": "استمري بتنمية مشروعك!",

    // MARK: Tab Bar
    "Home": "الرئيسية",
    "Projects": "مشاريعي",

    // MARK: Start From Scratch (idea input)
    "What's your\nbusiness idea?": "وش فكرة\nمشروعك؟",
    "Describe your idea in a few sentences.": "وصفي فكرتك بعدة جمل.",
    "Describe your business idea...": "وصفي فكرة مشروعك...",
    "Select your industry": "اختاري مجال مشروعك",
    "Continue": "متابعة",
    "words": "كلمة",
    "words minimum": "كلمة على الأقل",
    "Write at least": "اكتبي على الأقل",
    "words so the AI can understand and explain your project accurately.": "كلمة عشان الذكاء الاصطناعي يقدر يفهم مشروعك ويشرحه بدقة.",

    // MARK: Tell Us About You
    "Tell us a bit about you": "خبرينا شوي عن نفسك",
    "This helps us personalize your journey.": "هذا يساعدنا نخصص رحلتك.",
    "Location": "الموقع",
    "Select location": "اختاري الموقع",
    "Market": "السوق",
    "Select market": "اختاري السوق",
    "Select budget": "اختاري الميزانية",
    "Experience": "الخبرة",
    "Select experience": "اختاري مستوى خبرتك",
    "Business Goal": "هدف المشروع",
    "Select business goal": "اختاري هدف المشروع",
    "Timeline": "الجدول الزمني",
    "Select timeline": "اختاري المدة الزمنية",
    "Risk Tolerance": "تحمل المخاطرة",
    "Select risk tolerance": "اختاري مستوى تحمل المخاطرة",
    "Evaluate My Idea": "قيّمي فكرتي",

    // MARK: Idea Evaluation
    "AI Recommendation": "توصية الذكاء الاصطناعي",
    "Accept": "قبول",
    "Reject": "رفض",
    "Open Roadmap": "افتحي خارطة الطريق",
    "Overall Score": "التقييم العام",

    // MARK: Name Your Project
    "What do you want to\nname your project?": "وش تبين تسمين\nمشروعك؟",
    "We picked a name based on your idea — feel free to change it.": "اخترنا اسم بناءً على فكرتك — لك حرية تغييره.",
    "Project name": "اسم المشروع",
    "Continue to Roadmap": "متابعة لخارطة الطريق",

    // MARK: Roadmap
    "Stage": "المرحلة",
    "of": "من",
    "overall": "إجمالي",
    "Up next": "القادم",
    "Congratulations! 🎉": "مبروك! 🎉",
    "You've completed all stages in your business roadmap. Your project is ready for launch!":
        "خلّصتِ كل مراحل خارطة طريق مشروعك. مشروعك جاهز للانطلاق!",
    "Go to Dashboard": "الذهاب للداشبورد",
    "Description": "الوصف",
    "Objectives": "الأهداف",
    "Prioritized based on:": "أولوية بناءً على:",
    "Resources": "مصادر",
    "No resources yet for this stage.": "لا توجد مصادر لهذي المرحلة بعد.",
    "Copied": "تم النسخ",
    "Proceed to Next Stage": "الانتقال للمرحلة التالية",
    "Finish Stage": "إنهاء المرحلة",

    // MARK: Budget
    "Budget Overview": "نظرة عامة على الميزانية",
    "Track all project expenses in one place.": "تابعي كل مصاريف مشروعك بمكان واحد.",
    "Total Budget": "إجمالي الميزانية",
    "Spent": "المصروف",
    "Remaining": "المتبقي",
    "Used": "المستخدم",
    "Recent Expenses": "أحدث المصاريف",
    "No expenses yet.": "لا توجد مصاريف بعد.",
    "Add Expense": "إضافة مصروف",
    "Your Budget": "ميزانيتك",
    "Realistic Cost": "التكلفة الواقعية",
    "Shortfall": "العجز",
    "This removes all expenses and lets you generate a fresh budget.": "هذا يمسح كل المصاريف ويخليك تولّدين ميزانية جديدة.",
    "Delete Budget": "حذف الميزانية",
    "Delete this entire budget?": "تحذفين الميزانية بالكامل؟",
    "Building your budget...": "نبني ميزانيتك...",
    "Your stated budget may not be enough to realistically launch this business.": "ميزانيتك المذكورة ممكن ما تكفي واقعيًا لإطلاق هذا المشروع.",

    // MARK: All Expenses
    "All Expenses": "كل المصاريف",
    "Search expenses..": "ابحثي عن مصروف..",
    "This Month": "هذا الشهر",
    "Last Month": "الشهر الماضي",
    "All Time": "كل الوقت",
    "Total Spent": "إجمالي المصروف",

    // MARK: Add / Detail Expense
    "Amount": "المبلغ",
    "Expense Name": "اسم المصروف",
    "e.g Logo Design": "مثال: تصميم شعار",
    "Notes (optional)": "ملاحظات (اختياري)",
    "Add a note...": "أضيفي ملاحظة...",
    "Did you already pay this?": "هل دفعتِ هذا المصروف فعلاً؟",
    "Executed": "منفّذ",
    "Not Executed": "غير منفّذ",
    "Save Expense": "حفظ المصروف",
    "Delete Expense": "حذف المصروف",
    "This expense no longer exists.": "هذا المصروف ماعاد موجود.",
    "Delete this expense?": "تحذفين هذا المصروف؟",

    // MARK: Notifications
    "Notifications": "الإشعارات",
    "Recent": "الأحدث",
    "Check-in": "تسجيل حضور",
    "Progress reminder": "تذكير بالتقدم",
    "Daily reminders": "تذكيرات يومية",
    "yesterday · your project is one step closer": "أمس · مشروعك اقترب خطوة",
    "2days ago · Pick Up where you left off": "قبل يومين · كملي من وين وقفتِ",

    // MARK: Roadmap (extra)
    "complete": "مكتمل",
    "STAGE": "المرحلة",

    // MARK: Expense Categories (display-only, functional value stays English)
    "Design": "تصميم",
    "Marketing": "تسويق",
    "Supplies": "مستلزمات",
    "Other": "أخرى",

    // MARK: Industry Cards (display-only, functional value stays English)
    "Food &\nBeverage": "أطعمة\nومشروبات",
    "Retail": "تجزئة",

    // MARK: Tell Us About You — option lists (display-only, functional value stays English)
    "Riyadh": "الرياض",
    "Dammam": "الدمام",
    "Jeddah": "جدة",
    "Not decided yet": "لسه ما قررت",
    "Under 50,000 SAR": "أقل من ٥٠,٠٠٠ ريال",
    "50,000 SAR - 100,000 SAR": "٥٠,٠٠٠ - ١٠٠,٠٠٠ ريال",
    "100,000 SAR - 300,000 SAR": "١٠٠,٠٠٠ - ٣٠٠,٠٠٠ ريال",
    "300,000 SAR - 500,000 SAR": "٣٠٠,٠٠٠ - ٥٠٠,٠٠٠ ريال",
    "500,000 SAR+": "أكثر من ٥٠٠,٠٠٠ ريال",
    "Beginner": "مبتدئة",
    "Intermediate": "متوسطة",
    "Advanced": "متقدمة",
    "Validate a new idea": "التحقق من فكرة جديدة",
    "Build a scalable business": "بناء مشروع قابل للتوسع",
    "Side income / Passive business": "دخل جانبي / مشروع سلبي",
    "Fast ROI": "عائد سريع على الاستثمار",
    "Under 1 month": "أقل من شهر",
    "1 - 3 months": "١ - ٣ أشهر",
    "3 - 6 months": "٣ - ٦ أشهر",
    "6+ months": "أكثر من ٦ أشهر",
    "Low": "منخفض",
    "Medium": "متوسط",
    "High": "عالي",
    "Local (Saudi Arabia)": "محلي (السعودية)",
]
