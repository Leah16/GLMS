import Cocoa
import SwiftUI

/// Observable state for the HUD — keeps the same SwiftUI view tree alive
/// so animations are continuous rather than recreated
@MainActor
final class HUDState: ObservableObject {
    @Published var volume: String = "--"
    @Published var dbValue: Double = -100
    @Published var maxDB: Double = -60
}

/// A floating HUD panel that shows volume changes
@MainActor
final class VolumeHUDPanel {
    private var panel: NSPanel?
    private var hideTimer: Timer?
    private let hudState = HUDState()
    private var isVisible = false

    func show(volume: String, maxDB: Double = -60) {
        hideTimer?.invalidate()

        let dbValue = parseDB(volume) ?? -100

        if panel == nil {
            createPanel()
        }

        // Update state — SwiftUI animates the diff, no view replacement
        hudState.volume = volume
        hudState.dbValue = dbValue
        hudState.maxDB = maxDB

        guard let panel = panel, let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let x = screenFrame.maxX - panelSize.width - 20
        let y = screenFrame.maxY - panelSize.height - 10
        panel.setFrameOrigin(NSPoint(x: x, y: y))

        // Always order front — needed when switching Spaces (e.g. fullscreen apps)
        panel.orderFrontRegardless()

        if !isVisible {
            panel.alphaValue = 0
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                panel.animator().alphaValue = 1
            }
            isVisible = true
        }

        // Reset hide timer
        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.hide()
            }
        }
    }

    func hide() {
        guard let panel = panel, isVisible else { return }
        isVisible = false

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            panel.animator().alphaValue = 0
        }, completionHandler: {
            MainActor.assumeIsolated {
                panel.orderOut(nil)
            }
        })
    }

    private func createPanel() {
        let hudView = VolumeHUDView(state: hudState)
        let hosting = NSHostingView(rootView: hudView)
        hosting.frame = NSRect(x: 0, y: 0, width: 240, height: 80)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 80),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        panel.contentView = hosting
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden

        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true

        self.panel = panel
    }

    private func parseDB(_ str: String) -> Double? {
        let cleaned = str.replacingOccurrences(of: " dB", with: "")
            .replacingOccurrences(of: "dB", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleaned)
    }
}
