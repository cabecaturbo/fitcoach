import Foundation

public enum BiologicalSex: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case other

    public var id: String { rawValue }
}

public struct BodyComposition: Codable, Equatable {
    public var weightKg: Double?
    public var heightCm: Double?
    public var bodyFatPercentage: Double?
    public var leanMassKg: Double?
    public var biologicalSex: BiologicalSex?
    public var ageYears: Int?

    public init(weightKg: Double? = nil,
                heightCm: Double? = nil,
                bodyFatPercentage: Double? = nil,
                leanMassKg: Double? = nil,
                biologicalSex: BiologicalSex? = nil,
                ageYears: Int? = nil) {
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.bodyFatPercentage = bodyFatPercentage
        self.leanMassKg = leanMassKg
        self.biologicalSex = biologicalSex
        self.ageYears = ageYears
    }
}

public enum NutritionGoal: String, Codable, CaseIterable, Identifiable {
    case gain
    case loss
    case maintenance
    case performance
    case energy
    case convenience
    case other

    public var id: String { rawValue }
}

public struct Supplement: Codable, Equatable, Identifiable {
    public let id: UUID
    public var name: String

    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

public struct HealthProfile: Codable, Equatable {
    public var supplements: [Supplement]
    public var injuries: [String]
    public var conditions: [String]

    public init(supplements: [Supplement] = [],
                injuries: [String] = [],
                conditions: [String] = []) {
        self.supplements = supplements
        self.injuries = injuries
        self.conditions = conditions
    }
}

public struct TrainingProfile: Codable, Equatable {
    public var load: TrainingLoad
    public var highFuelDays: [Weekday]
    public var performanceGoals: [PerformanceGoal]
    public var recoveryPractices: [String]

    public init(load: TrainingLoad,
                highFuelDays: [Weekday] = [],
                performanceGoals: [PerformanceGoal] = [],
                recoveryPractices: [String] = []) {
        self.load = load
        self.highFuelDays = highFuelDays
        self.performanceGoals = performanceGoals
        self.recoveryPractices = recoveryPractices
    }
}

public enum PerformanceGoal: String, Codable, CaseIterable, Identifiable {
    case endurance
    case speed
    case strength
    case power
    case other

    public var id: String { rawValue }
}

public enum Weekday: String, Codable, CaseIterable, Identifiable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    public var id: String { rawValue }

    public static func from(date: Date, calendar: Calendar = .current) -> Weekday {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .saturday
        }
    }
}

public struct UserProfile: Codable, Equatable, Identifiable {
    public let id: UUID
    public var name: String
    public var bodyComposition: BodyComposition
    public var goals: [NutritionGoal]
    public var health: HealthProfile
    public var training: TrainingProfile
    public var tastePreferences: [String]
    public var avoidances: [String]
    public var groceryStaples: [String]
    public var dessertCadence: String?
    public var mealCadence: Int?

    public init(id: UUID = UUID(),
                name: String = "",
                bodyComposition: BodyComposition = BodyComposition(),
                goals: [NutritionGoal] = [],
                health: HealthProfile = HealthProfile(),
                training: TrainingProfile = TrainingProfile(load: .moderate),
                tastePreferences: [String] = [],
                avoidances: [String] = [],
                groceryStaples: [String] = [],
                dessertCadence: String? = nil,
                mealCadence: Int? = nil) {
        self.id = id
        self.name = name
        self.bodyComposition = bodyComposition
        self.goals = goals
        self.health = health
        self.training = training
        self.tastePreferences = tastePreferences
        self.avoidances = avoidances
        self.groceryStaples = groceryStaples
        self.dessertCadence = dessertCadence
        self.mealCadence = mealCadence
    }
}

