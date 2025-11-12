import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    private let storage: StorageProviding

    init(storage: StorageProviding) {
        self.storage = storage
        load()
    }

    func load() {
        profile = storage.fetchUserProfile()
    }
}

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                if let profile = viewModel.profile {
                    Section(header: Text("Body Composition")) {
                        if let weight = profile.bodyComposition.weightKg {
                            profileRow(label: "Weight", value: "\(Int(weight)) kg")
                        }
                        if let height = profile.bodyComposition.heightCm {
                            profileRow(label: "Height", value: "\(Int(height)) cm")
                        }
                        if let bodyFat = profile.bodyComposition.bodyFatPercentage {
                            profileRow(label: "Body Fat", value: "\(String(format: "%.1f", bodyFat))%")
                        }
                        if let leanMass = profile.bodyComposition.leanMassKg {
                            profileRow(label: "Lean Mass", value: "\(String(format: "%.1f", leanMass)) kg")
                        }
                    }

                    Section(header: Text("Goals")) {
                        profileRow(label: "Primary", value: profile.goals.map(\.rawValue.capitalized).joined(separator: ", "))
                        profileRow(label: "Training Load", value: profile.training.load.rawValue.capitalized)
                        profileRow(label: "Performance Focus", value: profile.training.performanceGoals.map(\.rawValue.capitalized).joined(separator: ", "))
                    }

                    Section(header: Text("Preferences")) {
                        profileRow(label: "Foods you love", value: profile.tastePreferences.joined(separator: ", "))
                        profileRow(label: "Foods to avoid", value: profile.avoidances.joined(separator: ", "))
                        profileRow(label: "Dessert cadence", value: profile.dessertCadence ?? "Not set")
                    }

                    Section(header: Text("Health")) {
                        profileRow(label: "Supplements", value: profile.health.supplements.map(\.name).joined(separator: ", "))
                        profileRow(label: "Conditions", value: profile.health.conditions.joined(separator: ", "))
                        profileRow(label: "Injuries", value: profile.health.injuries.joined(separator: ", "))
                    }
                } else {
                    Text("Complete onboarding to fill in your profile.")
                        .font(DesignTokens.Typography.body.font())
                        .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
                        .padding()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .toolbar {
                Button {
                    viewModel.load()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }

    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(DesignTokens.Color.secondaryText.swiftUIColor)
            Spacer()
            Text(value.isEmpty ? "–" : value)
                .foregroundColor(DesignTokens.Color.primaryText.swiftUIColor)
        }
    }
}

