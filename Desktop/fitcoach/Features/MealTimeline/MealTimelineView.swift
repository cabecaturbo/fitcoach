import SwiftUI

@MainActor
final class MealTimelineViewModel: ObservableObject {
    @Published var logs: [DailyLog] = []
    private let storage: StorageProviding
    private let calendar: Calendar = .current

    init(storage: StorageProviding) {
        self.storage = storage
        load()
    }

    func load() {
        logs = storage.fetchLogs().sorted { $0.date > $1.date }
    }
}

struct MealTimelineView: View {
    @ObservedObject var viewModel: MealTimelineViewModel

    init(viewModel: MealTimelineViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.logs) { log in
                    Section(header: Text(dateFormatter.string(from: log.date))) {
                        ForEach(log.entries) { entry in
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Text(entry.description)
                                    .font(DesignTokens.Typography.body.font())
                                if let macros = entry.macros {
                                    Text("\(Int(macros.calories)) kcal | \(Int(macros.protein))P \(Int(macros.carbohydrates))C \(Int(macros.fat))F")
                                        .font(DesignTokens.Typography.caption.font())
                                        .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                                }
                                Text(timeFormatter.string(from: entry.timestamp))
                                    .font(DesignTokens.Typography.caption.font())
                                    .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                            }
                            .padding(.vertical, DesignTokens.Spacing.xs)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Log")
            .toolbar {
                Button {
                    viewModel.load()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .overlay {
                if viewModel.logs.isEmpty {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 44))
                            .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                        Text("Log meals in chat, and they’ll appear here with macros.")
                            .font(DesignTokens.Typography.body.font())
                            .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignTokens.Spacing.lg)
                    }
                }
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

