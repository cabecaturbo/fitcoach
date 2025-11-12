import SwiftUI

@MainActor
final class PlanDashboardViewModel: ObservableObject {
    @Published var plan: Plan?
    @Published var selectedTemplateId: UUID?

    private let storage: StorageProviding
    private let planEngine: PlanEngine

    init(storage: StorageProviding, planEngine: PlanEngine) {
        self.storage = storage
        self.planEngine = planEngine
        load()
    }

    func load() {
        if let saved = storage.fetchPlan() {
            plan = saved
            selectedTemplateId = saved.templates.first?.id
            return
        }

        guard let profile = storage.fetchUserProfile() else {
            plan = nil
            return
        }

        let newPlan = planEngine.generatePlan(for: profile)
        storage.savePlan(newPlan)
        plan = newPlan
        selectedTemplateId = newPlan.templates.first?.id
    }

    func selectTemplate(_ template: MacroTemplate) {
        selectedTemplateId = template.id
    }

    var selectedTemplate: MacroTemplate? {
        guard let plan else { return nil }
        return plan.templates.first(where: { $0.id == selectedTemplateId }) ?? plan.templates.first
    }
}

struct PlanDashboardView: View {
    @ObservedObject var viewModel: PlanDashboardViewModel

    init(viewModel: PlanDashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Group {
                if let template = viewModel.selectedTemplate {
                    ScrollView {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                            templatePicker
                            macroRings(for: template)
                            planNotes(template)
                            sampleDays(template)
                            grocerySection
                        }
                        .padding(DesignTokens.Spacing.lg)
                    }
                    .background(DesignTokens.Color.background.swiftUIColor.ignoresSafeArea())
                } else {
                    emptyState
                }
            }
            .navigationTitle("Plan")
            .toolbar {
                Button {
                    viewModel.load()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }

    private var templatePicker: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Fuel rhythm")
                .font(DesignTokens.Typography.headline.font())
            SegmentedTemplatePicker(templates: viewModel.plan?.templates ?? [], selectedId: $viewModel.selectedTemplateId)
        }
    }

    private func macroRings(for template: MacroTemplate) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(template.name)
                .font(DesignTokens.Typography.title.font())
            HStack(spacing: DesignTokens.Spacing.lg) {
                MacroRing(value: template.macros.calories, title: "Calories", unit: "kcal", maxValue: template.macros.calories)
                MacroRing(value: template.macros.protein, title: "Protein", unit: "g", maxValue: template.macros.protein)
                MacroRing(value: template.macros.carbohydrates, title: "Carbs", unit: "g", maxValue: template.macros.carbohydrates)
                MacroRing(value: template.macros.fat, title: "Fat", unit: "g", maxValue: template.macros.fat)
            }
        }
    }

    private func planNotes(_ template: MacroTemplate) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Why this plan")
                .font(DesignTokens.Typography.headline.font())
            ForEach(template.notes, id: \.self) { note in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(DesignTokens.Color.accent.swiftUIColor)
                    Text(note)
                        .font(DesignTokens.Typography.body.font())
                        .foregroundColor(DesignTokens.Color.primaryText.swiftUIColor)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(DesignTokens.Color.surface.swiftUIColor)
        )
    }

    private func sampleDays(_ template: MacroTemplate) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Sample day")
                .font(DesignTokens.Typography.headline.font())
            if let day = viewModel.plan?.dailyPlans.first(where: { $0.template.id == template.id }) {
                ForEach(day.meals) { meal in
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(meal.name)
                            .font(DesignTokens.Typography.callout.font().weight(.semibold))
                        Text(meal.items.joined(separator: ", "))
                            .font(DesignTokens.Typography.body.font())
                            .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                        Text("\(Int(meal.macros.calories)) kcal | \(Int(meal.macros.protein))P / \(Int(meal.macros.carbohydrates))C / \(Int(meal.macros.fat))F")
                            .font(DesignTokens.Typography.caption.font())
                            .foregroundColor(DesignTokens.Color.primaryText.swiftUIColor)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                            .fill(DesignTokens.Color.surface.swiftUIColor)
                    )
                }
            } else {
                Text("We’ll generate training and rest day examples once your plan is ready.")
                    .font(DesignTokens.Typography.body.font())
                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
            }
        }
    }

    private var grocerySection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Groceries")
                .font(DesignTokens.Typography.headline.font())
            if let sections = viewModel.plan?.groceryList.sections {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(section.title)
                            .font(DesignTokens.Typography.callout.font().weight(.semibold))
                        ForEach(section.items) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text(item.storage.rawValue.capitalized)
                                    .font(DesignTokens.Typography.caption.font())
                                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                            }
                            .padding(.vertical, 2)
                            if let notes = item.notes {
                                Text(notes)
                                    .font(DesignTokens.Typography.caption.font())
                                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                            .fill(DesignTokens.Color.surface.swiftUIColor)
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(DesignTokens.Color.accent.swiftUIColor)
            Text("Complete onboarding to unlock your plan.")
                .font(DesignTokens.Typography.body.font())
                .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
        }
        .padding()
    }
}

private struct SegmentedTemplatePicker: View {
    let templates: [MacroTemplate]
    @Binding var selectedId: UUID?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(templates) { template in
                    Button {
                        selectedId = template.id
                    } label: {
                        ChipView(text: template.type.rawValue.capitalized, isSelected: selectedId == template.id)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, DesignTokens.Spacing.xs)
        }
    }
}

private struct MacroRing: View {
    let value: Double
    let title: String
    let unit: String
    let maxValue: Double

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(DesignTokens.Color.surface.swiftUIColor, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(DesignTokens.Color.accent.swiftUIColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(DesignTokens.Motion.standard, value: progress)
                VStack {
                    Text("\(Int(value))")
                        .font(DesignTokens.Typography.headline.font())
                    Text(unit)
                        .font(DesignTokens.Typography.caption.font())
                        .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                }
            }
            .frame(width: 90, height: 90)

            Text(title)
                .font(DesignTokens.Typography.caption.font())
        }
    }

    private var progress: Double {
        guard maxValue > 0 else { return 0 }
        return min(value / maxValue, 1)
    }
}

