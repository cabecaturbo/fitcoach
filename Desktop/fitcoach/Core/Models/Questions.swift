import Foundation

public struct Question: Identifiable, Hashable, Codable {
    public let id: Int
    public let text: String
    public let required: Bool
    public let groupId: Int
    public let helper: String?
    public let quickReplies: [String]

    public init(id: Int,
                text: String,
                required: Bool = false,
                groupId: Int,
                helper: String? = nil,
                quickReplies: [String] = []) {
        self.id = id
        self.text = text
        self.required = required
        self.groupId = groupId
        self.helper = helper
        self.quickReplies = quickReplies
    }
}

public struct QuestionGroup: Identifiable, Hashable, Codable {
    public let id: Int
    public let title: String
    public let questions: [Question]

    public init(id: Int, title: String, questions: [Question]) {
        self.id = id
        self.title = title
        self.questions = questions
    }
}

public enum QuestionBank {
    public static let groups: [QuestionGroup] = [
        QuestionGroup(
            id: 1,
            title: "Daily Rhythm & Frequency",
            questions: [
                Question(id: 1, text: "Walk me through a usual day — when do you tend to eat meals?", groupId: 1, helper: "Timing helps me space energy and protein for you.", quickReplies: ["Early breakfast", "Late breakfast", "Varies"]),
                Question(id: 2, text: "How many meals or snacks feel right most days?", groupId: 1, quickReplies: ["3 meals", "3 + snacks", "4+", "It depends"]),
                Question(id: 3, text: "Any times of day you prefer not to eat?", groupId: 1, quickReplies: ["Early AM", "Late PM", "Nope"])
            ]
        ),
        QuestionGroup(
            id: 2,
            title: "Taste & Preferences",
            questions: [
                Question(id: 4, text: "Foods you’re loving lately?", groupId: 2, quickReplies: ["Savory", "Sweet", "Spicy"]),
                Question(id: 5, text: "Foods or flavors you’d rather skip?", groupId: 2, quickReplies: ["Beans", "Seafood", "Spicy", "No thanks"]),
                Question(id: 11, text: "Favorite fruits or vegetables?", groupId: 2, quickReplies: ["Berries", "Citrus", "Leafy greens"]),
                Question(id: 12, text: "Any fruits or veggies you avoid?", groupId: 2, quickReplies: ["Cruciferous", "Nightshades", "Not picky"]),
                Question(id: 9, text: "Carbs that make you feel great?", groupId: 2, quickReplies: ["Rice", "Potatoes", "Pasta", "Oats"]),
                Question(id: 10, text: "Proteins you enjoy most?", groupId: 2, quickReplies: ["Chicken", "Fish", "Plant-based", "Red meat"])
            ]
        ),
        QuestionGroup(
            id: 3,
            title: "Dietary Constraints",
            questions: [
                Question(id: 6, text: "Any dietary restrictions, allergies, or cultural guidelines?", groupId: 3, helper: "I’ll keep your plan safe and respectful.", quickReplies: ["Gluten-free", "Dairy-free", "Halal", "Kosher", "None"])
            ]
        ),
        QuestionGroup(
            id: 4,
            title: "Sweets & Treats",
            questions: [
                Question(id: 7, text: "How often do desserts or treats pop up?", groupId: 4, quickReplies: ["Daily", "Few times/week", "Rarely"]),
                Question(id: 8, text: "What kind of sweet tooth are we fueling?", groupId: 4, quickReplies: ["Chocolate", "Candy", "Pastry", "Ice cream"])
            ]
        ),
        QuestionGroup(
            id: 5,
            title: "Cooking & Time",
            questions: [
                Question(id: 13, text: "How do you feel about cooking?", groupId: 5, quickReplies: ["Love it", "Some days", "Minimal"]),
                Question(id: 14, text: "Prep time sweet spot per meal?", groupId: 5, quickReplies: ["<15 min", "15–30 min", "45+ min"]),
                Question(id: 15, text: "Any kitchen equipment limits or favorites?", groupId: 5, quickReplies: ["Air fryer", "Slow cooker", "No oven", "Minimal gear"])
            ]
        ),
        QuestionGroup(
            id: 6,
            title: "Shopping Habits",
            questions: [
                Question(id: 16, text: "How often do you shop for groceries?", groupId: 6, quickReplies: ["Daily", "2-3x/week", "Weekly"]),
                Question(id: 17, text: "Do you follow a fixed list or shop flexibly?", groupId: 6, quickReplies: ["Fixed list", "Flexible", "Hybrid"]),
                Question(id: 18, text: "Staples you always keep on hand?", groupId: 6),
                Question(id: 19, text: "Seasonal favorites worth planning around?", groupId: 6)
            ]
        ),
        QuestionGroup(
            id: 7,
            title: "Body Data & Goals",
            questions: [
                Question(id: 20, text: "Recent DEXA/InBody values? Drop them in if you have them.", required: true, groupId: 7, helper: "Body comp helps me anchor your macros precisely."),
                Question(id: 21, text: "If no scan, what’s your height, weight, biological sex, and estimated body fat %?", groupId: 7, quickReplies: ["Share info", "Prefer not"]),
                Question(id: 22, text: "Primary goals right now? (gain, loss, performance, energy, convenience…)", groupId: 7, quickReplies: ["Build muscle", "Lose fat", "Perform", "Energy", "Sustain"])
            ]
        ),
        QuestionGroup(
            id: 8,
            title: "Health & Supplements",
            questions: [
                Question(id: 23, text: "Any supplements or meds affecting metabolism, nutrition, or body comp? (creatine, GLP-1s…)", required: true, groupId: 8, helper: "This keeps recommendations safe and effective.", quickReplies: ["Creatine", "GLP-1", "HRT", "None"]),
                Question(id: 24, text: "List them for me so I can factor them in.", groupId: 8),
                Question(id: 25, text: "Any injuries or limitations I should respect?", groupId: 8, quickReplies: ["Shoulder", "Back", "Knee", "None"]),
                Question(id: 26, text: "Any medical conditions I should keep in mind? (diabetes, thyroid, digestive…)", groupId: 8)
            ]
        ),
        QuestionGroup(
            id: 9,
            title: "Training & Recovery",
            questions: [
                Question(id: 27, text: "How heavy is your current training load and recovery? (light, moderate, heavy, variable)", required: true, groupId: 9, helper: "I periodize fuel around training and recovery."),
                Question(id: 28, text: "Which days need extra fuel or recovery support?", groupId: 9, quickReplies: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]),
                Question(id: 29, text: "Performance focus? Endurance, speed, strength, or something else?", groupId: 9, quickReplies: ["Endurance", "Speed", "Strength", "Power"]),
                Question(id: 30, text: "Other health practices worth noting (hydration, fasting, sleep, stress)?", groupId: 9)
            ]
        )
    ]
}

