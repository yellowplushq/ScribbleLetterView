# ScribbleLetterView

Animated handwritten text for UIKit and SwiftUI. Give it a word and it writes the word out stroke by stroke, like a pen on paper.

It's a Swift port of [kumailnanji/letters](https://github.com/kumailnanji/letters). Hershey script fonts set the spacing and stroke order, and hand-tuned Bézier paths draw each letter from a to z.

## Requirements

- iOS 15 or later
- No third-party dependencies

## Installation

Add the package with Swift Package Manager:

```swift
.package(url: "https://github.com/yellowplushq/ScribbleLetterView", from: "1.0.0")
```

Then add the `ScribbleLetter` product to your target.

## UIKit

```swift
import ScribbleLetter

let scribble = ScribbleLetterView(text: "hello")
scribble.color = .systemIndigo
scribble.timing = .tween(duration: 2.5, curve: .easeInOut) // or .spring(.bouncy)
scribble.loops = true
scribble.loopPause = 0.5
scribble.onComplete = { print("drawn") }
scribble.play()

scribble.progress = 0.4 // Jumps to 40% and stops playback
```

Control playback with `play()`, `pause()`, `replay()` and `reset()`. Read the current state from `isPlaying`, and observe it with `onPlayingChange` and `onProgressChange`.

The view scales the text to fit its bounds and centers it. `sizeThatFits(_:)` and `intrinsicContentSize` return a size that matches the text's aspect ratio.

## SwiftUI

```swift
ScribbleText("hello", autoPlay: true, loops: true, color: .pink)
    .frame(height: 56)

// Scrubber: when you pass `progress`, the view doesn't play on its own.
ScribbleText("hello", progress: value)

// Toolbar
@StateObject var controller = ScribbleLetterController()
ScribbleText("hello", autoPlay: true, controller: controller)
Button("Replay") { controller.replay() }
ProgressView(value: controller.progress)
```

On iOS 16 and later, `ScribbleText` sizes itself to the text's aspect ratio within the space it's offered. On iOS 15, it fills its frame and centers the text.

## Example App

Open `Example/Workspace.xcworkspace` and run **ScribbleApp**. The SwiftUI tab has a settings panel, and the UIKit tab cycles through phrases.

To regenerate the Xcode project, run `xcodegen` in `Example`.

## Differences from the React Package

- The `svgDefs` gradient option isn't supported.
- The `fit-curve` smoothing mode and the Chaikin, Gaussian and resampling options aren't supported. They're off by default upstream and only affect characters outside a–z.
- In UIKit, setting `progress` stops playback, and `play()` still works afterward. In the React package, a `progress` prop turns playback off.
- At progress 1, every stroke is fully drawn. In the React package, the first strokes of a short word can end slightly short.
- With `rewindsBeforePlay`, `replay()` un-writes first only when the text is fully drawn. Otherwise it draws from the start.
- A `tension` below 1 is treated as 1.

## Glyph Data

`Sources/ScribbleLetter/Resources/glyphs.json` is generated from `src/hershey-data.ts` and `src/custom-letters.ts` in the [upstream repository](https://github.com/kumailnanji/letters). To change a glyph, edit its `d` string there.

`swift test` checks the layout against values from the JavaScript implementation.

## Acknowledgements

- [kumailnanji/letters](https://github.com/kumailnanji/letters) by Kumail Nanji. This package ports its glyph data, layout and animation logic. Thank you for the original library.
- The Hershey fonts, created by Dr. A. V. Hershey at the U.S. National Bureau of Standards.

## License

ScribbleLetterView is available under the MIT License. It includes code and data from kumailnanji/letters, which is also MIT-licensed. See [LICENSE](LICENSE).
