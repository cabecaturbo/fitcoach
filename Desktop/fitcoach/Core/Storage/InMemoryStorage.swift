import Foundation

final class InMemoryStorage: StorageProviding {
    private var profile: UserProfile?
    private var plan: Plan?
    private var logs: [DailyLog] = []
    private let queue = DispatchQueue(label: "InMemoryStorage", attributes: .concurrent)

    func fetchUserProfile() -> UserProfile? {
        var result: UserProfile?
        queue.sync {
            result = profile
        }
        return result
    }

    func saveUserProfile(_ profile: UserProfile) {
        queue.async(flags: .barrier) {
            self.profile = profile
        }
    }

    func fetchPlan() -> Plan? {
        var result: Plan?
        queue.sync {
            result = plan
        }
        return result
    }

    func savePlan(_ plan: Plan) {
        queue.async(flags: .barrier) {
            self.plan = plan
        }
    }

    func fetchLogs() -> [DailyLog] {
        var result: [DailyLog] = []
        queue.sync {
            result = logs
        }
        return result
    }

    func saveLog(_ log: DailyLog) {
        queue.async(flags: .barrier) {
            if let index = self.logs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: log.date) }) {
                self.logs[index] = log
            } else {
                self.logs.append(log)
            }
        }
    }
}

