import Foundation

public struct Adjustment: Codable, Equatable, Identifiable {
    public let id: UUID
    public var message: String
    public var actions: [String]

    public init(id: UUID = UUID(), message: String, actions: [String]) {
        self.id = id
        self.message = message
        self.actions = actions
    }
}

