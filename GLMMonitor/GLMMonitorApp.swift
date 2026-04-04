import SwiftUI

@main
struct GLMMonitorApp: App {
    @StateObject private var volumeService = VolumeService()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(volumeService: volumeService)
        } label: {
            Label(menuBarTitle, systemImage: menuBarIcon)
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarTitle: String {
        if volumeService.isGLMRunning {
            return volumeService.volume
        }
        return "GLM"
    }

    private var menuBarIcon: String {
        if !volumeService.isGLMRunning {
            return "speaker.slash"
        }
        if volumeService.isMuted {
            return "speaker.slash.fill"
        }
        return "speaker.wave.2.fill"
    }
}
