import Foundation

struct PlanContext {
    let profile: UserProfile
    let now: Date
}

struct PlanEngine {
    private struct GoalAdjustment {
        let goal: NutritionGoal
        let multiplier: Double
    }

    private let goalAdjustments: [GoalAdjustment] = [
        GoalAdjustment(goal: .loss, multiplier: 0.85),
        GoalAdjustment(goal: .gain, multiplier: 1.12),
        GoalAdjustment(goal: .performance, multiplier: 1.05),
        GoalAdjustment(goal: .energy, multiplier: 1.0),
        GoalAdjustment(goal: .convenience, multiplier: 1.0),
        GoalAdjustment(goal: .other, multiplier: 1.0),
        GoalAdjustment(goal: .maintenance, multiplier: 1.0)
    ]

    func generatePlan(for profile: UserProfile, on date: Date = Date()) -> Plan {
        let context = PlanContext(profile: profile, now: date)
        let maintenanceCalories = estimateTDEE(for: profile)
        let adjustedCalories = applyGoalMultipliers(calories: maintenanceCalories, goals: profile.goals)
        let templates = buildTemplates(calories: adjustedCalories, context: context)
        let days = buildSampleDays(templates: templates, context: context)
        let groceries = buildGroceryList(for: context, templates: templates)

        return Plan(
            createdAt: date,
            updatedAt: date,
            templates: templates,
            dailyPlans: days,
            groceryList: groceries
        )
    }

    func estimateTDEE(for profile: UserProfile) -> Double {
        let body = profile.bodyComposition
        let weightKg = body.weightKg ?? 75
        let heightCm = body.heightCm ?? 175
        let age = body.ageYears ?? 32
        let sexCoefficient: Double = {
            switch body.biologicalSex {
            case .male:
                return 5
            case .female:
                return -161
            case .other, .none:
                return -78 // midpoint
            }
        }()

        let bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + sexCoefficient
        let loadMultiplier = activityMultiplier(for: profile.training.load)
        return bmr * loadMultiplier
    }

    private func activityMultiplier(for load: TrainingLoad) -> Double {
        switch load {
        case .light:
            return 1.3
        case .moderate:
            return 1.45
        case .heavy:
            return 1.6
        case .variable:
            return 1.5
        }
    }

    private func applyGoalMultipliers(calories: Double, goals: [NutritionGoal]) -> Double {
        guard !goals.isEmpty else { return calories }
        let multipliers = goals.compactMap { goalAdjustments.first(where: { $0.goal == goal })?.multiplier }
        guard !multipliers.isEmpty else { return calories }
        let averageMultiplier = multipliers.reduce(0, +) / Double(multipliers.count)
        return calories * averageMultiplier
    }

    private func proteinTargetKg(for profile: UserProfile) -> Double {
        let weightKg = profile.bodyComposition.weightKg ?? 75

        // Lower protein floor if kidney or renal issues are reported.
        let lowerRange: Double = profile.health.conditions.contains { $0.localizedCaseInsensitiveContains("kidney") || $0.localizedCaseInsensitiveContains("renal") } ? 1.4 : 1.6
        let upperRange: Double = 2.2

        let base = max(lowerRange * weightKg, lowerRange * 50)
        let maxTarget = upperRange * weightKg
        return min(max(base, lowerRange * weightKg), maxTarget)
    }

    private func macroSplit(for context: PlanContext) -> (carbRatio: Double, fatRatio: Double) {
        let training = context.profile.training
        let prioritisesEndurance = training.performanceGoals.contains(.endurance)
        let heavyLoad = training.load == .heavy

        if heavyLoad || prioritisesEndurance {
            return (carbRatio: 0.55, fatRatio: 0.25)
        }

        if training.performanceGoals.contains(.strength) {
            return (carbRatio: 0.5, fatRatio: 0.27)
        }

        if training.load == .light {
            return (carbRatio: 0.45, fatRatio: 0.3)
        }

        return (carbRatio: 0.48, fatRatio: 0.27)
    }

    private func buildTemplates(calories: Double, context: PlanContext) -> [MacroTemplate] {
        let proteinGrams = proteinTargetKg(for: context.profile)
        let split = macroSplit(for: context)

        func template(named name: String, type: MacroTemplate.TemplateType, multiplier: Double, notes: [String]) -> MacroTemplate {
            let adjustedCalories = calories * multiplier
            let macros = macrosFrom(calories: adjustedCalories, protein: proteinGrams, carbRatio: split.carbRatio, fatRatio: split.fatRatio)
            return MacroTemplate(name: name, type: type, macros: macros, notes: notes)
        }

        var notes: [String] = []
        if context.profile.training.load == .heavy {
            notes.append("Higher carbs to cover heavy training days.")
        }
        if context.profile.training.recoveryPractices.contains(where: { $0.localizedCaseInsensitiveContains("sleep") }) {
            notes.append("Encourage evening protein + magnesium-friendly choices for recovery.")
        }

        let baseTraining = template(named: "Training Day", type: .training, multiplier: 1.08, notes: notes + ["Add pre/intra carbs around key sessions."])
        let rest = template(named: "Rest Day", type: .rest, multiplier: 0.92, notes: ["Dial carbs down, keep protein steady."])

        var templates: [MacroTemplate] = [baseTraining, rest]

        if context.profile.training.load == .variable {
            let high = template(named: "High Output", type: .high, multiplier: 1.15, notes: ["Use on long or double-session days."])
            let low = template(named: "Low Output", type: .low, multiplier: 0.85, notes: ["Use for active recovery or off days."])
            templates.append(contentsOf: [high, low])
        }

        return templates
    }

