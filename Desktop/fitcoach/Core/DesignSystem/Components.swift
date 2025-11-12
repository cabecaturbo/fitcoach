import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.body.font().weight(.semibold))
            .padding(.vertical, DesignTokens.Spacing.sm)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(DesignTokens.Color.accent.swiftUIColor)
            )
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(DesignTokens.Motion.quick, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.body.font().weight(.semibold))
            .padding(.vertical, DesignTokens.Spacing.sm)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .stroke(DesignTokens.Color.accent.swiftUIColor, lineWidth: 1)
            )
            .foregroundColor(DesignTokens.Color.accent.swiftUIColor)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(DesignTokens.Motion.quick, value: configuration.isPressed)
    }
}

struct ChipView: View {
    let text: String
    let isSelected: Bool

    var body: some View {
        Text(text)
            .font(DesignTokens.Typography.callout.font().weight(.semibold))
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                Capsule()
                    .fill(isSelected ? DesignTokens.Color.accent.swiftUIColor.opacity(0.16) : DesignTokens.Color.chipBackground.swiftUIColor)
            )
            .foregroundColor(isSelected ? DesignTokens.Color.accent.swiftUIColor : DesignTokens.Color.primaryText.swiftUIColor)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(DesignTokens.Typography.headline.font())
                .foregroundColor(DesignTokens.Color.primaryText.swiftUIColor)
            if let subtitle {
                Text(subtitle)
                    .font(DesignTokens.Typography.callout.font())
                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
    }
}

