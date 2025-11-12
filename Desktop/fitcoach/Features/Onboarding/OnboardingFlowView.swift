import SwiftUI

@MainActor
final class OnboardingFlowViewModel: ObservableObject {
    @Published var answers: [Int: String] = [:]
    @Published var activeGroupIndex: Int = 0
    @Published var presentedHelper: Int?
    @Published var showingSkipConfirmation: Bool = false

    private let requiredQuestionIds: Set<Int>
    let groups: [QuestionGroup]
    let onComplete: (OnboardingPayload) -> Void

    init(groups: [QuestionGroup] = QuestionBank.groups,
         onComplete: @escaping (OnboardingPayload) -> Void) {
        self.groups = groups
        self.onComplete = onComplete
        self.requiredQuestionIds = Set(groups.flatMap { $0.questions }.filter { $0.required }.map { $0.id })
    }

    var progress: Double {
        guard !requiredQuestionIds.isEmpty else { return 1 }
        let answeredRequired = answers.keys.filter { requiredQuestionIds.contains($0) }.count
        return Double(answeredRequired) / Double(requiredQuestionIds.count)
    }

    var canFinish: Bool {
        requiredQuestionIds.allSatisfy { answers[$0]?.isEmpty == false }
    }

    func recordAnswer(_ answer: String, for question: Question) {
        answers[question.id] = answer
    }

    func skip(question: Question) {
        if question.required {
            showingSkipConfirmation = true
            return
        }

        answers.removeValue(forKey: question.id)
    }

    func finish() {
        guard canFinish else { return }
        let payload = OnboardingPayload(answers: answers)
        onComplete(payload)
    }
}

struct OnboardingPayload: Equatable {
    let answers: [Int: String]
}

struct OnboardingFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: OnboardingFlowViewModel

    init(viewModel: OnboardingFlowViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                        ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { index, group in
                            groupCard(group, index: index)
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.vertical, DesignTokens.Spacing.xl)
                }
                finishButton
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.vertical, DesignTokens.Spacing.lg)
                    .background(DesignTokens.Color.surface.swiftUIColor)
            }
            .background(DesignTokens.Color.background.swiftUIColor.ignoresSafeArea())
            .navigationTitle("Onboarding")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip onboarding") {
                        dismiss()
                    }
                    .font(DesignTokens.Typography.callout.font())
                }
            }
            .alert("You can’t skip this one", isPresented: $viewModel.showingSkipConfirmation, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("We need this answer to customize your plan.")
            })
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Hey! I’m your macro coach. Let’s make this yours.")
                .font(DesignTokens.Typography.headline.font())
                .foregroundColor(DesignTokens.Color.primaryText.swiftUIColor)
            ProgressView(value: viewModel.progress)
                .tint(DesignTokens.Color.accent.swiftUIColor)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(DesignTokens.Color.surface.swiftUIColor.shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4))
    }

    private func groupCard(_ group: QuestionGroup, index: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: group.title, subtitle: nil)
            ForEach(group.questions) { question in
                onboardingRow(question)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .fill(DesignTokens.Color.surface.swiftUIColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .stroke(DesignTokens.Color.surface.swiftUIColor.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 4)
    }

    private func onboardingRow(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                Text(question.text)
                    .font(DesignTokens.Typography.body.font())
                    .foregroundColor(DesignTokens.Color.primaryText.swiftUIColor)
                if question.required {
                    Text("Required")
                        .font(DesignTokens.Typography.caption.font())
                        .foregroundColor(DesignTokens.Color.accent.swiftUIColor)
                        .padding(.horizontal, DesignTokens.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(DesignTokens.Color.accent.swiftUIColor.opacity(0.16))
                        )
                }
                Spacer()
                if let helper = question.helper {
                    Button {
                        viewModel.presentedHelper = viewModel.presentedHelper == question.id ? nil : question.id
                    } label: {
                        Text("Why I’m asking")
                            .font(DesignTokens.Typography.caption.font())
                            .foregroundColor(DesignTokens.Color.accent.swiftUIColor)
                    }
                    .buttonStyle(.plain)
                }
            }

            if viewModel.presentedHelper == question.id, let helper = question.helper {
                Text(helper)
                    .font(DesignTokens.Typography.caption.font())
                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                    .padding(DesignTokens.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                            .fill(DesignTokens.Color.chipBackground.swiftUIColor)
                    )
            }

            VStack(spacing: DesignTokens.Spacing.xs) {
                TextField("Type your answer", text: Binding(
                    get: { viewModel.answers[question.id] ?? "" },
                    set: { viewModel.recordAnswer($0, for: question) }
                ))
                .textFieldStyle(.roundedBorder)

                if !question.quickReplies.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(question.quickReplies, id: \.self) { chip in
                                Button {
                                    viewModel.recordAnswer(chip, for: question)
                                } label: {
                                    ChipView(text: chip, isSelected: viewModel.answers[question.id] == chip)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, DesignTokens.Spacing.xs)
                    }
                }

                if !question.required {
                    Button("Skip for now") {
                        viewModel.skip(question: question)
                    }
                    .font(DesignTokens.Typography.caption.font())
                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                }
            }
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
    }

    private var finishButton: some View {
        Button {
            viewModel.finish()
            dismiss()
        } label: {
            Text("Finish")
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!viewModel.canFinish)
        .opacity(viewModel.canFinish ? 1 : 0.4)
        .accessibilityHint("Enabled when required answers are complete.")
    }
}

