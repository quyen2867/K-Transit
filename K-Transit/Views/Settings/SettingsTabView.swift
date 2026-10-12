import SwiftUI

struct SettingsTabView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var community: CommunityDataStore

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Appearance
                Section {
                    Picker(selection: $settings.theme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    } label: {
                        Label("테마", systemImage: "paintbrush")
                    }
                } header: {
                    Text("외관")
                }

                // MARK: - Language
                Section {
                    Picker(selection: $settings.language) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    } label: {
                        Label("언어", systemImage: "globe")
                    }
                    .onChange(of: settings.language) { newLang in
                        UserDefaults.standard.set([newLang.rawValue], forKey: "AppleLanguages")
                    }
                } header: {
                    Text("언어")
                }

                // MARK: - Developer
                Section {
                    Toggle(isOn: $settings.debugMode) {
                        Label("디버그 모드", systemImage: "ladybug")
                    }
                } header: {
                    Text("개발자")
                } footer: {
                    Text("Raw 데이터와 디버그 로그를 표시합니다")
                }

                // MARK: - About
                Section {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("정보")
                }

                // MARK: - Community
                Section {
                    // Telegram
                    socialLink(
                        url: "https://t.me/mankittk",
                        imageURL: nil,
                        title: "Mquyen186",
                        subtitle: community.info.telegramSubscribers > 0 ? "@mankittk · \(community.info.telegramSubscribers) subscribers" : "@mankittk",
                        fallbackIcon: "paperplane.fill",
                        accentColor: Color(red: 0.16, green: 0.63, blue: 0.89)
                    )

                    // Facebook
                    socialLink(
                        url: "https://www.facebook.com/quyen.2867",
                        imageURL: nil,
                        title: "Mquyen186",
                        subtitle: "Facebook · quyen.2867",
                        fallbackIcon: "person.3.fill",
                        accentColor: Color(red: 0.23, green: 0.35, blue: 0.60)
                    )
                } header: {
                    Text("커뮤니티")
                }

                // MARK: - Credits
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "wave.3.right.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                        Text("K-Transit")
                            .font(.system(size: 16, weight: .bold))
                        Text("by Mquyen186")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Text("github.com/quyen2867")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle(Text("설정"))
        }
    }

    // MARK: - Social Link Row

    private func socialLink(url: String, imageURL: String?, title: String, subtitle: String, fallbackIcon: String, accentColor: Color) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                // Avatar
                if let imgURL = imageURL, let url = URL(string: imgURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        default:
                            fallbackAvatar(icon: fallbackIcon, color: accentColor)
                        }
                    }
                } else {
                    fallbackAvatar(icon: fallbackIcon, color: accentColor)
                }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func fallbackAvatar(icon: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 40, height: 40)
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
        }
    }
}
