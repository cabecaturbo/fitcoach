import Foundation

@MainActor
final class UserProfileStore: ObservableObject {
    @Published private(set) var profile: UserProfile?
    private let storage: StorageProviding
    private let planEngine: PlanEngine

    init(storage: StorageProviding, planEngine: PlanEngine = PlanEngine()) {
        self.storage = storage
        self.planEngine = planEngine
        self.profile = storage.fetchUserProfile()
    }

    func apply(payload: OnboardingPayload) {
        var current = profile ?? UserProfile()

        if let dexa = payload.answers[20], !dexa.isEmpty {
            current.bodyComposition.leanMassKg = parseLeanMass(from: dexa)
        }

        if let trainingLoadAnswer = payload.answers[27] {
            current.training.load = trainingLoad(from: trainingLoadAnswer)
        }

        if let supplementsList = payload.answers[24], !supplementsList.isEmpty {
            current.health.supplements = supplementsList
                .split(separator: ",")
                .map { Supplement(name: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        }

        if let highFuelDays = payload.answers[28], !highFuelDays.isEmpty {
            current.training.highFuelDays = parseDays(from: highFuelDays)
        }

        if let performance = payload.answers[29] {
            current.training.performanceGoals = parsePerformanceGoals(from: performance)
        }

        if let recovery = payload.answers[30], !recovery.isEmpty {
            current.training.recoveryPractices = recovery.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }

        if let basics = payload.answers[21] {
            current.bodyComposition = updateBodyComposition(current.bodyComposition, from: basics)
        }

        if let desserts = payload.answers[7] {
            current.dessertCadence = desserts
        }

        if let dessertTypes = payload.answers[8] {
            current.groceryStaples.append("Dessert: \(dessertTypes)")
        }

        if let mealCount = payload.answers[2], let approximate = Int(mealCount.filter(\.isNumber)) {
            current.mealCadence = approximate
        }

        let tastes = [4, 9, 10, 11].compactMap { payload.answers[$0] }
        current.tastePreferences = tastes.flatMap { $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }

        let avoidances = [5, 12].compactMap { payload.answers[$0] }
        current.avoidances = avoidances.flatMap { $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }

        if let staples = payload.answers[18] {
            current.groceryStaples = staples
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }

        if let injuries = payload.answers[25] {
            current.health.injuries = injuries
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }

        if let conditions = payload.answers[26] {
            current.health.conditions = conditions
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }

        if let goals = payload.answers[22] {
            current.goals = parseGoals(from: goals)
        }

        profile = current
        storage.saveUserProfile(current)

        let plan = planEngine.generatePlan(for: current)
        storage.savePlan(plan)
    }

    func refreshPlanIfNeeded() {
        guard let profile else { return }
        let plan = planEngine.generatePlan(for: profile)
        storage.savePlan(plan)
    }

    private func trainingLoad(from answer: String) -> TrainingLoad {
        let lower = answer.lowercased()
        if lower.contains("heavy") {
            return .heavy
        } else if lower.contains("light") {
            return .light
        } else if lower.contains("variable") {
            return .variable
        }
        return .moderate
    }

    private func parseDays(from answer: String) -> [Weekday] {
        let components = answer.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        return Weekday.allCases.filter { components.contains($0.rawValue) }
    }

    private func parsePerformanceGoals(from answer: String) -> [PerformanceGoal] {
        let lower = answer.lowercased()
        return PerformanceGoal.allCases.filter { lower.contains($0.rawValue) }
    }

    private func parseGoals(from answer: String) -> [NutritionGoal] {
        let lower = answer.lowercased()
        return NutritionGoal.allCases.filter { lower.contains($0.rawValue) }
    }

    private func parseLeanMass(from answer: String) -> Double? {
        let numbers = answer
            .split(whereSeparator: { !$0.isNumber && $0 != "." })
            .compactMap { Double($0) }
        return numbers.first
    }

    private func updateBodyComposition(_ composition: BodyComposition, from answer: String) -> BodyComposition {
        var updated = composition
        let components = answer.lowercased()

        if let weight = extractValue(from: components, keywords: ["kg", "lb", "lbs"]) {
            updated.weightKg = convertToKg(value: weight.value, unit: weight.unit)
        }

        if let height = extractValue(from: components, keywords: ["cm", "m", "ft", "in"]) {
            updated.heightCm = convertToCm(value: height.value, unit: height.unit)
        }

        if let bodyFat = extractValue(from: components, keywords: ["%", "percent"]) {
            updated.bodyFatPercentage = bodyFat.value
        }

        return updated
    }

    private func extractValue(from input: String, keywords: [String]) -> (value: Double, unit: String)? {
        for keyword in keywords {
            if let range = input.range(of: keyword) {
                let prefix = input[..<range.lowerBound]
                let valueString = prefix.split(separator: " ").last ?? ""
                if let value = Double(valueString.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) {
                    return (value, keyword)
                }
            }
        }
        return nil
    }

    private func convertToKg(value: Double, unit: String) -> Double {
        if unit.contains("lb") {
            return value * 0.453592
        }
        return value
    }

    private func convertToCm(value: Double, unit: String) -> Double {
        if unit == "m" {
            return value * 100
        }
        if unit == "ft" {
            return value * 30.48
        }
        if unit == "in" {
            return value * 2.54
        }
        return value
    }
}

