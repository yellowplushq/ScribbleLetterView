//
//  UIKitDemo.swift
//  ScribbleApp
//

import ScribbleLetter
import SwiftUI
import UIKit

struct UIKitDemo: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIKitDemoViewController {
        UIKitDemoViewController()
    }

    func updateUIViewController(_: UIKitDemoViewController, context _: Context) {}
}

/// Cycles through phrases, drawing each one after the previous finishes.
final class UIKitDemoViewController: UIViewController {
    private let phrases = ["hello", "nice to meet you", "welcome back"]
    private var phraseIndex = 0
    private var nextPhraseTask: Task<Void, Never>?

    private let scribbleView = ScribbleLetterView()
    private let slider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        scribbleView.text = phrases[phraseIndex]
        scribbleView.color = .systemIndigo
        scribbleView.strokeWidth = 2.5
        scribbleView.timing = .tween(duration: 2.5, curve: .easeInOut)
        scribbleView.onComplete = { [weak self] in self?.scheduleNextPhrase() }
        scribbleView.onProgressChange = { [weak self] in self?.slider.value = Float($0) }

        slider.value = Float(scribbleView.progress)
        slider.accessibilityLabel = "Progress"
        slider.addAction(UIAction { [weak self] _ in self?.scrub() }, for: .valueChanged)

        let replayButton = UIButton(configuration: .filled(), primaryAction: UIAction(title: "Replay") { [weak self] _ in
            self?.nextPhraseTask?.cancel()
            self?.scribbleView.replay()
        })
        let nextButton = UIButton(configuration: .gray(), primaryAction: UIAction(title: "Next Phrase") { [weak self] _ in
            self?.showNextPhrase()
        })
        let buttons = UIStackView(arrangedSubviews: [replayButton, nextButton])
        buttons.spacing = 12

        let stack = UIStackView(arrangedSubviews: [scribbleView, slider, buttons])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            // The view aspect-fits the text, so a fixed height and full width is enough.
            scribbleView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            scribbleView.heightAnchor.constraint(equalToConstant: 120),
            slider.widthAnchor.constraint(equalTo: stack.widthAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scribbleView.replay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nextPhraseTask?.cancel()
        scribbleView.reset()
    }

    private func scrub() {
        nextPhraseTask?.cancel()
        scribbleView.progress = Double(slider.value)
    }

    private func scheduleNextPhrase() {
        nextPhraseTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard !Task.isCancelled else { return }
            self?.showNextPhrase()
        }
    }

    private func showNextPhrase() {
        nextPhraseTask?.cancel()
        phraseIndex = (phraseIndex + 1) % phrases.count
        scribbleView.text = phrases[phraseIndex]
        scribbleView.replay()
    }
}
