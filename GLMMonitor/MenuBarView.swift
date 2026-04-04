import SwiftUI

struct MenuBarView: View {
    @ObservedObject var volumeService: VolumeService
    @State private var showSettings = false
    @State private var launchError: String?
    @State private var l10n = L10n()

    var body: some View {
        VStack(spacing: 14) {
            if showSettings {
                SettingsView(
                    onPollingChanged: { interval in
                        volumeService.startPolling(interval: interval)
                    },
                    onLanguageChanged: {
                        l10n = L10n()
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))

                Divider()

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSettings = false
                    }
                } label: {
                    Label(l10n.back, systemImage: "chevron.left")
                }
                .buttonStyle(.glass)
                .controlSize(.small)
                .padding(.bottom, 4)
            } else {
                mainContent
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .padding()
        .frame(width: showSettings ? 320 : 260)
        .animation(.easeInOut(duration: 0.25), value: showSettings)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var mainContent: some View {
        // Header
        HStack {
            Image(systemName: "hifispeaker.2.fill")
                .font(.title2)
            Text(l10n.glmMonitor)
                .font(.headline)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSettings = true
                }
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 4)

        if volumeService.isGLMRunning {
            // Volume display
            Text(volumeService.volume)
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.12), value: volumeService.volume)

            // Volume bar
            VolumeBar(value: volumeService.volumeDB, maxDB: volumeService.volumeMaxLimit)
                .frame(height: 8)
                .padding(.horizontal)

            // Max volume label
            Text("\(l10n.maxVolume): \(String(format: "%.0f", volumeService.volumeMaxLimit)) dB")
                .font(.caption2)
                .foregroundStyle(.secondary)

            // Mute button
            Button {
                volumeService.toggleMute()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: volumeService.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    Text(volumeService.isMuted ? l10n.unmute : l10n.mute)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .tint(volumeService.isMuted ? .red : nil)
            .controlSize(.regular)

            Divider()

            // GLM control + Quit
            HStack(spacing: 10) {
                Button {
                    if volumeService.isGLMVisible {
                        volumeService.hideGLM()
                    } else {
                        volumeService.showGLM()
                    }
                } label: {
                    Label(
                        volumeService.isGLMVisible ? l10n.hideGLM : l10n.showGLM,
                        systemImage: volumeService.isGLMVisible ? "eye.slash" : "eye"
                    )
                }
                .buttonStyle(.glass)
                .controlSize(.small)

                Button(l10n.quit) {
                    quitApp()
                }
                .buttonStyle(.glass)
                .controlSize(.small)
            }
        } else {
            VStack(spacing: 12) {
                if let error = launchError {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    ProgressView()
                        .controlSize(.regular)
                    Text(l10n.launchingGLM)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 20)
            .onAppear {
                launchGLM()
            }

            Divider()

            HStack(spacing: 10) {
                if launchError != nil {
                    Button {
                        launchError = nil
                        launchGLM()
                    } label: {
                        Label(l10n.retry, systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.glass)
                    .controlSize(.small)
                }

                Button(l10n.quit) {
                    quitApp()
                }
                .buttonStyle(.glass)
                .controlSize(.small)
            }
        }
    }

    private func launchGLM() {
        if let error = volumeService.launchGLMIfNeeded() {
            launchError = error
        }
    }

    private func quitApp() {
        let quitGLM = UserDefaults.standard.bool(forKey: "quitGLMOnExit")
        if quitGLM {
            volumeService.terminateGLM()
        }
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Sub-views

struct VolumeBar: View {
    let value: Double
    var maxDB: Double = -60

    private var normalizedValue: Double {
        let range = maxDB - volumeMinDB
        guard range > 0 else { return 0 }
        return min(max((value - volumeMinDB) / range, 0), 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)

                Capsule()
                    .fill(barColor)
                    .frame(width: max(geo.size.width * normalizedValue, 3))
                    .animation(.easeOut(duration: 0.12), value: normalizedValue)
            }
        }
    }

    private var barColor: some ShapeStyle {
        AnyShapeStyle(.tint)
    }
}
