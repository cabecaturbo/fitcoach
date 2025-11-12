import SwiftUI

enum DesignTokens {
    enum Color {
        static let background = ColorToken(light: Color(.systemGroupedBackground))
        static let surface = ColorToken(light: Color(.secondarySystemGroupedBackground))
        static let primaryText = ColorToken(light: Color(.label))
        static let secondaryText = ColorToken(light: Color(.secondaryLabel))
        static let accent = ColorToken(light: Color(red: 0.12, green: 0.45, blue: 0.75))
        static let success = ColorToken(light: Color(red: 0.27, green: 0.67, blue: 0.36))
        static let warning = ColorToken(light: Color(red: 0.95, green: 0.69, blue: 0.12))
        static let danger = ColorToken(light: Color(red: 0.89, green: 0.25, blue: 0.18))
        static let chipBackground = ColorToken(light: Color(red: 0.94, green: 0.96, blue: 0.99))
    }

    enum Typography {
        static let largeTitle = FontToken(size: 34, weight: .bold)
        static let title = FontToken(size: 24, weight: .semibold)
        static let headline = FontToken(size: 20, weight: .semibold)
        static let body = FontToken(size: 16, weight: .regular)
        static let callout = FontToken(size: 15, weight: .regular)
        static let caption = FontToken(size: 13, weight: .medium)
        static let footnote = FontToken(size: 12, weight: .regular)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
    }

    enum Motion {
        static let quick: Animation = .easeInOut(duration: 0.12)
        static let standard: Animation = .easeInOut(duration: 0.16)
        static let gentle: Animation = .easeInOut(duration: 0.24)
    }
}

struct ColorToken {
    let light: Color

    var swiftUIColor: Color { light }
}

struct FontToken {
    let size: CGFloat
    let weight: Font.Weight

    func font() -> Font {
        .system(size: size, weight: weight)
    }
}

