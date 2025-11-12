import Foundation

final class FileStorage: StorageProviding {
    private struct Keys {
        static let profile = "userProfile.json"
        static let plan = "plan.json"
        static let logs = "logs.json"
    }

    private let directory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let queue = DispatchQueue(label: "FileStorage", attributes: .concurrent)

    init(directory: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first) {
        self.directory = directory ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        ensureDirectory()
    }

    private func ensureDirectory() {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            print("Failed to create storage directory: \(error)")
        }
    }

    private func url(for key: String) -> URL {
        directory.appendingPathComponent(key)
    }

    func fetchUserProfile() -> UserProfile? {
        read(UserProfile.self, key: Keys.profile)
    }

    func saveUserProfile(_ profile: UserProfile) {
        queue.sync(flags: .barrier) {
            self.writeSync(profile, key: Keys.profile)
        }
    }

    func fetchPlan() -> Plan? {
        read(Plan.self, key: Keys.plan)
    }

    func savePlan(_ plan: Plan) {
        queue.sync(flags: .barrier) {
            self.writeSync(plan, key: Keys.plan)
        }
    }

    func fetchLogs() -> [DailyLog] {
        read([DailyLog].self, key: Keys.logs) ?? []
    }

    func saveLog(_ log: DailyLog) {
        queue.sync(flags: .barrier) {
            var logs = self.readLogsDirect()
            if let index = logs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: log.date) }) {
                logs[index] = log
            } else {
                logs.append(log)
            }
            self.writeSync(logs, key: Keys.logs)
        }
    }

    private func read<T: Decodable>(_ type: T.Type, key: String) -> T? {
        var result: T?
        queue.sync {
            let url = self.url(for: key)
            guard let data = try? Data(contentsOf: url) else { return }
            result = try? decoder.decode(T.self, from: data)
        }
        return result
    }

    private func writeSync<T: Encodable>(_ value: T, key: String) {
        let url = url(for: key)
        do {
            let data = try encoder.encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to persist \(key): \(error)")
        }
    }

    private func readLogsDirect() -> [DailyLog] {
        let url = url(for: Keys.logs)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? decoder.decode([DailyLog].self, from: data)) ?? []
    }
}

