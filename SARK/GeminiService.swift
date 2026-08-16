//
//  GeminiService.swift
//  SARK
//

import Foundation

struct IdeaEvaluationResult: Codable {
    let suggestedBusinessName: String
    let overallScore: Int
    let scoreFeedback: String
    let marketDemand: Int
    let feasibility: Int
    let competition: Int
    let riskLevel: Int
    let strengths: [String]
    let weaknesses: [String]
    let aiRecommendation: String

    init(
        suggestedBusinessName: String,
        overallScore: Int,
        scoreFeedback: String,
        marketDemand: Int,
        feasibility: Int,
        competition: Int,
        riskLevel: Int,
        strengths: [String],
        weaknesses: [String],
        aiRecommendation: String
    ) {
        self.suggestedBusinessName = suggestedBusinessName
        self.overallScore = overallScore
        self.scoreFeedback = scoreFeedback
        self.marketDemand = marketDemand
        self.feasibility = feasibility
        self.competition = competition
        self.riskLevel = riskLevel
        self.strengths = strengths
        self.weaknesses = weaknesses
        self.aiRecommendation = aiRecommendation
    }

    // Custom decode so businesses saved BEFORE `suggestedBusinessName` existed
    // still load instead of silently wiping out everything in BusinessStore.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        suggestedBusinessName = try container.decodeIfPresent(String.self, forKey: .suggestedBusinessName) ?? ""
        overallScore = try container.decode(Int.self, forKey: .overallScore)
        scoreFeedback = try container.decode(String.self, forKey: .scoreFeedback)
        marketDemand = try container.decode(Int.self, forKey: .marketDemand)
        feasibility = try container.decode(Int.self, forKey: .feasibility)
        competition = try container.decode(Int.self, forKey: .competition)
        riskLevel = try container.decode(Int.self, forKey: .riskLevel)
        strengths = try container.decode([String].self, forKey: .strengths)
        weaknesses = try container.decode([String].self, forKey: .weaknesses)
        aiRecommendation = try container.decode(String.self, forKey: .aiRecommendation)
    }
}

// Returned by generateBudget — kept separate from `Business` on purpose so
// GeminiService doesn't need to know about the Business/store types.
// CHANGE: أضفنا isBudgetSufficient/feasibilityNote — قبل كذا كان الـ AI
// يبني ميزانية "توهم" إنها كافية لأنه يضبط totalBudget ليطابق الرينج
// الي اختاره اليوزر بالضبط، حتى لو واقعيًا (حسب بيانات السوق الحقيقية)
// المبلغ مايكفي لفتح المشروع فعليًا — وهذا يناقض تحذير الايديا ايفالويشن
// نفسه. الحين الـ totalBudget يعكس التكلفة الواقعية، ولو تجاوزت ميزانية
// اليوزر نعرض تحذير صريح بدل ما نخفي المشكلة.
struct BudgetGenerationResult {
    let totalBudget: Double
    let expenses: [Expense]
    let isBudgetSufficient: Bool
    let feasibilityNote: String
    // CHANGE: رقم صريح للميزانية اللي حددها اليوزر (مو بس النص التوضيحي)
    // عشان نقدر نعرض رقم العجز الفعلي بالواجهة، مو بس جملة عامة.
    let statedBudget: Double
}

enum GeminiServiceError: LocalizedError {
    case invalidRequest
    case emptyContent
    case apiError(String)

    // CHANGE: لقينا إن الخطأ الحقيقي كان "429 RESOURCE_EXHAUSTED" (تجاوزنا
    // الحد المجاني لـ Gemini API — 20 طلب/دقيقة) مو خطأ بالنت ولا بالمفتاح.
    // هذا الفرق يخلي أي شاشة تعرض رسالة صحيحة بدل ما توهم اليوزر إن مشكلته
    // بالنت أو الـ API key وهو مو كذا.
    var isRateLimited: Bool {
        if case .apiError(let message) = self {
            return message.contains("429") || message.contains("RESOURCE_EXHAUSTED")
        }
        return false
    }

    // رسالة موحّدة تُستخدم بكل الشاشات (Idea Evaluation, Roadmap, Budget)
    // عشان اليوزر يفهم بالضبط وش صار بدل رسالة عامة مضللة.
    static func userFacingMessage(for error: Error, action: String) -> String {
        if let serviceError = error as? GeminiServiceError, serviceError.isRateLimited {
            return "You've made a lot of AI requests in a short time and hit Gemini's free-tier limit. Please wait about a minute, then try again."
        }
        return "Couldn't \(action). Check your internet connection and API key, then try again."
    }

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Could not build the request."
        case .emptyContent:
            return "The AI service returned no content."
        case .apiError(let message):
            return message
        }
    }
}

