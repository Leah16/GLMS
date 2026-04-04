import SwiftUI

enum PollingSpeed: String, CaseIterable, Identifiable {
    case standard = "standard"
    case fast = "fast"
    case fastest = "fastest"

    var id: String { rawValue }

    var interval: TimeInterval {
        switch self {
        case .standard: return 0.5
        case .fast: return 0.25
        case .fastest: return 0.1
        }
    }

    func label(_ l10n: L10n) -> String {
        switch self {
        case .standard: return l10n.pollingStandard
        case .fast: return l10n.pollingFast
        case .fastest: return l10n.pollingFastest
        }
    }
}

struct SettingsView: View {
    @AppStorage("quitGLMOnExit") var quitGLMOnExit: Bool = false
    @AppStorage("pollingSpeed") var pollingSpeed: String = PollingSpeed.standard.rawValue
    @AppStorage("appLanguage") var appLanguage: String = AppLanguage.system.rawValue

    var onPollingChanged: ((TimeInterval) -> Void)?
    var onLanguageChanged: (() -> Void)?

    private var l10n: L10n { L10n() }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                Text(l10n.settings)
                    .font(.headline)
            }
            .padding(.top, 4)

            Divider()

            // Quit GLM on exit
            Toggle(isOn: $quitGLMOnExit) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.quitGLMOnExit)
                        .font(.body)
                    Text(l10n.quitGLMOnExitDesc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)

            Divider()

            // Polling speed
            VStack(alignment: .leading, spacing: 6) {
                Text(l10n.pollingSpeed)
                    .font(.body)

                Picker("", selection: $pollingSpeed) {
                    ForEach(PollingSpeed.allCases) { speed in
                        Text(speed.label(l10n)).tag(speed.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: pollingSpeed) {
                    if let speed = PollingSpeed(rawValue: pollingSpeed) {
                        onPollingChanged?(speed.interval)
                    }
                }
            }

            Divider()

            // Language
            VStack(alignment: .leading, spacing: 6) {
                Text(l10n.language)
                    .font(.body)

                Picker("", selection: $appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang.rawValue)
                    }
                }
                .onChange(of: appLanguage) {
                    onLanguageChanged?()
                }
            }

            Spacer()
        }
        .padding()
    }
}
