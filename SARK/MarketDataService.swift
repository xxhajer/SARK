//
//  MarketDataService.swift
//  SARK
//
//  Loads MarketData.json — a real, cleaned dataset of property prices and
//  construction/operating costs for Riyadh, Dammam, and Jeddah — bundled
//  with the app, and turns it into a short factual text block that gets
//  injected into Gemini prompts. This grounds the AI's numbers (budget,
//  ROI expectations, evaluation) in actual regional data instead of the
//  model inventing figures purely from general knowledge.
//

import Foundation

struct CityMarketStats: Codable {
    let year: String
    let sampleSize: Int
    let Price_Per_Sqm: Double?
    let Total_Project_Cost: Double?
    let Permit_Cost: Double?
    let Annual_Operating_Cost: Double?
    let Annual_Maintenance_Cost: Double?
    let Estimated_Annual_Revenue: Double?
    let ROI_Percentage: Double?
    let Construction_Cost: Double?
    let Labor_Cost: Double?
    let Material_Cost: Double?
}

struct CityMarketData: Codable {
    let byPropertyType: [String: CityMarketStats]
    let overall: CityMarketStats?
}

struct MarketDataset: Codable {
    let sourceFile: String
    let note: String
    let cities: [String: CityMarketData]
}

enum MarketDataService {
    // Loaded once from the bundled MarketData.json. nil if the file is
    // missing/unreadable — callers treat that as "no grounding data available"
    // and the app falls back to the AI's general knowledge, same as before.
    static let dataset: MarketDataset? = {
        guard let url = Bundle.main.url(forResource: "MarketData", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(MarketDataset.self, from: data)
    }()

    // Maps the app's industry picker values to the closest property types
    // that exist in the real dataset (which is organized by real-estate
    // property type, not by business industry).
    private static func propertyTypes(for industry: String) -> [String] {
        switch industry {
        case "Food & Beverage":
            return ["Shop", "Commercial_Center", "Facility"]
        case "Retail":
            return ["Shop", "Commercial_Center", "Building"]
        default:
            return ["Shop", "Commercial_Center"]
        }
    }

    // Builds a short, factual block to append to a Gemini prompt so the AI
    // grounds its numbers in this real dataset. Returns nil if the city
    // isn't one we have data for (e.g. "Not decided yet" or empty).
    static func contextSummary(city: String, industry: String) -> String? {
        guard let dataset, let cityData = dataset.cities[city] else { return nil }

        var lines: [String] = []
        let matchedTypes = propertyTypes(for: industry).compactMap { type -> String? in
            guard let stats = cityData.byPropertyType[type] else { return nil }
            return formatLine(label: type.replacingOccurrences(of: "_", with: " "), stats: stats)
        }

        if !matchedTypes.isEmpty {
            lines.append(contentsOf: matchedTypes)
        } else if let overall = cityData.overall {
            lines.append(formatLine(label: "Overall market", stats: overall))
        }

        guard !lines.isEmpty else { return nil }

        return """
        Real market/cost data for \(city), Saudi Arabia (source: cleaned local dataset):
        \(lines.joined(separator: "\n"))
        """
    }

    private static func formatLine(label: String, stats: CityMarketStats) -> String {
        var parts: [String] = []
        if let v = stats.Price_Per_Sqm { parts.append("avg price/sqm ≈ SAR \(Int(v))") }
        if let v = stats.Total_Project_Cost { parts.append("avg total project cost ≈ SAR \(Int(v))") }
        if let v = stats.Permit_Cost { parts.append("avg permit cost ≈ SAR \(Int(v))") }
        if let v = stats.Annual_Operating_Cost { parts.append("avg annual operating cost ≈ SAR \(Int(v))") }
        if let v = stats.Estimated_Annual_Revenue { parts.append("avg estimated annual revenue ≈ SAR \(Int(v))") }
        if let v = stats.ROI_Percentage { parts.append("avg ROI ≈ \(Int(v * 100))%") }
        let detail = parts.joined(separator: ", ")
        return "- \(label) (\(stats.year) data, n=\(stats.sampleSize)): \(detail)"
    }
}
