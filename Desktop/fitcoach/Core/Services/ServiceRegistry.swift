import Foundation

struct ServiceRegistry {
    let llmClient: LLMClient
    let planEngine: PlanEngine
    let storage: StorageProviding
    let userProfileStore: UserProfileStore
}

extension ServiceRegistry {
    static func bootstrap() -> ServiceRegistry {
        let storage = FileStorage()
        let planEngine = PlanEngine()
        let llmClient = MockLLMClient()
        let userProfileStore = UserProfileStore(storage: storage, planEngine: planEngine)

        return ServiceRegistry(
            llmClient: llmClient,
            planEngine: planEngine,
            storage: storage,
            userProfileStore: userProfileStore
        )
    }
}

