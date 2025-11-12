import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    enum Sender {
        case user
        case coach
    }

    let id: UUID
    let sender: Sender
    let text: String
    let timestamp: Date

    init(id: UUID = UUID(), sender: Sender, text: String, timestamp: Date = Date()) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var dailyTotals: Macros = Macros(calories: 0, protein: 0, carbohydrates: 0, fat: 0)
    @Published var targetMacros: Macros?
    @Published var adjustments: [Adjustment] = []
    @Published var isLoading: Bool = false

    private let llmClient: LLMClient
    private let storage: StorageProviding
    private let planEngine: PlanEngine
    private let calendar: Calendar = .current

    init(llmClient: LLMClient, storage: StorageProviding, planEngine: PlanEngine) {
        self.llmClient = llmClient
        self.storage = storage
        self.planEngine = planEngine
        bootstrapConversation()
    }

    func sendMessage() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = ChatMessage(sender: .user, text: trimmed)
        messages.append(userMessage)
        input = ""

        Task {
            await handleMealEntry(from: trimmed)
        }
    }

    private func bootstrapConversation() {
        messages = [
            ChatMessage(sender: .coach, text: "Welcome back! Log what you ate or how training feels, and I’ll keep your macros dialed.")
        ]
        refreshState()
    }

    private func refreshState() {
        let logs = storage.fetchLogs()
        let today = calendar.startOfDay(for: Date())
        let todaysLog = logs.first(where: { calendar.isDate($0.date, inSameDayAs: today) })
        dailyTotals = todaysLog?.totalMacros ?? Macros(calories: 0, protein: 0, carbohydrates: 0, fat: 0)

        if let plan = storage.fetchPlan(), let target = targetTemplate(for: plan)?.macros {
            targetMacros = target
        } else {
            targetMacros = nil
        }
    }

    private func handleMealEntry(from text: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let entry = try await llmClient.parseMealEntry(text)
            persist(entry: entry)
            refreshState()
            try await produceAdjustments()
        } catch {
            await MainActor.run {
                messages.append(ChatMessage(sender: .coach, text: "I couldn’t parse that. Try sharing what you had and when, like “Slice of pie at 9am.”"))
            }
        }
    }

    private func persist(entry: MealEntry) {
        var logs = storage.fetchLogs()
        let today = calendar.startOfDay(for: Date())

        if let index = logs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            var log = logs[index]
            log.entries.append(entry)
            log.entries.sort { $0.timestamp < $1.timestamp }
            logs[index] = log
            storage.saveLog(log)
        } else {
            let log = DailyLog(date: today, entries: [entry], trainingLoad: currentTrainingLoad(), recoveryFlag: currentRecoveryFlag())
            storage.saveLog(log)
        }

        messages.append(ChatMessage(sender: .coach, text: acknowledgement(for: entry)))
    }

    private func targetTemplate(for plan: Plan) -> MacroTemplate? {
        let trainingLoad = currentTrainingLoad()
        switch trainingLoad {
        case .heavy:
            return plan.templates.first(where: { $0.type == .training }) ?? plan.templates.first
        case .light:
            return plan.templates.first(where: { $0.type == .rest }) ?? plan.templates.first
        case .moderate:
            return plan.templates.first(where: { $0.type == .training }) ?? plan.templates.first
        case .variable:
            let weekday = Weekday.from(date: Date(), calendar: calendar)
            if storage.fetchUserProfile()?.training.highFuelDays.contains(weekday) == true {
                return plan.templates.first(where: { $0.type == .high }) ?? plan.templates.first(where: { $0.type == .training })
            }
            return plan.templates.first(where: { $0.type == .low }) ?? plan.templates.first(where: { $0.type == .rest })
        }
    }

    private func currentTrainingLoad() -> TrainingLoad {
        storage.fetchUserProfile()?.training.load ?? .moderate
    }

    private func currentRecoveryFlag() -> Bool {
        let recoveryPractices = storage.fetchUserProfile()?.training.recoveryPractices.joined(separator: " ").lowercased() ?? ""
        return recoveryPractices.contains("sauna") || recoveryPractices.contains("sleep") || recoveryPractices.contains("hrv")
    }

    private func acknowledgement(for entry: MealEntry) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let time = formatter.string(from: entry.timestamp)

        if entry.description.lowercased().contains("pie") {
            return "Noted the pie at \(time). I’ll balance it by trimming carbs later if needed."
        }
        return "Logged \(entry.description.lowercased()) at \(time)."
    }

    private func buildDayContext() -> DayContext {
        DayContext(
            date: Date(),
            trainingLoad: currentTrainingLoad(),
            recoveryFlag: currentRecoveryFlag(),
            targetMacros: targetMacros,
            consumedMacros: dailyTotals
        )
    }

    private func produceAdjustments() async throws {
        let context = buildDayContext()
        let suggested = try await llmClient.suggestAdjustments(for: context)

        await MainActor.run {
            adjustments = suggested
            if let first = suggested.first {
                messages.append(ChatMessage(sender: .coach, text: first.message))
            }
        }
    }
}

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
                .background(DesignTokens.Color.background.swiftUIColor)
                .onChange(of: viewModel.messages) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            totalsBar
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(DesignTokens.Color.surface.swiftUIColor.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4))

            inputBar
                .background(DesignTokens.Color.surface.swiftUIColor)
        }
    }

    private var totalsBar: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Today")
                    .font(DesignTokens.Typography.caption.font())
                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                Text("\(Int(viewModel.dailyTotals.calories)) / \(Int(viewModel.targetMacros?.calories ?? 0)) kcal")
                    .font(DesignTokens.Typography.body.font().weight(.semibold))
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Macros")
                    .font(DesignTokens.Typography.caption.font())
                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                Text("\(Int(viewModel.dailyTotals.protein))P | \(Int(viewModel.dailyTotals.carbohydrates))C | \(Int(viewModel.dailyTotals.fat))F")
                    .font(DesignTokens.Typography.body.font())
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            TextField("Log meals or ask a question…", text: $viewModel.input)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isLoading)
            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: viewModel.isLoading ? "hourglass" : "paperplane.fill")
            }
            .disabled(viewModel.isLoading)
        }
        .padding(DesignTokens.Spacing.lg)
    }
}

private struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.sender == .coach {
                bubble
                Spacer()
            } else {
                Spacer()
                bubble
            }
        }
    }

    private var bubble: some View {
        Text(message.text)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(message.sender == .coach ? DesignTokens.Color.surface.swiftUIColor : DesignTokens.Color.accent.swiftUIColor)
            )
            .foregroundColor(message.sender == .coach ? DesignTokens.Color.primaryText.swiftUIColor : .white)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.sender == .coach ? .leading : .trailing)
    }
}

