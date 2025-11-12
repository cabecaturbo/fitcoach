import Foundation

public struct Macros: Codable, Equatable {
    public var calories: Double
    public var protein: Double
    public var carbohydrates: Double
    public var fat: Double

    public init(calories: Double, protein: Double, carbohydrates: Double, fat: Double) {
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
    }
}

public struct MacroTemplate: Codable, Equatable, Identifiable {
    public enum TemplateType: String, Codable {
        case training
        case rest
        case high
        case low
    }

    public let id: UUID
    public var name: String
    public var type: TemplateType
    public var macros: Macros
    public var notes: [String]

    public init(id: UUID = UUID(),
                name: String,
                type: TemplateType,
                macros: Macros,
                notes: [String] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.macros = macros
        self.notes = notes
    }
}

public struct Meal: Codable, Equatable, Identifiable {
    public let id: UUID
    public var name: String
    public var items: [String]
    public var macros: Macros

    public init(id: UUID = UUID(),
                name: String,
                items: [String],
                macros: Macros) {
        self.id = id
        self.name = name
        self.items = items
        self.macros = macros
    }
}

public struct DailyPlan: Codable, Equatable, Identifiable {
    public let id: UUID
    public var label: String
    public var template: MacroTemplate
    public var meals: [Meal]

    public init(id: UUID = UUID(),
                label: String,
                template: MacroTemplate,
                meals: [Meal]) {
        self.id = id
        self.label = label
        self.template = template
        self.meals = meals
    }
}

public struct Plan: Codable, Equatable, Identifiable {
    public let id: UUID
    public var createdAt: Date
    public var updatedAt: Date
    public var templates: [MacroTemplate]
    public var dailyPlans: [DailyPlan]
    public var groceryList: GroceryList

    public init(id: UUID = UUID(),
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                templates: [MacroTemplate] = [],
                dailyPlans: [DailyPlan] = [],
                groceryList: GroceryList = GroceryList(sections: [])) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.templates = templates
        self.dailyPlans = dailyPlans
        self.groceryList = groceryList
    }
}

