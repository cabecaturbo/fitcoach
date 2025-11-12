import Foundation

protocol StorageProviding {
    func fetchUserProfile() -> UserProfile?
    func saveUserProfile(_ profile: UserProfile)

    func fetchPlan() -> Plan?
    func savePlan(_ plan: Plan)

    func fetchLogs() -> [DailyLog]
    func saveLog(_ log: DailyLog)
}

