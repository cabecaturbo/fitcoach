import Foundation

public struct DailyLog: Codable, Equatable, Identifiable {
    public let id: UUID
    public var date: Date
    public var entries: [MealEntry]
    public var trainingLoad: TrainingLoad
    public var recoveryFlag: Bool

    public init(id: UUID = UUID(),
                date: Date,
                entries: [MealEntry] = [],
                trainingLoad: TrainingLoad,
                recoveryFlag: Bool) {
        self.id = id
        self.date = date
        self.entries = entries
        self.trainingLoad = trainingLoad
        self.recoveryFlag = recoveryFlag
    }

    public var totalMacros: Macros {
        entries.reduce(Macros(calories: 0, protein: 0, carbohydrates: 0, fat: 0)) { partial, entry in
            guard let macros = entry.macros else { return partial }
            return Macros(
                calories: partial.calories + macros.calories,
                protein: partial.protein + macros.protein,
                carbohydrates: partial.carbohydrates + macros.carbohydrates,
                fat: partial.fat + macros.fat
            )
        }
    }
}

