//
//  TrendTipView.swift
//  SARK
//
//  CHANGE: شاشة "Trend Insight" اللي تبدلت مكان "Business Health" —
//  نصيحة قصيرة مبنية على ترندات السوشيال ميديا (تيك توك/إكس) تخص مجال
//  المشروع بالتحديد، مع تصميم أكثر فخامة بدل النص العادي، وتتجدد تلقائيًا
//  كل فترة عشان تحس إنها فعليًا "حيّة" مو جملة ثابتة.
//

import SwiftUI

struct TrendTipView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = BusinessStore.shared
    let businessID: UUID

    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private var businessIndex: Int? { store.index(of: businessID) }
    private var business: Business? {
        guard let idx = businessIndex else { return nil }
        return store.businesses[idx]
    }

    private var isLeverage: Bool { (business?.trendTip?.stance ?? "leverage") != "avoid" }
    private var accentColor: Color { isLeverage ? Color("appGreen") : Color("appOrange") }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    if isLoading {
                        loadingState
                    } else if let errorMessage {
                        errorState(errorMessage)
                    } else if let tip = business?.trendTip {
                        content(tip)
                    }

                    Spacer(minLength: 80)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadTip(forceReload: business?.trendTipIsStale ?? true)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("priemary text"))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color("boxes")))
            }
            Spacer()
            Text("Trend Insight")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color("priemary text"))
            Spacer()
            Button(action: {
                Task { await loadTip(forceReload: true) }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("priemary text"))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color("boxes")))
            }
            .disabled(isLoading)
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    // MARK: - Loading / Error
    private var loadingState: some View {
        VStack(spacing: 14) {
            Spacer(minLength: 120)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("appGreen")))
                .scaleEffect(1.3)
            Text("Scanning what's trending for your business...")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color("faded text"))
            Spacer(minLength: 120)
        }
        .frame(maxWidth: .infinity)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 60)
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(Color("appOrange"))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color("faded text"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button(action: { Task { await loadTip(forceReload: true) } }) {
                Text("Try Again")
            }
            .buttonStyle(PrimaryAppButtonStyle())
            .frame(maxWidth: 200)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Content
    private func content(_ tip: TrendTip) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            // Hero gradient card — the headline trend, big and bold.
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [accentColor, accentColor.opacity(0.65)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: isLeverage ? "flame.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 110))
                    .foregroundColor(.white.opacity(0.14))
                    .rotationEffect(.degrees(-12))
                    .offset(x: 90, y: -10)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: isLeverage ? "arrow.up.right.circle.fill" : "exclamationmark.circle.fill")
                            .font(.system(size: 13))
                        Text(isLeverage ? "TREND TO LEVERAGE" : "TREND TO AVOID")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(20)

                    Text(tip.trendTitle)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                }
                .padding(20)
            }
            .frame(height: 170)
            .cornerRadius(24)
            .shadow(color: accentColor.opacity(0.35), radius: 16, x: 0, y: 10)
            .padding(.horizontal)

            // "What's happening" card
            infoCard(
                icon: "sparkles",
                label: "What's happening",
                text: tip.insight,
                textColor: Color("priemary text"),
                fill: Color("boxes")
            )
            .padding(.horizontal)

            // "What to do" card — action-emphasized
            infoCard(
                icon: isLeverage ? "checkmark.seal.fill" : "hand.raised.fill",
                label: "What to do",
                text: tip.recommendation,
                textColor: accentColor,
                fill: accentColor.opacity(0.1),
                textWeight: .bold
            )
            .padding(.horizontal)

            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                Text("Based on general trend patterns the AI knows for your idea — not a live pull from TikTok/X.")
                    .font(.system(size: 11))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(Color("faded text"))
            .padding(.horizontal)
        }
        .padding(.top, 10)
    }

    private func infoCard(
        icon: String,
        label: String,
        text: String,
        textColor: Color,
        fill: Color,
        textWeight: Font.Weight = .regular
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(label.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .tracking(0.6)
            }
            .foregroundColor(Color("faded text"))

            Text(text)
                .font(.system(size: 15, weight: textWeight))
                .foregroundColor(textColor)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(fill)
        .cornerRadius(18)
    }

    // MARK: - Load
    private func loadTip(forceReload: Bool = false) async {
        guard let idx = businessIndex else { return }
        guard forceReload || store.businesses[idx].trendTip == nil else { return }

        isLoading = true
        errorMessage = nil
        do {
            let tip = try await GeminiService.generateTrendTip(
                ideaText: store.businesses[idx].ideaText,
                industry: store.businesses[idx].industry,
                location: store.businesses[idx].location
            )
            store.businesses[idx].trendTip = tip
            store.businesses[idx].trendTipGeneratedAt = Date()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = GeminiServiceError.userFacingMessage(for: error, action: "get today's trend insight")
        }
    }
}

#Preview {
    NavigationStack {
        TrendTipView(businessID: UUID())
    }
}
