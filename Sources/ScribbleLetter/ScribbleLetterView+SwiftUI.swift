//
//  ScribbleLetterView+SwiftUI.swift
//  ScribbleLetter
//

#if canImport(UIKit)
    import SwiftUI
    import UIKit

    /// Drives a `ScribbleText` from outside, e.g. from toolbar buttons. Hold it in `@StateObject`.
    @MainActor
    public final class ScribbleLetterController: ObservableObject {
        @Published public internal(set) var isPlaying = false
        /// Updates on every playback frame.
        @Published public internal(set) var progress: Double = 1

        private weak var view: ScribbleLetterView?

        public init() {}

        public func play() { view?.play() }
        public func pause() { view?.pause() }
        public func replay() { view?.replay() }
        public func reset() { view?.reset() }

        // Both run inside a SwiftUI update, where publishing isn't allowed, so their state changes wait a turn.

        func attach(_ view: ScribbleLetterView) {
            self.view = view
            DispatchQueue.main.async { [weak self, weak view] in
                guard let self, let view, self.view === view else { return }
                isPlaying = view.isPlaying
                progress = view.progress
            }
        }

        /// Only lets go if `view` is still the one this controller drives; a controller can be shared.
        func detach(_ view: ScribbleLetterView) {
            guard self.view === view else { return }
            self.view = nil
            DispatchQueue.main.async { [weak self] in
                guard let self, self.view == nil else { return }
                isPlaying = false
            }
        }
    }

    /// SwiftUI wrapper around `ScribbleLetterView`. On iOS 16 and later it sizes itself to the text's
    /// aspect ratio within the proposed size, so constrain one dimension, e.g. `.frame(height: 56)`.
    /// On iOS 15 it fills its frame and centers the text inside.
    @MainActor
    public struct ScribbleText {
        let text: String
        let progress: Double?
        let autoPlay: Bool
        let loops: Bool
        let rewindsBeforePlay: Bool
        let loopPause: TimeInterval
        let timing: ScribbleTiming
        let overlap: Double
        let strokeWidth: CGFloat
        let color: Color
        let variant: ScribbleVariant
        let tension: Double
        let controller: ScribbleLetterController?
        let onComplete: (() -> Void)?
        let onPlayingChange: ((Bool) -> Void)?
        let onProgressChange: ((Double) -> Void)?

        /// - Parameters:
        ///   - text: Lowercase a–z and spaces render with hand-tuned glyphs.
        ///   - progress: External 0–1 progress. When set, the view doesn't play and `controller` has no effect.
        ///   - autoPlay: Draws the text once the view appears.
        ///   - loops: Cycles forever: draw, wait `loopPause`, un-write at half duration, draw again.
        ///   - rewindsBeforePlay: When `play()` or `replay()` starts fully drawn, un-writes first.
        ///   - loopPause: Seconds to hold the drawn text before a loop un-writes it. `.infinity` holds it.
        ///   - timing: Tween or spring used for each draw.
        ///   - overlap: How much adjacent paths blend while drawing, from 0 to 0.5.
        ///   - strokeWidth: Stroke width in font units.
        ///   - variant: Hershey font used for spacing and fallback glyphs.
        ///   - tension: Catmull-Rom tension for fallback glyphs. Values below 1 act as 1.
        ///   - onComplete: Called at the end of every forward draw.
        ///   - onPlayingChange: Called on the next main-queue turn after playback starts or stops.
        ///   - onProgressChange: Called on every playback frame.
        public init(
            _ text: String,
            progress: Double? = nil,
            autoPlay: Bool = false,
            loops: Bool = false,
            rewindsBeforePlay: Bool = false,
            loopPause: TimeInterval = 0,
            timing: ScribbleTiming = .default,
            overlap: Double = 0.02,
            strokeWidth: CGFloat = 2,
            color: Color = .primary,
            variant: ScribbleVariant = .simple,
            tension: Double = 4,
            controller: ScribbleLetterController? = nil,
            onComplete: (() -> Void)? = nil,
            onPlayingChange: ((Bool) -> Void)? = nil,
            onProgressChange: ((Double) -> Void)? = nil
        ) {
            self.text = text
            self.progress = progress
            self.autoPlay = autoPlay
            self.loops = loops
            self.rewindsBeforePlay = rewindsBeforePlay
            self.loopPause = loopPause
            self.timing = timing
            self.overlap = overlap
            self.strokeWidth = strokeWidth
            self.color = color
            self.variant = variant
            self.tension = tension
            self.controller = controller
            self.onComplete = onComplete
            self.onPlayingChange = onPlayingChange
            self.onProgressChange = onProgressChange
        }

        private func update(_ view: ScribbleLetterView, _ coordinator: Coordinator) {
            view.text = text
            view.variant = variant
            view.tension = tension
            view.strokeWidth = strokeWidth
            view.color = UIColor(color)
            view.overlap = overlap
            view.timing = timing
            view.loops = loops
            view.rewindsBeforePlay = rewindsBeforePlay
            view.loopPause = loopPause
            view.onComplete = onComplete
            let controller = progress == nil ? controller : nil
            view.onPlayingChange = { [controller, onPlayingChange] isPlaying in
                // Playback also stops inside SwiftUI updates, e.g. below, where publishing isn't allowed.
                DispatchQueue.main.async {
                    controller?.isPlaying = isPlaying
                    onPlayingChange?(isPlaying)
                }
            }
            view.onProgressChange = { [controller, onProgressChange] progress in
                controller?.progress = progress
                onProgressChange?(progress)
            }
            if let progress {
                coordinator.autoPlay?.cancel()
                view.progress = progress
            }
            if coordinator.controller !== controller {
                coordinator.controller?.detach(view)
                controller?.attach(view)
                coordinator.controller = controller
            }
        }
    }

    extension ScribbleText: UIViewRepresentable {
        public final class Coordinator {
            /// The deferred `autoPlay` start. Cancelled if `progress` is set or the view is removed first.
            var autoPlay: Task<Void, Never>?
            weak var controller: ScribbleLetterController?
        }

        public func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        public func makeUIView(context: Context) -> ScribbleLetterView {
            let view = ScribbleLetterView(text: text)
            // Without sizeThatFits (iOS 15), SwiftUI sizes the view from intrinsicContentSize; let the frame win.
            view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            update(view, context.coordinator)
            if autoPlay, progress == nil {
                view.progress = 0
                // Start after this update pass, so callbacks don't mutate state mid-update.
                context.coordinator.autoPlay = Task { [weak view] in
                    guard !Task.isCancelled else { return }
                    view?.play()
                }
            }
            return view
        }

        public func updateUIView(_ view: ScribbleLetterView, context: Context) {
            update(view, context.coordinator)
        }

        public static func dismantleUIView(_ view: ScribbleLetterView, coordinator: Coordinator) {
            coordinator.autoPlay?.cancel()
            view.pause()
            coordinator.controller?.detach(view)
        }

        @available(iOS 16.0, *)
        public func sizeThatFits(
            _ proposal: ProposedViewSize,
            uiView: ScribbleLetterView,
            context _: Context
        ) -> CGSize? {
            uiView.sizeThatFits(CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0))
        }
    }
#endif
