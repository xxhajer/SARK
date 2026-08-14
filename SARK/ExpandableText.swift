//
//  ExpandableText.swift
//  SARK
//
//  مكون قابل لإعادة الاستخدام: بدل ما نقص النص تلقائيًا بثلاث نقط (...)
//  اللي ما توضح لليوزر إن فيه كلام ناقص أو وين يشوفه، هذا المكون يعرض
//  النص كامل إذا كان يناسب المساحة، وإذا كان طويل فعلاً يقصه عند آخر
//  كلمة كاملة ويحط زر "More" واضح — يضغطه اليوزر ويشوف الباقي كامل.
//

import SwiftUI

struct ExpandableText: View {
    let text: String
    var collapsedLimit: Int = 60
    var font: Font = .system(size: 15)
    var color: Color = .primary
    var alignment: TextAlignment = .leading
    // CHANGE: زر "More" لون افتراضي أخضر، بس نخليه قابل للتخصيص عشان
    // يبين واضح لو الكرت خلفيته خضراء أصلاً (زي كرت Today's Goal).
    var linkColor: Color = Color("appGreen")

    @State private var isExpanded = false

    private var needsTruncation: Bool {
        text.count > collapsedLimit
    }

    private var collapsedText: String {
        guard needsTruncation else { return text }
        let cutIndex = text.index(text.startIndex, offsetBy: collapsedLimit)
        let truncated = String(text[..<cutIndex])
        // نقص عند آخر مسافة كاملة عشان ما نقطع كلمة نص نص.
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[..<lastSpace])
        }
        return truncated
    }

    var body: some View {
        VStack(alignment: alignment == .center ? .center : .leading, spacing: 4) {
            Text(isExpanded || !needsTruncation ? text : collapsedText)
                .font(font)
                .foregroundColor(color)
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)

            if needsTruncation {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Show less" : "More")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(linkColor)
                }
            }
        }
    }
}
