//
//  ControlSurface.swift
//  ScribbleApp
//

import ScribbleLetter
import SwiftUI

struct Settings {
    enum Ink: String, CaseIterable, Identifiable {
        case label = "Ink"
        case pink = "Pink"
        case indigo = "Indigo"
        case orange = "Orange"

        var id: Self { self }

        var color: Color {
            switch self {
            case .label: .primary
            case .pink: .pink
            case .indigo: .indigo
            case .orange: .orange
            }
        }
    }

    enum Motion: String, CaseIterable, Identifiable {
        case easeInOut = "Ease In Out"
        case easeOut = "Ease Out"
        case easeIn = "Ease In"
        case linear = "Linear"
        case gentle = "Gentle Spring"
        case snappy = "Snappy Spring"
        case bouncy = "Bouncy Spring"
        case smooth = "Smooth Spring"

        var id: Self { self }
    }

    var text = "hello"
    var variant: ScribbleVariant = .simple
    var color: Ink = .label
    var strokeWidth = 2.0
    var overlap = 0.02
    var motion: Motion = .easeInOut
    var duration = 2.0
    var loops = true
    var rewindsBeforePlay = false
    var loopPause = 0.5
    var isScrubbing = false
    var progress = 1.0

    var timing: ScribbleTiming {
        switch motion {
        case .easeInOut: .tween(duration: duration, curve: .easeInOut)
        case .easeOut: .tween(duration: duration, curve: .easeOut)
        case .easeIn: .tween(duration: duration, curve: .easeIn)
        case .linear: .tween(duration: duration, curve: .linear)
        case .gentle: .spring(.gentle)
        case .snappy: .spring(.snappy)
        case .bouncy: .spring(.bouncy)
        case .smooth: .spring(.smooth)
        }
    }
}

struct ControlSurface: View {
    @Binding var settings: Settings

    var body: some View {
        Form {
            Section {
                TextField("Text", text: $settings.text)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                Picker("Font", selection: $settings.variant) {
                    Text("Simple").tag(ScribbleVariant.simple)
                    Text("Complex").tag(ScribbleVariant.complex)
                }
            } footer: {
                Text("Lowercase letters use hand-drawn glyphs. Other characters use the Hershey font's strokes.")
            }

            Section("Style") {
                Picker("Color", selection: $settings.color) {
                    ForEach(Settings.Ink.allCases) { Text($0.rawValue).tag($0) }
                }
                ValueSlider(title: "Stroke Width", value: $settings.strokeWidth, range: 0.5 ... 5, format: "%.1f")
                ValueSlider(title: "Overlap", value: $settings.overlap, range: 0 ... 0.5, format: "%.2f")
            }

            Section("Motion") {
                Picker("Timing", selection: $settings.motion) {
                    ForEach(Settings.Motion.allCases) { Text($0.rawValue).tag($0) }
                }
                if case .tween = settings.timing {
                    ValueSlider(title: "Duration", value: $settings.duration, range: 0.2 ... 6, format: "%.1f s")
                }
            }

            Section("Playback") {
                Toggle("Loop", isOn: $settings.loops)
                if settings.loops {
                    ValueSlider(
                        title: "Pause Between Loops",
                        value: $settings.loopPause,
                        range: 0 ... 3,
                        format: "%.1f s"
                    )
                }
                Toggle("Rewind Before Playing", isOn: $settings.rewindsBeforePlay)
                Toggle("Scrub Manually", isOn: $settings.isScrubbing)
            }
        }
    }
}

private struct ValueSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, value))
                    .monospacedDigit()
                    .foregroundColor(.secondary)
            }
            Slider(value: $value, in: range)
                .accessibilityLabel(title)
        }
    }
}
