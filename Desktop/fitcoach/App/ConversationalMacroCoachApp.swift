import SwiftUI

@main
struct ConversationalMacroCoachApp: App {
    @StateObject private var appContainer = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appContainer)
        }
    }
}

struct RootTabView: View {
    @EnvironmentObject private var appContainer: AppContainer

    var body: some View {
        TabView(selection: $appContainer.routing.activeTab) {
            appContainer.buildCoachTab()
                .tabItem {
                    Label("Coach", systemImage: "figure.walk.circle")
                }
                .tag(AppRoute.Tab.coach)

            appContainer.buildPlanTab()
                .tabItem {
                    Label("Plan", systemImage: "chart.pie.fill")
                }
                .tag(AppRoute.Tab.plan)

            appContainer.buildLogTab()
                .tabItem {
                    Label("Log", systemImage: "list.bullet.rectangle")
                }
                .tag(AppRoute.Tab.log)

            appContainer.buildGroceriesTab()
                .tabItem {
                    Label("Groceries", systemImage: "cart.fill")
                }
                .tag(AppRoute.Tab.groceries)

            appContainer.buildProfileTab()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(AppRoute.Tab.profile)
        }
        .accentColor(DesignTokens.Color.accent.swiftUIColor)
        .fullScreenCover(isPresented: $appContainer.routing.showOnboarding) {
            OnboardingFlowView(
                viewModel: OnboardingFlowViewModel { payload in
                    appContainer.services.userProfileStore.apply(payload: payload)
                    appContainer.routing.showOnboarding = false
                }
            )
        }
    }
}

