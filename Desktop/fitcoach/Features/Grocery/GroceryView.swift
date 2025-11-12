import SwiftUI

@MainActor
final class GroceryViewModel: ObservableObject {
    @Published var groceryList: GroceryList = GroceryList(sections: [])
    @Published var searchText: String = ""

    private let storage: StorageProviding

    init(storage: StorageProviding) {
        self.storage = storage
        load()
    }

    func load() {
        if let list = storage.fetchPlan()?.groceryList {
            groceryList = list
        } else {
            groceryList = GroceryList(sections: [])
        }
    }

    var filteredSections: [GrocerySection] {
        guard !searchText.isEmpty else { return groceryList.sections }
        return groceryList.sections.map { section in
            let items = section.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) || (section.title.localizedCaseInsensitiveContains(searchText)) }
            return GrocerySection(id: section.id, title: section.title, items: items)
        }.filter { !$0.items.isEmpty }
    }
}

struct GroceryView: View {
    @ObservedObject var viewModel: GroceryViewModel

    init(viewModel: GroceryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredSections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.items) { item in
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                HStack {
                                    Text(item.name)
                                        .font(DesignTokens.Typography.body.font())
                                    Spacer()
                                    Text(tag(for: item.storage))
                                        .font(DesignTokens.Typography.caption.font())
                                        .padding(.horizontal, DesignTokens.Spacing.xs)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule().fill(DesignTokens.Color.chipBackground.swiftUIColor)
                                        )
                                }
                                if let notes = item.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(DesignTokens.Typography.caption.font())
                                        .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                                }
                            }
                            .padding(.vertical, DesignTokens.Spacing.xs)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .navigationTitle("Groceries")
            .toolbar {
                Button {
                    viewModel.load()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .overlay {
                if viewModel.groceryList.sections.isEmpty {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "cart")
                            .font(.system(size: 44))
                            .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                        Text("Generate your plan to see a personalized grocery list.")
                            .font(DesignTokens.Typography.body.font())
                            .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignTokens.Spacing.lg)
                    }
                }
            }
        }
    }

    private func tag(for storage: GroceryItem.Storage) -> String {
        switch storage {
        case .pantry: return "Pantry"
        case .refrigerated: return "Fridge"
        case .frozen: return "Frozen"
        case .fresh: return "Fresh"
        }
    }
}