    private func macrosFrom(calories: Double, protein: Double, carbRatio: Double, fatRatio: Double) -> Macros {
        let proteinCalories = protein * 4
        let remainingCalories = max(calories - proteinCalories, calories * 0.4)
        let carbCalories = remainingCalories * carbRatio
        let fatCalories = remainingCalories * fatRatio

        let carbs = carbCalories / 4
        let fats = fatCalories / 9

        return Macros(
            calories: round(calories),
            protein: round(protein),
            carbohydrates: round(carbs),
            fat: round(fats)
        )
    }

    private func buildSampleDays(templates: [MacroTemplate], context: PlanContext) -> [DailyPlan] {
        let staples = context.profile.groceryStaples
        let favorites = context.profile.tastePreferences
        let dessert = context.profile.dessertCadence

        func meals(for template: MacroTemplate) -> [Meal] {
            let labels = ["Breakfast", "Lunch", "Dinner", "Snacks"]
            let macros = template.macros

            return labels.enumerated().map { index, label in
                let ratio: Double
                switch index {
                case 0: ratio = 0.25
                case 1: ratio = 0.30
                case 2: ratio = 0.30
                default: ratio = 0.15
                }

                let mealMacros = Macros(
                    calories: round(macros.calories * ratio),
                    protein: round(macros.protein * ratio),
                    carbohydrates: round(macros.carbohydrates * ratio),
                    fat: round(macros.fat * ratio)
                )

                var items: [String] = []
                if let favorite = favorites.first {
                    items.append(favorite)
                }
                if let staple = staples.first {
                    items.append(staple)
                }
                if index == 3, let dessert {
                    items.append("Treat: \(dessert)")
                }
                if items.isEmpty {
                    items = ["Coach-suggested option"]
                }

                return Meal(name: label, items: items, macros: mealMacros)
            }
        }

        return templates.map { template in
            DailyPlan(label: template.name, template: template, meals: meals(for: template))
        }
    }

    private func buildGroceryList(for context: PlanContext, templates: [MacroTemplate]) -> GroceryList {
        var pantryItems: [GroceryItem] = context.profile.groceryStaples.map {
            GroceryItem(name: $0, aisle: "Pantry", storage: .pantry)
        }

        let dessertItems: [GroceryItem] = {
            guard let dessert = context.profile.dessertCadence, !dessert.isEmpty else { return [] }
            return [
                GroceryItem(name: dessert, aisle: "Treats", storage: .fresh, notes: "Keep dessert cadence aligned with goals.")
            ]
        }()

        if pantryItems.isEmpty {
            pantryItems = [
                GroceryItem(name: "Steel-cut oats", aisle: "Grains", storage: .pantry),
                GroceryItem(name: "Greek yogurt", aisle: "Dairy", storage: .refrigerated)
            ]
        }

        let hydrationItems: [GroceryItem] = {
            if context.profile.training.load == .heavy {
                return [GroceryItem(name: "Electrolyte mix", aisle: "Supplements", storage: .pantry, notes: "Support recovery and heavy days.")]
            }
            return []
        }()

        let proteinSupportNotes = context.profile.health.supplements.map { "Contains \($0.name)" }

        let proteinItems: [GroceryItem] = [
            GroceryItem(name: favoritesProtein(from: context.profile), aisle: "Protein", storage: .refrigerated, notes: proteinSupportNotes.first)
        ]

        let sections = [
            GrocerySection(title: "Pantry & Staples", items: pantryItems),
            GrocerySection(title: "Protein & Recovery", items: proteinItems + hydrationItems),
            GrocerySection(title: "Treats & Dessert", items: dessertItems)
        ].filter { !$0.items.isEmpty }

        return GroceryList(sections: sections)
    }

    private func favoritesProtein(from profile: UserProfile) -> String {
        if let protein = profile.tastePreferences.first(where: { $0.localizedCaseInsensitiveContains("chicken") || $0.localizedCaseInsensitiveContains("salmon") }) {
            return protein.capitalized
        }
        return "Lean protein of choice"
    }
}

