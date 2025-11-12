import SwiftUI

struct AppRoute {
    enum Tab: Hashable {
        case coach
        case plan
        case log
        case groceries
        case profile
    }
}

@MainActor
final class AppRouting: ObservableObject {
    @Published var activeTab: AppRoute.Tab = .coach
    @Published var showOnboarding: Bool = true
}

