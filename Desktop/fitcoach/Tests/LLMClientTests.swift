import XCTest
@testable import ConversationalMacroCoach

final class LLMClientTests: XCTestCase {
    func testParseMealEntryDetectsPie() async throws {
        let client = MockLLMClient()
        let entry = try await client.parseMealEntry("Slice of pie at 9am")

        XCTAssertTrue(entry.description.lowercased().contains("pie"))
        XCTAssertEqual(Int(entry.macros?.calories ?? 0), 350)
    }

    func testSuggestsAdjustmentWhenOverCalories() async throws {
        let client = MockLLMClient()
        let context = DayContext(
            date: Date(),
            trainingLoad: .moderate,
            recoveryFlag: false,
            targetMacros: Macros(calories: 2000, protein: 140, carbohydrates: 220, fat: 70),
            consumedMacros: Macros(calories: 2300, protein: 120, carbohydrates: 260, fat: 80)
        )

        let adjustments = try await client.suggestAdjustments(for: context)
        XCTAssertFalse(adjustments.isEmpty)
        XCTAssertTrue(adjustments.first?.message.contains("over") ?? false)
    }
}

