import XCTest
@testable import ConversationalMacroCoach

final class PlanEngineTests: XCTestCase {
    func testMacroTemplatesIncludeTrainingAndRest() throws {
        let profile = UserProfile(
            bodyComposition: BodyComposition(weightKg: 80, heightCm: 180, bodyFatPercentage: 18, leanMassKg: 65, biologicalSex: .male, ageYears: 32),
            goals: [.performance],
            health: HealthProfile(),
            training: TrainingProfile(load: .heavy, highFuelDays: [.monday], performanceGoals: [.strength], recoveryPractices: ["Sleep tracking"]),
            tastePreferences: ["Chicken", "Rice"],
            avoidances: ["Shellfish"],
            groceryStaples: ["Rice", "Greek yogurt"]
        )

        let engine = PlanEngine()
        let plan = engine.generatePlan(for: profile)

        XCTAssertGreaterThanOrEqual(plan.templates.count, 2)
        XCTAssertNotNil(plan.templates.first(where: { $0.type == .training }))
        XCTAssertNotNil(plan.templates.first(where: { $0.type == .rest }))
    }

    func testCarbBiasForHeavyLoad() throws {
        let profile = UserProfile(
            bodyComposition: BodyComposition(weightKg: 70, heightCm: 172, bodyFatPercentage: 20, leanMassKg: 56, biologicalSex: .female, ageYears: 29),
            goals: [.maintenance],
            health: HealthProfile(conditions: ["thyroid"]),
            training: TrainingProfile(load: .heavy, performanceGoals: [.endurance]),
            tastePreferences: ["Oats"],
            avoidances: ["Fried foods"],
            groceryStaples: ["Oats", "Bananas"]
        )

        let engine = PlanEngine()
        let plan = engine.generatePlan(for: profile)

        guard let training = plan.templates.first(where: { $0.type == .training }) else {
            XCTFail("Missing training template")
            return
        }

        XCTAssertGreaterThan(training.macros.carbohydrates, training.macros.fat * 2)
    }
}

