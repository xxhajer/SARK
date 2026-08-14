import SwiftUI

struct projectDashBoard: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 2

    var body: some View {
        ZStack(alignment: .bottom){
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .center, spacing: 0) {

                    HStack(spacing: 35) {

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.black)
                        }

                        Text("Lena's coffee shop")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)

                    VStack(alignment: .leading, spacing: 20) {
                        HStack {

                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.greeen)
                                .frame(width: 55, height: 65)
                                .overlay(
                                    Image("document")
                                        .foregroundColor(.white)
                                        .font(.system(size:0))
                                )

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Stage")
                                    .foregroundColor(.fadedText)
                                    .font(.system(size: 16, weight: .medium))
                                Text("Business Plan")
                                    .foregroundColor(.black)
                                    .font(.system(size: 20, weight: .bold))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 15) {
                                Text("Overall Progress")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18, weight: .semibold))
                                Text("70%")
                                    .foregroundColor(.black)
                                    .font(.system(size: 35, weight: .bold))
                            }
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.orangee)
                                    .frame(width: geo.size.width * 0.7, height: 8)
                            }
                        }
                        .frame(height: 1)
                    }
                    .padding(25)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                            .frame(width: 380, height: 150)
                    )
                    .padding(.bottom, 25)

                    HStack(spacing: 20) {
                        Image("goal")

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today's Goal")
                                .foregroundColor(.insideTheGreen)
                                .font(.system(size: 18, weight: .medium))
                            Text("Finish competitor research")
                                .foregroundColor(.insideTheGreen)
                                .font(.system(size: 17, weight: .bold))
                        }

                        Spacer()

                        Circle()
                            .stroke(Color.insideTheGreen, lineWidth: 2)
                            .frame(width: 22, height: 22)
                    }
                    .padding(25)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                        .fill(Color.greeen)
                        .frame(width: 380, height: 110)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )
                    .padding(.bottom, 30)

                    HStack(spacing: 5) {

                        VStack(alignment: .leading, spacing: 13) {
                            Text("Next Milestone")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)

                            Text("Licensing &Permits")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)

                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.fadedText)
                                    .font(.system(size: 22))
                                Text("12 days left")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundColor(.fadedText)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .frame(width: 200, height: 160)
                        )

                        VStack(spacing: 10) {
                            Text("Business Health")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            Image("smileFace")
                            Text("Good")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .frame(width: 150, height: 160)
                        )
                    }
                    .padding(.bottom, 25)
                    VStack(spacing:10){
                        Text("Quick Actions")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading,15)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)

                        HStack(spacing: 12) {
                            HStack(spacing: 0) {

                                NavigationLink(destination: IdeaEvaluationView()) {
                                    VStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.white)
                                            .frame(width: 160, height: 90)
                                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                            .overlay(
                                                Image("ideaEva")
                                            )
                                        Text("Idea Evaluation")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PlainButtonStyle())

                                NavigationLink(destination: RoadmapView()) {
                                    VStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.white)
                                            .frame(width: 160, height: 90)
                                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                            .overlay(
                                                Image("Roadmap")
                                            )
                                        Text("Roadmap")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        Rectangle()
                            .fill(Color.insideTheGreen)
                            .frame(height: 1)
                            .padding(.horizontal, 15)
                            .padding(.top, 10)
                            .shadow(color: Color.insideTheGreen, radius: 8, x: 0, y: 8)
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        projectDashBoard()
    }
}
