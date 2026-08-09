import SwiftUI

// MARK: - 1. Business Data Model
struct BusinessItem: Identifiable {
    let id = UUID()
    var name: String
    var stage: String
    var progress: Double
    var iconName: String
    var lastUpdated: String
}

// MARK: - 2. Main Screen View
struct MyBusinessesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    // القائمة فارغة لعرض الواجهة الفاضية في البداية
    @State private var businesses: [BusinessItem] = []
    
    var filteredBusinesses: [BusinessItem] {
        if searchText.isEmpty {
            return businesses
        } else {
            return businesses.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            
            // Header Bar
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
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Businesses")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color("priemary texts"))

                        Text("Manage and track all your ventures.")
                            .font(.system(size: 15))
                            .foregroundColor(Color("faded text"))
                    }

                    // Count Label
                    Text("\(businesses.count) Active Businesses")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("priemary texts"))

                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("faded text"))
                            .font(.system(size: 16))
                        
                        TextField("Search business..", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(Color("priemary texts"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("boxes"))
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)

                    // CONDITION: Empty State vs Businesses List
                    if businesses.isEmpty {
                        
                        // ===== الواجهة الفاضية (باستخدام صورة sad-fac) =====
                        VStack(spacing: 16) {
                            Spacer().frame(height: 30)
                            
                            Text("You have no\nbusinesses")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("priemary texts"))
                                .multilineTextAlignment(.center)

                            // صورة الوجه الحزين المضافة في الـ Assets
                            Image("sad-fac")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)

                            Text("Start your First!")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color("priemary texts"))
                                .padding(.top, 16)

                            // زر ينقل فوراً لشاشة StartFromScratchView
                            NavigationLink(destination: StartFromScratchView()) {
                                HStack {
                                    Text("+New Business")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .buttonStyle(PrimaryAppButtonStyle())
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        
                    } else {
                        
                        // ===== الواجهة المليانة (عند وجود مشاريع) =====
                        VStack(spacing: 16) {
                            ForEach(filteredBusinesses) { item in
                                BusinessCardView(item: item)
                            }

                            NavigationLink(destination: StartFromScratchView()) {
                                HStack {
                                    Text("+ New Business")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .buttonStyle(PrimaryAppButtonStyle())
                            .padding(.top, 12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color("Background").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - 3. Business Card Component
private struct BusinessCardView: View {
    let item: BusinessItem

    var body: some View {
        NavigationLink(destination: IdeaEvaluationView()) {
            HStack(spacing: 16) {
                // Icon Background
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

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("priemary texts"))
                    }

                    Text(item.stage)
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        MyBusinessesView()
    }
}