enum GeminiService {
    private static let model = "gemini-3.6-flash"
    private static let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent"

    // CHANGE: شخصية موحّدة تُستخدم بالثلاث نداءات (evaluate/roadmap/budget)
    // — بدل "business advisor AI" العامة، صار AI يتصرف كمخطط أعمال محترف
    // خبرة حقيقية، عشان المخرجات تكون واقعية ومحترفة مو عامة/سطحية.
    private static let plannerPersona = """
    You are a professional business planner with real, hands-on experience launching and advising small businesses in Saudi Arabia. You think like a careful human consultant, not a generic AI: specific, realistic, and grounded in how this exact type of business actually works in this exact city — never generic filler advice that could apply to any business.
    """

    // CHANGE: اليوزر لاحظ إن الايفالويشن يطلع بالعربي (متوافق مع لغة الفكرة)
    // بس البجت والرود ماب يطلعون بالإنجليزي دايمًا. هذا غير منطقي — لازم
    // كل مخرجات الـ AI (كل حقل نصي) تكون بنفس لغة الفكرة اللي كتبها اليوزر.
    private static func languageInstruction(for ideaText: String) -> String {
        """

        CRITICAL LANGUAGE RULE: Respond entirely in the same language the founder used to write the business idea below. If the idea is written in Arabic, EVERY text field in your JSON response (titles, descriptions, feedback, recommendations, resources, expense names, everything) must be in Arabic. If it's written in English, respond entirely in English. Never mix languages and never default to English just because the schema/instructions above are in English.
        """
    }

    static func evaluateIdea(
        ideaText: String,
        industry: String,
        location: String,
        budget: String,
        experience: String,
        goal: String,
        timeline: String,
        riskTolerance: String
    ) async throws -> IdeaEvaluationResult {

        let prompt = """
        \(plannerPersona)

        Evaluate the following business idea realistically and respond ONLY with a JSON object matching this exact schema, with no extra text before or after it:

        {
          "suggestedBusinessName": "<a short, clean, catchy business name (2-5 words) inferred from the idea — e.g. 'Lena's Coffee Shop', NOT a copy-paste of the raw idea text>",
          "overallScore": <Int 0-100>,
          "scoreFeedback": "<short one-sentence feedback>",
          "marketDemand": <Int 0-100>,
          "feasibility": <Int 0-100 — must honestly reflect real constraints below, not just market appeal>,
          "competition": <Int 0-100>,
          "riskLevel": <Int 0-100>,
          "strengths": ["<point 1>", "<point 2>", "<point 3>"],
          "weaknesses": ["<point 1>", "<point 2>", "<point 3>"],
          "aiRecommendation": "<2-3 sentence actionable recommendation>"
        }

        CRITICAL — REALISTIC FEASIBILITY: Don't just score the idea in the abstract. Actually think through what this specific business, in this specific city, genuinely requires to open (e.g. specific licenses/permits, minimum equipment, a location deposit, certifications) and compare that honestly against the founder's stated budget below. If the budget is realistically not enough to cover a real, specific requirement (for example: "a commercial registration + food handling permit alone would use most of this budget"), you MUST say so plainly — name the specific gap — inside "weaknesses" and reflect it by lowering "feasibility". Never hide a real budget shortfall just to sound encouraging; a good human advisor would always flag it directly.

        Business idea: \(ideaText)
        Industry: \(industry)
        City: \(location)
        Budget: \(budget)
        Founder experience: \(experience)
        Business goal: \(goal)
        Timeline: \(timeline)
        Risk tolerance: \(riskTolerance)
        """

        let fullPrompt = prompt + marketContextBlock(location: location, industry: industry) + languageInstruction(for: ideaText)
        let jsonData = try await requestJSON(prompt: fullPrompt)
        return try JSONDecoder().decode(IdeaEvaluationResult.self, from: jsonData)
    }

