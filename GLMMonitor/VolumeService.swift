import Cocoa
import Combine

/// Reads GLM volume in real-time via macOS Accessibility API
@MainActor
final class VolumeService: ObservableObject {
    @Published var volume: String = "--"
    @Published var volumeDB: Double = -100
    @Published var isMuted: Bool = false
    @Published var isGLMRunning: Bool = false
    @Published var isGLMVisible: Bool = true
    @Published var volumeMaxLimit: Double = -60

    private let hudPanel = VolumeHUDPanel()

    private var timer: Timer?
    private var lastVolume: String = ""
    /// True if GLM was launched by us — will be auto-hidden
    private var launchedByUs = false

    init() {
        readMaxVolumeFromConfig()
        let savedSpeed = UserDefaults.standard.string(forKey: "pollingSpeed") ?? "standard"
        let interval = PollingSpeed(rawValue: savedSpeed)?.interval ?? 0.5
        startPolling(interval: interval)
    }

    func startPolling(interval: TimeInterval = 0.3) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.readGLMState()
            }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Mute Control (via Accessibility)

    func toggleMute() {
        guard let glmApp = findGLMApp() else { return }
        guard let window = getFirstWindow(of: glmApp) else { return }
        guard let buttons = getChildren(of: window, role: kAXButtonRole as CFString) else { return }
        // Button 0 is the mute button
        if let muteBtn = buttons.first {
            AXUIElementPerformAction(muteBtn, kAXPressAction as CFString)
            isMuted.toggle()
        }
    }

    // MARK: - GLM Lifecycle

    /// Launch GLM if not running. Returns error message on failure.
    @discardableResult
    func launchGLMIfNeeded() -> String? {
        if findGLMRunningApp() != nil { return nil }

        let glmURL = URL(fileURLWithPath: "/Applications/GLMv5.app")
        guard FileManager.default.fileExists(atPath: glmURL.path) else {
            return "GLMv5.app not found in /Applications"
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = false  // Don't bring to front initially

        launchedByUs = true
        NSWorkspace.shared.openApplication(
            at: glmURL,
            configuration: config
        ) { app, error in
            if let error {
                Task { @MainActor in
                    _ = error
                }
            }
        }
        return nil
    }

    /// Terminate GLM process
    func terminateGLM() {
        findGLMRunningApp()?.terminate()
    }

    // MARK: - GLM Window Control

    func hideGLM() {
        guard let app = findGLMRunningApp() else { return }
        app.hide()
        isGLMVisible = false
    }

    func showGLM() {
        guard let app = findGLMRunningApp() else { return }
        app.unhide()
        app.activate()
        isGLMVisible = true
    }

    private func findGLMRunningApp() -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first {
            $0.localizedName == "GLMv5" || $0.bundleIdentifier == "com.genelec.GLM5"
        }
    }

    private func readGLMState() {
        guard let glmApp = findGLMApp() else {
            isGLMRunning = false
            volume = "--"
            return
        }
        isGLMRunning = true

        if let app = findGLMRunningApp() {
            // Auto-hide GLM if we launched it
            if launchedByUs && !app.isHidden {
                app.hide()
                launchedByUs = false  // Only do this once
                isGLMVisible = false
            } else {
                isGLMVisible = !app.isHidden
            }
        }

        guard let window = getFirstWindow(of: glmApp) else { return }

        // Read volume from text area 1
        if let textAreas = getChildren(of: window, role: kAXTextAreaRole as CFString) {
            if let firstArea = textAreas.first {
                if let val = getStringValue(of: firstArea) {
                    volume = val
                    if let dbVal = parseDB(val) {
                        volumeDB = dbVal
                    }
                    if val != lastVolume && !lastVolume.isEmpty {
                        hudPanel.show(volume: val, maxDB: volumeMaxLimit)
                    }
                    lastVolume = val
                }
            }
        }

        // Mute state is managed by toggleMute(), not polled from GLM
        // GLM's mute button title doesn't reliably change
    }

    // MARK: - Config File Reading

    /// Read max volume limit from GLM setup file
    private func readMaxVolumeFromConfig() {
        // Find the last used setup from GLM config
        let cfgPath = NSHomeDirectory() + "/Library/Application Support/Genelec/GLMv5.cfg"
        guard let cfgContent = try? String(contentsOfFile: cfgPath, encoding: .utf8) else { return }

        // Extract lastUsedSetup path
        var samPath: String?
        for line in cfgContent.components(separatedBy: "\n") {
            if line.contains("lastUsedSetup") {
                // Format: <VALUE name="lastUsedSetup" val="/path/to/file.sam"/>
                if let range = line.range(of: "val=\""), let endRange = line.range(of: "\"", range: range.upperBound..<line.endIndex) {
                    samPath = String(line[range.upperBound..<endRange.lowerBound])
                }
            }
        }

        // Read the .sam file for Volume_Max_Limit
        guard let path = samPath, let samContent = try? String(contentsOfFile: path, encoding: .utf8) else { return }

        for line in samContent.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("Volume_Max_Limit:") {
                let valStr = trimmed.replacingOccurrences(of: "Volume_Max_Limit:", with: "").trimmingCharacters(in: .whitespaces)
                if let val = Double(valStr) {
                    volumeMaxLimit = val
                }
                break
            }
        }
    }

    // MARK: - Accessibility Helpers

    private func findGLMApp() -> AXUIElement? {
        let workspace = NSWorkspace.shared
        for app in workspace.runningApplications {
            if app.localizedName == "GLMv5" || app.bundleIdentifier == "com.genelec.GLM5" {
                return AXUIElementCreateApplication(app.processIdentifier)
            }
        }
        return nil
    }

    private func getFirstWindow(of app: AXUIElement) -> AXUIElement? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &value)
        guard result == .success, let windows = value as? [AXUIElement], let first = windows.first else {
            return nil
        }
        return first
    }

    private func getChildren(of element: AXUIElement, role: CFString) -> [AXUIElement]? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &value)
        guard result == .success, let children = value as? [AXUIElement] else {
            return nil
        }
        return children.filter { child in
            var childRole: CFTypeRef?
            AXUIElementCopyAttributeValue(child, kAXRoleAttribute as CFString, &childRole)
            return (childRole as? String) == (role as String)
        }
    }

    private func getStringValue(of element: AXUIElement) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &value)
        guard result == .success else { return nil }
        return value as? String
    }

    private func getTitle(of element: AXUIElement) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &value)
        guard result == .success else { return nil }
        return value as? String
    }

    private func parseDB(_ str: String) -> Double? {
        let cleaned = str.replacingOccurrences(of: " dB", with: "")
            .replacingOccurrences(of: "dB", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleaned)
    }
}
