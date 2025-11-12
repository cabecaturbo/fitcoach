import Foundation

public struct GroceryItem: Codable, Equatable, Identifiable {
    public enum Storage: String, Codable {
        case pantry
        case refrigerated
        case frozen
        case fresh
    }

    public let id: UUID
    public var name: String
    public var aisle: String
    public var storage: Storage
    public var notes: String?

    public init(id: UUID = UUID(),
                name: String,
                aisle: String,
                storage: Storage,
                notes: String? = nil) {
        self.id = id
        self.name = name
        self.aisle = aisle
        self.storage = storage
        self.notes = notes
    }
}

public struct GrocerySection: Codable, Equatable, Identifiable {
    public let id: UUID
    public var title: String
    public var items: [GroceryItem]

    public init(id: UUID = UUID(),
                title: String,
                items: [GroceryItem]) {
        self.id = id
        self.title = title
        self.items = items
    }
}

public struct GroceryList: Codable, Equatable {
    public var sections: [GrocerySection]

    public init(sections: [GrocerySection]) {
        self.sections = sections
    }
}

