import Foundation

enum LLMError: Error {
    case parsingFailed
    case networkUnavailable
}

protocol LLMClient {
    func parseMealEntry(_ text: String) async throws -> MealEntry
    func suggestAdjustments(for dayContext: DayContext) async throws -> [Adjustment]
}

final class MockLLMClient: LLMClient {
    func parseMealEntry(_ text: String) async throws -> MealEntry {
        let lowered = text.lowercased()
        let timestamp = extractTimestamp(from: lowered) ?? Date()
        let description = text
        let macros = estimateMacros(from: lowered)
        return MealEntry(timestamp: timestamp, description: description, macros: macros)
    }

    func suggestAdjustments(for dayContext: DayContext) async throws -> [Adjustment] {
        guard
            let target = dayContext.targetMacros,
            let consumed = dayContext.consumedMacros
        else {
            return []
        }

        let calorieDelta = consumed.calories - target.calories
        if calorieDelta > 150 {
            return [
                Adjustment(message: "You’re \(Int(calorieDelta)) kcal over plan. Let’s ease dinner carbs and add a walk.", actions: [
                    "Swap dinner starch for greens",
                    "Add 10-minute walk post-meal"
                ])
            ]
        } else if calorieDelta < -150 {
            return [
                Adjustment(message: "Fuel is a bit low today. Add a light carb + protein snack.", actions: [
                    "Add yogurt with berries",
                    "Sip electrolytes if training felt heavy"
                ])
            ]
        }

        if dayContext.trainingLoad == .heavy && (consumed.carbohydrates < target.carbohydrates * 0.8) {
            return [
                Adjustment(message: "Heavy day detected but you’re light on carbs. Let’s bump pre-training fuel.", actions: [
                    "Add banana + honey before next session",
                    "Include electrolyte drink during training"
                ])
            ]
        }

        return []
    }

    private func estimateMacros(from text: String) -> Macros {
        if text.contains("pie") {
            return Macros(calories: 350, protein: 4, carbohydrates: 45, fat: 16)
        }
        if text.contains("shake") {
            return Macros(calories: 240, protein: 30, carbohydrates: 12, fat: 6)
        }
        if text.contains("salad") {
            return Macros(calories: 180, protein: 12, carbohydrates: 14, fat: 8)
        }
        return Macros(calories: 250, protein: 15, carbohydrates: 20, fat: 10)
    }

    private func extractTimestamp(from text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mma"

        if let range = text.range(of: #"\d{1,2}(:\d{2})?\s?(am|pm)"#, options: .regularExpression) {
            let timeString = text[range].replacingOccurrences(of: " ", with: "")
            return formatter.date(from: timeString.uppercased())
        }

        return nil
    }
}

final class OpenAIClient: LLMClient {
    private let session: URLSession
    private let apiKey: String
    private let baseURL: URL

    init(apiKey: String, baseURL: URL = URL(string: "https://api.openai.com/v1")!, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
    }

    func parseMealEntry(_ text: String) async throws -> MealEntry {
        // Stub implementation for local development.
        // Extend to call OpenAI responses once API wiring is ready.
        return try await MockLLMClient().parseMealEntry(text)
    }

    func suggestAdjustments(for dayContext: DayContext) async throws -> [Adjustment] {
        return try await MockLLMClient().suggestAdjustments(for: dayContext)
    }
}

