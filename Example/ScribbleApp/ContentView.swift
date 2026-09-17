//
//  ContentView.swift
//  ScribbleApp
//

import ScribbleLetter
import SwiftUI

struct ContentView: View {
    @StateObject private var controller = ScribbleLetterController()
    @State private var settings = Settings()

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                ScribbleText(
                    settings.text,
                    progress: settings.isScrubbing ? settings.progress : nil,
                    autoPlay: true,
                    loops: settings.loops,
                    rewindsBeforePlay: settings.rewindsBeforePlay,
                    loopPause: settings.loopPause,
                    timing: settings.timing,
                    overlap: settings.overlap,
                    strokeWidth: settings.strokeWidth,
                    color: settings.color.color,
                    variant: settings.variant,
                    controller: controller
                )
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { controller.replay() }
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("Replays the handwriting")

                if settings.isScrubbing {
                    Slider(value: $settings.progress)
                        .accessibilityLabel("Progress")
                } else {
                    PlaybackBar(controller: controller)
                }
            }
            .padding(24)

            ControlSurface(settings: $settings)
        }
    }
}

private struct PlaybackBar: View {
    @ObservedObject var controller: ScribbleLetterController

    var body: some View {
        VStack(spacing: 12) {
            ProgressView(value: controller.progress)
            HStack {
                Button("Play") { controller.play() }
                    .disabled(controller.isPlaying)
                Button("Pause") { controller.pause() }
                    .disabled(!controller.isPlaying)
                Button("Replay") { controller.replay() }
                Button("Reset") { controller.reset() }
            }
            .buttonStyle(.bordered)
        }
    }
}
