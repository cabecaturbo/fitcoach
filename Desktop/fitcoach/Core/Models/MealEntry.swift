import Foundation

public struct MealEntry: Codable, Equatable, Identifiable {
    public let id: UUID
    public var timestamp: Date
    public var description: String
    public var macros: Macros?

    public init(id: UUID = UUID(),
                timestamp: Date,
                description: String,
                macros: Macros? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.description = description
        self.macros = macros
    }
}

