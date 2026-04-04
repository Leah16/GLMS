import SwiftUI

// Volume range constant
let volumeMinDB: Double = -100

struct VolumeHUDView: View {
    @ObservedObject var state: HUDState

    private var normalizedValue: Double {
        let maxDB = state.maxDB
        let range = maxDB - volumeMinDB
        guard range > 0 else { return 0 }
        return min(max((state.dbValue - volumeMinDB) / range, 0), 1)
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: speakerIcon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 28)
                .contentTransition(.symbolEffect(.replace))
                .animation(.easeInOut(duration: 0.2), value: speakerIcon)

            VStack(alignment: .leading, spacing: 6) {
                Text(state.volume)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.15), value: state.volume)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.quaternary)

                        Capsule()
                            .fill(.tint)
                            .frame(width: max(geo.size.width * normalizedValue, 3))
                    }
                }
                .frame(height: 5)
                .animation(.easeOut(duration: 0.15), value: normalizedValue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(width: 240, height: 80)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
    }

    private var speakerIcon: String {
        if state.dbValue <= -98 {
            return "speaker.fill"
        } else if state.dbValue <= -85 {
            return "speaker.wave.1.fill"
        } else if state.dbValue <= -70 {
            return "speaker.wave.2.fill"
        } else {
            return "speaker.wave.3.fill"
        }
    }
}
