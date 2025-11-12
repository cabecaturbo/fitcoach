import SwiftUI

@MainActor
final class AppContainer: ObservableObject {
    let services: ServiceRegistry
    @Published var routing: AppRouting

    init(services: ServiceRegistry = .bootstrap(),
         routing: AppRouting = AppRouting()) {
        self.services = services
        self.routing = routing
        self.routing.showOnboarding = services.storage.fetchUserProfile() == nil
    }

    func buildCoachTab() -> some View {
        ChatView(viewModel: ChatViewModel(
            llmClient: services.llmClient,
            storage: services.storage,
            planEngine: services.planEngine))
            .environmentObject(services.userProfileStore)
    }

    func buildPlanTab() -> some View {
        PlanDashboardView(viewModel: PlanDashboardViewModel(
            storage: services.storage,
            planEngine: services.planEngine))
            .environmentObject(services.userProfileStore)
    }

    func buildLogTab() -> some View {
        MealTimelineView(viewModel: MealTimelineViewModel(storage: services.storage))
            .environmentObject(services.userProfileStore)
    }

    func buildGroceriesTab() -> some View {
        GroceryView(viewModel: GroceryViewModel(storage: services.storage))
            .environmentObject(services.userProfileStore)
    }

    func buildProfileTab() -> some View {
        ProfileView(viewModel: ProfileViewModel(storage: services.storage))
            .environmentObject(services.userProfileStore)
    }
}