    // MARK: - Roadmap generation
    // Builds a roadmap tailored to the idea + the founder's chosen timeline.
    // The number of stages scales with the timeline the founder picked, and
    // every stage is explicitly labeled Month 1 / Month 2 / ... (or Week 1...
    // for a sub-1-month plan) so the roadmap visibly grows with the timeline.
    // The AI never sees or invents an `id` — every stage/objective gets a
    // fresh UUID locally once decoded, matching how RoadmapStage/StageObjective
    // are meant to be constructed in app code.
    static func generateRoadmap(
        ideaText: String,
        industry: String,
        location: String,
        timeline: String,
        goal: String
    ) async throws -> [RoadmapStage] {

        let (stageCount, spanDescription) = roadmapStageTarget(for: timeline)
        let iconList = allowedStageIcons.joined(separator: ", ")

        let prompt = """
        \(plannerPersona)

        Based on the business idea below, build a REAL, actionable roadmap the founder should follow — not a generic template. Respond ONLY with a JSON array matching this exact schema, with no extra text before or after it:

        [
          {
            "monthLabel": "<matching the timeframe below, e.g. 'Month 1' or 'Week 1', numbered sequentially>",
            "title": "<short stage title>",
            "iconName": "<MUST be exactly one of these values, copied verbatim — do not invent, modify, or use any icon outside this list: \(iconList)>",
            "description": "<1-2 sentence description of what this stage covers>",
            "priorityReason": "<short reason this stage is prioritized where it is>",
            "objectives": ["<one objective per realistic task>"],
            "resources": ["<a specific, useful resource/reference for this stage, e.g. a tool, portal, or type of professional to consult — 2 to 4 items>"]
          }
        ]

        Create EXACTLY \(stageCount) stages, one per timeframe unit, covering \(spanDescription). Order them logically from idea validation through to launch. The first stage should already be actionable today.

        CRITICAL — REAL, NOT GENERIC: Every objective must be something this exact founder actually, concretely needs to do to open THIS specific business in THIS specific city — not a generic startup checklist item that could apply to any business. Think like someone who has actually opened this type of business before: real permits/licenses this business type needs in this city, real supplier or sourcing steps, real equipment specific to this business, real staffing/hiring needs if relevant, real location/lease steps if relevant. If a generic step (e.g. "create a business plan") genuinely doesn't apply or isn't a priority for this specific idea, leave it out — do not pad the roadmap with filler just to fill space.

        For "objectives": decide the count yourself based on genuine complexity — analyze how much real work that specific stage actually requires. A simple stage might only need 2-3 objectives; a demanding, multi-part stage might need 7-10. Never default to a fixed number like 3 for every stage — pad nothing, skip nothing real.

        For "iconName": this app has a fixed icon design and must never deviate from it. Only ever use one of the exact icon names listed above, verbatim, with no substitutions.

        Business idea: \(ideaText)
        Industry: \(industry)
        City: \(location)
        Timeline: \(timeline)
        Business goal: \(goal)
        """

        let fullPrompt = prompt + marketContextBlock(location: location, industry: industry) + languageInstruction(for: ideaText)
        let jsonData = try await requestJSON(prompt: fullPrompt)

        struct RawStage: Decodable {
            let monthLabel: String
            let title: String
            let iconName: String
            let description: String
            let priorityReason: String
            let objectives: [String]
            let resources: [String]
        }

        let rawStages = try JSONDecoder().decode([RawStage].self, from: jsonData)

        guard !rawStages.isEmpty else { throw GeminiServiceError.emptyContent }

        return rawStages.enumerated().map { index, raw in
            let state: TimelineStepState = index == 0 ? .inProgress : .upcoming
            let subtitle = index == 0 ? "In progress - 0%" : "Upcoming"
            // CHANGE: نتأكد إن الأيقونة فعليًا من قائمتنا الثابتة، حتى لو
            // الـ AI ما التزم بالتعليمات — عشان التصميم يضل موحّد دايمًا.
            let icon = allowedStageIcons.contains(raw.iconName)
                ? raw.iconName
                : allowedStageIcons[index % allowedStageIcons.count]
            return RoadmapStage(
                title: raw.title,
                subtitle: subtitle,
                progressPercentage: 0,
                state: state,
                monthLabel: raw.monthLabel,
                iconName: icon,
                description: raw.description,
                priorityReason: raw.priorityReason,
                objectives: raw.objectives.map { StageObjective(title: $0, isCompleted: false) },
                resources: raw.resources
            )
        }
    }

    // Maps the timeline the founder picked in TellUsAboutYouView to how many
    // roadmap stages to generate — more months picked → a bigger roadmap.
    private static func roadmapStageTarget(for timeline: String) -> (count: Int, spanDescription: String) {
        switch timeline {
        case "Under 1 month":
            return (3, "roughly 1 month, broken into weekly milestones (Week 1, Week 2, Week 3)")
        case "1 - 3 months":
            return (3, "3 months, one stage per month (Month 1, Month 2, Month 3)")
        case "3 - 6 months":
            return (6, "6 months, one stage per month (Month 1 through Month 6)")
        case "6+ months":
            return (9, "9 months, one stage per month (Month 1 through Month 9)")
        default:
            return (5, "the founder's chosen timeline, one stage per month")
        }
    }

