import Foundation

public enum TrainingLoad: String, Codable, CaseIterable, Identifiable {
    case light
    case moderate
    case heavy
    case variable

    public var id: String { rawValue }
}

public struct DayContext: Codable, Equatable, Identifiable {
    public let id: UUID
    public let date: Date
    public let trainingLoad: TrainingLoad
    public let recoveryFlag: Bool
    public var targetMacros: Macros?
    public var consumedMacros: Macros?

    public init(id: UUID = UUID(),
                date: Date,
                trainingLoad: TrainingLoad,
                recoveryFlag: Bool,
                targetMacros: Macros? = nil,
                consumedMacros: Macros? = nil) {
        self.id = id
        self.date = date
        self.trainingLoad = trainingLoad
        self.recoveryFlag = recoveryFlag
        self.targetMacros = targetMacros
        self.consumedMacros = consumedMacros
    }
}

