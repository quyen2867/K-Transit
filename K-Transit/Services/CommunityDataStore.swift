import SwiftUI
import Combine

struct CommunityInfo: Codable {
    var telegramSubscribers: Int = 0
    var lastUpdated: Date = .distantPast

    var isStale: Bool {
        Date().timeIntervalSince(lastUpdated) > 300 // 5 minutes
    }
}

class CommunityDataStore: ObservableObject {
    @Published var info: CommunityInfo

    private let cacheKey = "communityData"

    init() {
        // Load cache
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode(CommunityInfo.self, from: data) {
            self.info = cached
        } else {
            self.info = CommunityInfo()
        }
    }

    func refreshIfNeeded() {
        guard info.isStale else { return }
        Task {
            await fetchTelegram()
            await MainActor.run {
                info.lastUpdated = Date()
                save()
            }
        }
    }

    // MARK: - Telegram

    private func fetchTelegram() async {
        // Telegram doesn't have a simple public API for subscriber count
        // Parse from t.me page meta tags
        await fetchTelegramChannel("mankittk")
    }

    private func fetchTelegramChannel(_ username: String) async {
        guard let url = URL(string: "https://t.me/\(username)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = String(data: data, encoding: .utf8) {
                // Parse subscriber count from meta or page content
                // Look for patterns like "2 039 subscribers" or "1,178 subscribers"
                let patterns = [
                    "([\\d\\s,]+)\\s*subscribers",
                    "([\\d\\s,]+)\\s*members"
                ]
                for pattern in patterns {
                    if let regex = try? NSRegularExpression(pattern: pattern),
                       let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
                       let range = Range(match.range(at: 1), in: html) {
                        let numStr = String(html[range])
                            .replacingOccurrences(of: " ", with: "")
                            .replacingOccurrences(of: ",", with: "")
                            .replacingOccurrences(of: " ", with: "")
                        if let count = Int(numStr) {
                            await MainActor.run {
                                info.telegramSubscribers = count
                            }
                            break
                        }
                    }
                }
            }
        } catch {
            print("[Community] Telegram fetch failed: \(error)")
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
}