    // Fixed, curated icon set for roadmap stages — matches the app's existing
    // icon style (all SF Symbols, filled weight). The AI must choose only
    // from this list so every roadmap looks consistent with our design,
    // instead of inventing its own icons stage to stage.
    private static let allowedStageIcons: [String] = [
        "lightbulb.fill", "magnifyingglass", "wallet.pass.fill", "archivebox.fill",
        "hammer.fill", "megaphone.fill", "shippingbox.fill", "rocket.fill",
        "doc.text.fill", "checkmark.seal.fill", "building.2.fill", "chart.bar.fill",
        "cart.fill", "person.3.fill", "target"
    ]

    // MARK: - Budget generation
    // Builds a realistic startup budget from the idea + the budget range the
    // founder picked in TellUsAboutYouView.
    static func generateBudget(
        ideaText: String,
        industry: String,
        location: String,
        budgetRange: String
    ) async throws -> BudgetGenerationResult {

        let prompt = """
        \(plannerPersona)

        Based on the business idea below, work out what it would REALISTICALLY cost to actually launch it — grounded in the real market/cost data provided below when available — and build a startup budget breakdown. Respond ONLY with a JSON object matching this exact schema, with no extra text before or after it:

        {
          "totalBudget": <Number, the REALISTIC total in SAR this business would actually need to launch — do NOT just copy the founder's stated budget range>,
          "founderStatedBudgetAmount": <Number in SAR — your best plain-number reading of the founder's stated budget range below; for an open-ended range like "50,000 SAR+" use 50000, otherwise use the upper bound of the range they picked>,
          "isBudgetSufficient": <true or false — true only if founderStatedBudgetAmount can realistically cover totalBudget>,
          "feasibilityNote": "<if isBudgetSufficient is false, ONE short honest sentence explaining the realistic gap (e.g. 'Realistic launch costs for this type of business in this city run closer to SAR 45,000 — consider starting smaller or raising more capital.'). If isBudgetSufficient is true, an empty string.>",
          "expenses": [
            {
              "title": "<expense title>",
              "category": "<one of these exact English words, unchanged regardless of response language — an internal code used for icon logic, never shown to the user as-is: Design, Marketing, Supplies, Development, Legal, Equipment, Other>",
              "categoryLabel": "<the same category, but as a short label written in the response language (matching the idea's language) — this IS shown to the user, e.g. category 'Design' with an Arabic idea → categoryLabel 'تصميم'>",
              "amount": <Number in SAR>
            }
          ]
        }

        Create between 4 and 8 realistic starting expenses a founder in this industry would actually need, with amounts that together add up to totalBudget.

        CRITICAL — ONE THING PER EXPENSE: Each expense must be a SINGLE, atomic, distinct cost item with its own short, specific title (e.g. "Shop Rent Deposit", "POS System", "3-Month Staff Visas"). NEVER bundle multiple unrelated costs into one expense with a combined title like "Rent, Marketing & Staff Visas" or "Branding, POS Hardware & Pre-Launch Marketing" — split each of those into its own separate expense entry instead, even if that means going slightly above 8 items. A human reading the title should immediately know it's exactly one thing, not a list.

        CRITICAL: Do not artificially shrink totalBudget or the expenses to fit inside the founder's stated budget range just to make it look feasible. Estimate the real cost first, from the actual idea, location, and the market data below. Only after that, compare it honestly against what the founder said they have — and flag it via isBudgetSufficient/feasibilityNote if there's a real gap, exactly like how a careful human advisor would never pretend an unrealistic budget is fine.

        IMPORTANT: "totalBudget" and every "amount" MUST be plain numbers (e.g. 5000), never text, never with "SAR", currency symbols, or thousands separators — even though the real market data below is shown with "SAR" for readability, do not copy that formatting into the numeric fields.

        Business idea: \(ideaText)
        Industry: \(industry)
        City: \(location)
        Founder's stated budget range: \(budgetRange)
        """

        let fullPrompt = prompt + marketContextBlock(location: location, industry: industry) + languageInstruction(for: ideaText)
        let jsonData = try await requestJSON(prompt: fullPrompt)

        // CHANGE: بعض المرات الـ AI يرجع الأرقام كنص فيه "SAR" أو فواصل
        // (مثلاً "SAR 5,000" بدل 5000) — خصوصًا بعد ما ضفنا بيانات السوق
        // الحقيقية بصيغة نصية بالبرومبت، فصار يقلّد نفس الصيغة أحيانًا.
        // قبل كذا كان الديكود يفشل بصمت ويطلع "Couldn't build your budget"
        // حتى لو النت والـ API key تمام. هذا الـ decoder يقبل رقم أو نص.
        struct FlexibleDouble: Decodable {
            let value: Double
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let d = try? container.decode(Double.self) {
                    value = d
                } else if let s = try? container.decode(String.self) {
                    let cleaned = s.filter { $0.isNumber || $0 == "." }
                    value = Double(cleaned) ?? 0
                } else {
                    value = 0
                }
            }
        }
        struct RawExpense: Decodable {
            let title: String
            let category: String
            let amount: FlexibleDouble
            // CHANGE: نخلي "category" كود إنجليزي ثابت داخلي (مسؤول عن اختيار
            // الأيقونة)، و"categoryLabel" هو الي فعليًا يتعرض لليوزر بنفس
            // لغة الفكرة — عشان ما تصير شاشة المصاريف عربي وفجأة كلمة
            // إنجليزية وسطها.
            let categoryLabel: String?
        }
        struct RawBudget: Decodable {
            let totalBudget: FlexibleDouble
            let expenses: [RawExpense]
            let founderStatedBudgetAmount: FlexibleDouble?
            let isBudgetSufficient: Bool?
            let feasibilityNote: String?
        }

