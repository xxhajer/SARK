import SwiftUI

// MARK: - Main Screen View
struct MyBusinessesView: View {
    @ObservedObject private var store = BusinessStore.shared
    @State private var searchText: String = ""
    @State private var showNewBusiness = false
    @State private var navigateToNewDashboard = false
    @State private var newDashboardBusinessID: UUID? = nil

    // CHANGE: البروفايل انشال كامل بناءً على ملاحظات المنتورة — زر حذف
    // الحساب انتقل هنا لأيقونة دائرية صغيرة فوق الشاشة بدل ما يكون بصفحة
    // بروفايل منفصلة.
    @State private var showAccountMenu = false
    @State private var showDeleteAlert = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @ObservedObject private var streak = StreakManager.shared
    // CHANGE: نراقب اللغة الحالية عشان الشاشة تعيد رسم نفسها فورًا لما
    // اليوزر يبدّل اللغة من قائمة الحساب.
    @ObservedObject private var loc = LocalizationManager.shared

    var filteredBusinesses: [Business] {
        if searchText.isEmpty {
            return store.businesses
        } else {
            return store.businesses.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            // CHANGE: تحولت من ScrollView+VStack إلى List عشان نقدر نسحب
            // بطاقة بزنس ونحذفها (swipe to delete) — أضفنا listRowSeparator
            // و listRowBackground شفاف لكل صف عشان الشكل يضل بالضبط نفس
            // التصميم الأصلي (بدون خطوط فاصلة أو خلفية لست تقليدية).
            List {
                Group {
                    // Header Bar — بدون سهم رجوع (كانت لا تسوي شي أصلاً لأن
                    // هذي الشاشة تاب رئيسي مو صفحة مدفوعة). بدلها أيقونة
                    // دائرية صغيرة فوق تفتح خيارات الحساب (حذف الحساب).
                    HStack {
                        Spacer()
                        Button(action: { showAccountMenu = true }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("priemary texts"))
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color("boxes")))
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L("My Businesses"))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        Text(L("Manage and track all your ventures."))
                            .font(.system(size: 15))
                            .foregroundColor(Color("faded text"))
                    }
                    .padding(.top, 8)

                    Text("\(store.businesses.count) \(L("Active Businesses"))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("priemary texts"))
                        .padding(.top, 18)

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("faded text"))
                            .font(.system(size: 16))

                        TextField(L("Search business.."), text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(Color("priemary texts"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("boxes"))
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                    .padding(.top, 18)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

                if store.businesses.isEmpty {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 30)

                        Text(L("You have no\nbusinesses"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("priemary texts"))
                            .multilineTextAlignment(.center)

                        Image("sad-fac")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)

                        Text(L("Start your First!"))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("priemary texts"))
                            .padding(.top, 16)

                        Button(action: {
                            showNewBusiness = true
                        }) {
                            Text(L("+New Business"))
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .buttonStyle(PrimaryAppButtonStyle())
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    // CHANGE: كل بطاقة بزنس صارت قابلة للسحب لليسار وتظهر
                    // زر حذف — هذا هو طلب المنتورة "نقدر نسحبه ثم يصير حذف".
                    ForEach(filteredBusinesses) { item in
                        BusinessCardView(item: item)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        store.removeBusiness(item.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }

                    Button(action: {
                        showNewBusiness = true
                    }) {
                        Text(L("+ New Business"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(PrimaryAppButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                Color.clear.frame(height: 100)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color("Background"))
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToNewDashboard) {
            if let id = newDashboardBusinessID {
                projectDashBoard(businessID: id)
            }
        }
        .fullScreenCover(isPresented: $showNewBusiness) {
            StartFromScratchView(
                onFinishCreation: { finishedBusinessID in
                    showNewBusiness = false
                    newDashboardBusinessID = finishedBusinessID
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToNewDashboard = true
                    }
                },
                onReject: {
                    // المستخدم رفض الفكرة — نقفل الفلو ونرجع لـ My Businesses
                    // بدون ما نضيف أي بزنس (وبزنس الدرافت انحذف من الستور).
                    showNewBusiness = false
                }
            )
        }
        // CHANGE: نفس منطق حذف الحساب اللي كان بالبروفايل، نقلناه هنا —
        // وضفنا فيه خيار تبديل لغة الواجهة (عربي/إنجليزي).
        .confirmationDialog(L("Account"), isPresented: $showAccountMenu) {
            Button(loc.language == .en ? L("Switch to Arabic") : L("Switch to English")) {
                loc.toggle()
            }
            Button(L("Delete Account"), role: .destructive) {
                showDeleteAlert = true
            }
            Button(L("Cancel"), role: .cancel) {}
        }
        .alert(L("Delete Your Account"), isPresented: $showDeleteAlert) {
            Button(L("Cancel"), role: .cancel) {}
            Button(L("Delete"), role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text(L("This will erase your name and all your businesses, and take you back to the beginning. Are you sure?"))
        }
    }

    private func deleteAccount() {
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        streak.reset()
        store.removeAll()
        hasCompletedOnboarding = false
    }
}

// MARK: - Business Card Component
private struct BusinessCardView: View {
    let item: Business

    var body: some View {
        // CHANGE: النافيجيشن لينك صار مخفي تمامًا (opacity 0) بالخلفية —
        // هذا يشيل سهم الـ"disclosure chevron" التلقائي اللي كان List
        // يضيفه على يمين الصف (السهم "الخارجي")، بدون ما نأثر على إن
        // الكرت لسه قابل للضغط والانتقال لصفحة البزنس.
        ZStack {
            NavigationLink(destination: projectDashBoard(businessID: item.id)) {
                EmptyView()
            }
            .opacity(0)

            // CHANGE: الخط المظلل صار برا صندوق الكرت (مو جواه)، جنبه من
            // برا — عشان يبين واضح إنه تلميح منفصل على إن الكرت يُسحب،
            // مو جزء من محتوى الكرت نفسه.
            HStack(spacing: 10) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("appGreen"))
                            .frame(width: 54, height: 54)

                        Image(systemName: item.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.name)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color("priemary texts"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color("priemary texts"))
                        }

                        Text(item.stageLabel)
                            .font(.system(size: 13))
                            .foregroundColor(Color("faded text"))

                        HStack(spacing: 8) {
                            Text("\(Int(item.progress * 100))%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color("priemary texts"))

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 6)

                                    Capsule()
                                        .fill(Color("appOrange"))
                                        .frame(width: geo.size.width * CGFloat(item.progress), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }

                        Text(item.lastUpdated)
                            .font(.system(size: 11))
                            .foregroundColor(Color("faded text"))
                    }
                }
                .padding(16)
                .background(Color("boxes"))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                // CHANGE: خط صغير مظلل (swipe hint) برا الكرت تمامًا —
                // تلميح بصري خفيف إن الكرت يُسحب، مو زر ولا رابط.
                Capsule()
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 4, height: 28)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyBusinessesView()
    }
}