        let raw: RawBudget
        do {
            raw = try JSONDecoder().decode(RawBudget.self, from: jsonData)
        } catch {
            // CHANGE: نطبع سبب الفشل الحقيقي بالكونسول عشان نقدر نشخصه بدل
            // ما يضيع برسالة عامة بالواجهة فقط.
            print("generateBudget decode failed: \(error)")
            if let raw = String(data: jsonData, encoding: .utf8) {
                print("generateBudget raw response: \(raw)")
            }
            throw error
        }
        guard !raw.expenses.isEmpty else { throw GeminiServiceError.emptyContent }

        func assetName(for category: String) -> String {
            switch category {
            case "Design": return "PaintBrush"
            case "Marketing": return "speakers"
            case "Supplies": return "World"
            case "Development": return "Box"
            case "Legal": return "World"
            case "Equipment": return "Box"
            default: return "Box"
            }
        }

        let expenses = raw.expenses.map { raw -> Expense in
            let displayCategory = (raw.categoryLabel?.isEmpty == false) ? raw.categoryLabel! : raw.category
            return Expense(
                title: raw.title,
                category: displayCategory,
                date: "Planned",
                amount: raw.amount.value,
                status: "Planned",
                assetName: assetName(for: raw.category)
            )
        }

        return BudgetGenerationResult(
            totalBudget: raw.totalBudget.value,
            expenses: expenses,
            isBudgetSufficient: raw.isBudgetSufficient ?? true,
            feasibilityNote: raw.feasibilityNote ?? "",
            statedBudget: raw.founderStatedBudgetAmount?.value ?? raw.totalBudget.value
        )
    }

    // MARK: - Real-data grounding
    // Appended to every prompt so the AI anchors its numbers in the actual
    // MarketData.json dataset for the founder's city, instead of relying
    // purely on its own general knowledge. Returns an empty string (no-op)
    // when there's no data for that city/industry combo.
    private static func marketContextBlock(location: String, industry: String) -> String {
        guard let summary = MarketDataService.contextSummary(city: location, industry: industry) else {
            return ""
        }
        return """


        \(summary)

        Use the real data above to ground your numbers (costs, budgets, ROI expectations) whenever it's relevant, instead of relying purely on general knowledge — while still tailoring the specifics to the founder's exact idea.
        """
    }

    // MARK: - Shared networking helper
    private static func requestJSON(prompt: String) async throws -> Data {
        guard var components = URLComponents(string: baseURL) else {
            throw GeminiServiceError.invalidRequest
        }
        components.queryItems = [URLQueryItem(name: "key", value: Secrets.geminiAPIKey)]

        guard let url = components.url else {
            throw GeminiServiceError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "responseMimeType": "application/json"
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiServiceError.apiError("HTTP \(httpResponse.statusCode): \(message)")
        }

        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable { let text: String? }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]?
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let text = decoded.candidates?.first?.content.parts.first?.text,
              let jsonData = text.data(using: .utf8) else {
            throw GeminiServiceError.emptyContent
        }

        return jsonData
    }
}
